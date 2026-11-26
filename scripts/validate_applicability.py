"""Check the FRM-000133 source pin and reproduce its synthetic boundary example."""

import hashlib
import json
import math
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RECORD = Path("docs/applicability/frm-000133.json")
MODULE = "TheoremLibrary/Geometry/Sphere/NormalizationSpectrum.lean"
NAMESPACE = "TheoremLibrary.Geometry.Sphere"
THEOREM = "normalization_singularValues"
_SHA1 = re.compile(r"[0-9a-f]{40}")
_LEAN_PATH = re.compile(r"TheoremLibrary(?:/[A-Za-z_][A-Za-z0-9_]*)+[.]lean")


def require(predicate, message):
    if not predicate:
        raise ValueError(message)


def proof_declarations(record):
    public = record["publicReference"]
    supporting = public.get("supportingDeclarations", [])
    require(isinstance(supporting, list), "supporting declarations must be a list")
    for item in supporting:
        require(isinstance(item, dict) and set(item) == {"module", "sourcePath", "declaration", "applicability"}
                and isinstance(item["applicability"], str) and item["applicability"].strip(),
                "supporting declaration requires a source, name and applicability statement")
    declarations = [record["proof"], *public["relatedDeclarations"], *supporting]
    require(len({item["declaration"] for item in declarations}) == len(declarations),
            f"duplicate declaration for {record['id']}")
    return declarations


