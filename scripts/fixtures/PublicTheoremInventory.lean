import Lean.Elab.Command
import TheoremLibrary

open Lean Elab Command

private def checkPublicTheorems (modules : Array String)
    (declared : Array (String × String)) : CommandElabM Unit := do
  let env ← getEnv
  let moduleNames := env.allImportedModuleNames
  let actual : Array (String × String) := env.constants.fold (init := #[]) fun entries name info =>
    match info, env.getModuleIdxFor? name with
    | .thmInfo _, some index =>
      let moduleName := moduleNames[index.toNat]!.toString
      if modules.contains moduleName && !name.isInternalDetail then
        entries.push (name.toString, moduleName)
      else
        entries
    | _, _ => entries
  for entry in actual do
    unless declared.contains entry do
      logError m!"Public theorem has no applicability record: {entry.1} ({entry.2})"
  for entry in declared do
    unless actual.contains entry do
      logError m!"Applicability record does not name a theorem in its declared module: {entry.1} ({entry.2})"
  logInfo m!"Public theorem inventory contains {actual.size} declarations."
