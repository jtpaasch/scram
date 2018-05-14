type t = Blank | Comment | Code | Output

let string_of t =
  match t with
  | Blank -> "BLANK"
  | Comment -> "COMMENT"
  | Code -> "CODE"
  | Output -> "OUTPUT"