def _git_blob(root, commit, path):
    try:
        return subprocess.check_output(
            ["git", "show", "--no-ext-diff", "--no-textconv", f"{commit}:{path}"],
            cwd=root, stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError as exc:
        raise ValueError(f"proof-source pin does not resolve {path}") from exc


def _pinned_source(root, commit, path, digest):
    require(_SHA1.fullmatch(commit), "the proof source requires an exact Git commit")
    require(_LEAN_PATH.fullmatch(path), "proof source must name a public Lean module")
    source = _git_blob(root, commit, path)
    require(hashlib.sha256(source).hexdigest() == digest, f"proof source digest mismatch for {path}")
    require((root / path).read_bytes().replace(b"\r\n", b"\n") == source,
            f"the checked proof source differs from the pinned source for {path}")
    return source


def _validate_proof(root, proof):
    require(proof["declaration"] == f"{NAMESPACE}.{THEOREM}", "unresolved proof declaration")
    require(proof["sourcePath"] == MODULE and proof["module"] == f"{NAMESPACE}.NormalizationSpectrum",
            "unresolved proof module")
    commit = proof["sourceCommit"]
    source = _pinned_source(root, commit, MODULE, proof["sourceSha256"])
    lean = _git_blob(root, commit, "lean-toolchain").decode().strip()
    require(lean == proof["leanToolchain"] == (root / "lean-toolchain").read_text().strip(),
            "Lean toolchain differs from the pinned proof environment")
    manifest = _git_blob(root, commit, "lake-manifest.json")
    require((root / "lake-manifest.json").read_bytes().replace(b"\r\n", b"\n") == manifest,
            "Lake manifest differs from the pinned proof environment")
    mathlib = [item["rev"] for item in json.loads(manifest)["packages"] if item["name"] == "mathlib"]
    require(mathlib == [proof["mathlibCommit"]], "Mathlib commit differs from the pinned proof environment")
    text = source.decode()
    require(f"namespace {NAMESPACE}\n" in text
            and f"theorem {THEOREM} (x : E) (hx : x ≠ 0)" in text, "unresolved proof declaration")


def _validate_scope(scope, study):
    require(scope == {
        "map": "x ↦ (1 / ‖x‖) • x",
        "domain": "finite-dimensional real inner-product space",
        "premise": "x ≠ 0",
        "tangentDirections": "v with inner product ⟨x, v⟩ = 0",
        "claim": "inverse-radius tangent gain and radial kernel",
        "extent": "single local derivative",
    }, "formal scope must preserve the exact map, domain, nonzero premise and local tangent claim")
    telemetry = {"operatorRevision", "numericType", "epsilonPolicy", "maskPolicy", "population"}
    require(set(study) == telemetry | {"checkpoint", "applicability", "denominators"},
            "unsupported study telemetry fields")
    require(study["checkpoint"] == "https://github.com/pH34r-pH/research-notes/issues/31",
            "the Research Notes checkpoint is missing")
    require(study["applicability"] == "unmeasured"
            and all(study[key] is None for key in telemetry),
            "the public pilot has unmeasured applicability and unknown operator and population telemetry")
    denominators = study["denominators"]
    require(set(denominators) == {"presented", "unmasked", "active", "cutoff"}
            and all(isinstance(value, str) and value.strip() for value in denominators.values()),
            "the study handoff requires explicit denominators")


def _normalize(point, cutoff, *, masked=False):
    if masked:
        return None
    radius = math.hypot(*point)
    if radius < cutoff:
        return (1.0, 0.0)
    return tuple(value / radius for value in point)


def _tangent_gain(point, tangent, step, cutoff):
    plus = tuple(value + step * direction for value, direction in zip(point, tangent))
    minus = tuple(value - step * direction for value, direction in zip(point, tangent))
    high, low = _normalize(plus, cutoff), _normalize(minus, cutoff)
    return math.fsum((a - b) * direction for a, b, direction in zip(high, low, tangent)) / (2 * step)


def _vector(value):
    require(len(value) == 2 and all(type(axis) in (int, float) and math.isfinite(axis) for axis in value),
            "the synthetic example requires finite two-dimensional vectors")
    return tuple(value)


def _validate_example(example):
    epsilon, step, tolerance = (example[key] for key in ("epsilon", "step", "absoluteTolerance"))
    require(all(type(value) in (int, float) and math.isfinite(value) for value in (epsilon, step, tolerance)),
            "synthetic epsilon, step and tolerance must be finite numbers")
    require(0 < step < epsilon and 0 < tolerance <= 1e-9, "invalid synthetic epsilon, step or tolerance")
    require(example["numericType"] == "IEEE-754 binary64" and sys.float_info.mant_dig == 53
            and sys.float_info.radix == 2, "the synthetic fixture requires binary64")
    require(example["cutoffPolicy"] == "use a constant unit direction when norm is below epsilon"
            and example["maskPolicy"] == "exclude masked rows before normalization", "unexpected synthetic branch policy")
    active, small, tangent = (_vector(example[key]) for key in ("activeInput", "smallInput", "unitTangent"))
    active_radius, small_radius = math.hypot(*active), math.hypot(*small)
    require(active_radius - step > epsilon and small_radius == epsilon / 2 and small_radius + step < epsilon,
            "synthetic perturbations must remain within their respective branches")
    require(math.hypot(*tangent) == 1 and all(
        math.fsum(axis * direction for axis, direction in zip(point, tangent)) == 0 for point in (active, small)
    ), "the synthetic perturbation must be unit tangent at both inputs")
    expected = {"active": 1 / active_radius, "smallExact": 1 / small_radius, "smallCutoff": 0.0}
    require(example["expectedTangentialGain"] == expected, "synthetic targets differ from the declared branch laws")
    observed = {
        "active": _tangent_gain(active, tangent, step, epsilon),
        "smallExact": _tangent_gain(small, tangent, step, 0.0),
        "smallCutoff": _tangent_gain(small, tangent, step, epsilon),
    }
    require(all(math.isclose(observed[key], gain, abs_tol=tolerance, rel_tol=0.0)
                for key, gain in expected.items()), "synthetic tangential gain differs from the target")
    require(_normalize(active, epsilon, masked=True) is None, "masked rows must be excluded")
    return observed


def validate(root, record):
    require(type(record["schemaVersion"]) is int and record["schemaVersion"] == 1
            and record["id"] == "FRM-000133", "unsupported applicability record")
    _validate_scope(record["formalScope"], record["studyHandoff"])
    require({item["sourcePath"] for item in proof_declarations(record)} == {MODULE},
            "FRM-000133 declarations must resolve to its pinned proof module")
    _validate_proof(root, record["proof"])
    return _validate_example(record["syntheticExample"])


def validate_indexed_scope(root, record):
    identifier = record["id"]
    require(type(record["schemaVersion"]) is int and record["schemaVersion"] == 1,
            f"unsupported applicability record for {identifier}")
    scope = record["formalScope"]
    required = {"map", "domain", "extent", "claim", "studyBoundary"}
    require(set(scope) == required | {"premises"} and all(
        isinstance(scope[key], str) and scope[key].strip() for key in required
    ), f"{identifier} requires an exact map, domain, proved claim and study boundary")
    premises = scope["premises"]
    require(isinstance(premises, list) and premises and all(
        isinstance(value, str) and value.strip() for value in premises
    ), f"{identifier} requires explicit proof premises")
    binding = record["publicReference"]
    paths = {declaration["sourcePath"] for declaration in proof_declarations(record)}
    proof = record["proofSource"]
    require(set(proof["sha256"]) == paths, f"missing or extra proof source pin for {identifier}")
    for path, digest in proof["sha256"].items():
        _pinned_source(root, proof["commit"], path, digest)
    handoff = record["studyHandoff"]
    unavailable = {"operatorRevision", "numericType", "epsilonPolicy", "maskPolicy", "population"}
    require(set(handoff) == unavailable | {"checkpoint", "applicability"}
            and handoff["applicability"] == "unmeasured" and all(handoff[key] is None for key in unavailable),
            f"{identifier} study applicability remains unmeasured in the public proof record")
    require(handoff["checkpoint"] == binding["researchNotes"], f"{identifier} study checkpoint differs from index")


if __name__ == "__main__":
    try:
        gains = validate(ROOT, json.loads((ROOT / RECORD).read_text(encoding="utf-8")))
        for record_path in sorted((ROOT / RECORD.parent).glob("*.json")):
            if record_path.name != RECORD.name:
                validate_indexed_scope(ROOT, json.loads(record_path.read_text(encoding="utf-8")))
    except (KeyError, OSError, TypeError, ValueError) as exc:
        sys.exit(f"Public applicability check failed: {exc}")
    print(f"FRM-000133 synthetic tangential gains: {gains}. Study applicability: unmeasured.")
