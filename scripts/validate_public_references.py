"""Check the applicability records against the public index and render Lean checks."""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from validate_applicability import ROOT, require


RECORDS = "docs/applicability"
IDENTIFIER = re.compile(r"FRM-[0-9]{6}|LIB-[A-Z]+-[0-9]{3}")
LEAN_NAME = re.compile(r"TheoremLibrary(?:\.[A-Za-z_][A-Za-z0-9_']*)+")
RESEARCH_NOTES = "https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#"


def _read(root, path):
    return (root / path).read_text(encoding="utf-8")


def _load_records(root):
    return {path.relative_to(root).as_posix(): json.loads(path.read_bytes())
            for path in sorted((root / RECORDS).glob("*.json"))}


def _label_ids(label):
    identifiers = []
    for part in label.split(" / "):
        primary, *suffixes = part.split("/")
        identifiers.append(primary)
        if suffixes:
            require(primary.startswith("LIB-") and len(suffixes) == 1
                    and re.fullmatch(r"[0-9]{3}", suffixes[0]), f"invalid combined identifier {part}")
            identifiers.append(primary.rsplit("-", 1)[0] + "-" + suffixes[0])
    require(all(IDENTIFIER.fullmatch(value) for value in identifiers)
            and len(set(identifiers)) == len(identifiers), f"invalid or duplicate index labels {label}")
    return set(identifiers)


def _declared_ids(record):
    identifier = record["id"]
    public = record.get("publicReference")
    if public is None:
        return {identifier: {record["proof"]["declaration"]}}
    declarations = [record["proof"], *public["relatedDeclarations"]]
    names = {declaration["declaration"] for declaration in declarations}
    require(len(names) == len(declarations), f"duplicate declaration for {identifier}")
    bindings = {identifier: names}
    for alias, targets in public["aliases"].items():
        require(alias != identifier and IDENTIFIER.fullmatch(alias)
                and isinstance(targets, list) and targets and set(targets) <= names
                and len(set(targets)) == len(targets), f"invalid alias binding {alias}")
        bindings[alias] = set(targets)
    require(set(bindings) == _label_ids(public["indexLabel"]), f"index identifiers differ for {identifier}")
    return bindings


def _add_bindings(target, bindings):
    for identifier, declarations in bindings.items():
        require(identifier not in target, f"duplicate or conflicting stable identifier {identifier}")
        target[identifier] = declarations


def _public_modules(root):
    imports = re.findall(r"^import[ \t]+(TheoremLibrary\.[\w.]+)[ \t]*(?:--[^\n]*)?$",
                         _read(root, "TheoremLibrary.lean"), re.M)
    inventory = re.findall(r"^- `(TheoremLibrary\.[\w.]+)` —", _read(root, "PUBLIC_CORE.md"), re.M)
    require(imports and len(set(imports)) == len(imports) and len(set(inventory)) == len(inventory)
            and set(imports) == set(inventory), "PUBLIC_CORE module inventory differs from the public imports")
    for module in imports:
        require((root / (module.replace(".", "/") + ".lean")).is_file(), f"missing public module source {module}")
    return set(imports)


def _index_cards(root):
    index = _read(root, "INDEX.md")
    cards = re.findall(r"^### ([^\n]+) — [^\n]+\n(.*?)(?=^#{2,3} |\Z)", index, re.M | re.S)
    require(len({label for label, _ in cards}) == len(cards), "duplicate index heading")
    return dict(cards)


def _check_source(root, declaration, exported):
    module, name = declaration["module"], declaration["declaration"]
    require(LEAN_NAME.fullmatch(module) and LEAN_NAME.fullmatch(name), "invalid qualified Lean name")
    path = module.replace(".", "/") + ".lean"
    require(declaration["sourcePath"] == path and (root / path).is_file(), f"missing or mismatched declaration source {path}")
    require(module in exported, f"declaration module is missing from the public imports {module}")
    return path


def _check_card(root, path, record, cards, exported):
    require(type(record["schemaVersion"]) is int and record["schemaVersion"] == 1
            and IDENTIFIER.fullmatch(record["id"]), f"unsupported public reference {path}")
    public = record["publicReference"]
    label = public["indexLabel"]
    require(public["publicImport"] is True and label in cards, f"missing public index entry {label}")
    card = cards.pop(label)
    sources = {_check_source(root, item, exported) for item in [record["proof"], *public["relatedDeclarations"]]}
    links = set(re.findall(r"\]\((TheoremLibrary/[^ )]+\.lean)\)", card))
    require(sources == links and f"]({path})" in card, f"source or applicability links differ for {label}")
    notes = public["researchNotes"]
    require(notes.startswith(RESEARCH_NOTES) and re.fullmatch("[a-z0-9-]+", notes.removeprefix(RESEARCH_NOTES))
            and f"]({notes})" in card, f"Research Notes destination differs for {label}")


def validate(root, records, previous=()):
    cards, exported = _index_cards(root), _public_modules(root)
    bindings = {}
    for path, record in records.items():
        _add_bindings(bindings, _declared_ids(record))
        _check_card(root, path, record, cards, exported)
    require(not cards, "missing applicability records for indexed results")
    old_bindings = {}
    for record in previous:
        _add_bindings(old_bindings, _declared_ids(record))
    for identifier, declarations in old_bindings.items():
        current = bindings.get(identifier, set())
        preserved = declarations == current if identifier.startswith("LIB-") else declarations <= current
        require(preserved, f"stable reference was silently removed or repointed: {identifier}")
    return sorted(set().union(*bindings.values()))


def _previous_records(root, base):
    if not base:
        return []
    require(re.fullmatch("[0-9a-f]{40}", base), "validation base must be an exact Git commit")
    names = subprocess.check_output(["git", "ls-tree", "-r", "-z", "--name-only", base, "--", RECORDS], cwd=root)
    return [json.loads(subprocess.check_output(["git", "show", f"{base}:{path}"], cwd=root))
            for path in names.decode().split("\0") if path.endswith(".json")]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", default="")
    parser.add_argument("--lean-output", type=Path)
    args = parser.parse_args()
    try:
        names = validate(ROOT, _load_records(ROOT), _previous_records(ROOT, args.base))
        if args.lean_output is not None:
            with args.lean_output.open("x", encoding="utf-8") as output:
                output.write("import TheoremLibrary\n\n" + "".join(f"#check {name}\n" for name in names))
    except (KeyError, OSError, TypeError, ValueError, subprocess.CalledProcessError) as exc:
        sys.exit(f"Public reference check failed: {exc}")
    print(f"Public reference inventory passed for {len(names)} distinct Lean declarations.")


if __name__ == "__main__":
    main()
