import Lake

open Lake DSL

package TheoremLibrary

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @
  "58e016c6f6c829b5f25b1a87a88f495f40e70aa7"

@[default_target]
lean_lib TheoremLibrary
