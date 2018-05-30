(** Implements {!Token_type}. *)

type t =
  | Blank 
  | Comment
  | ProfiledCode 
  | Code
  | Output 
  | Stats
  | Diff

let string_of t =
  match t with
  | Blank -> "BLANK"
  | Comment -> "COMMENT"
  | Code -> "CODE"
  | ProfiledCode -> "PROFILED CODE"
  | Output -> "OUTPUT"
  | Stats -> "STATS"
  | Diff -> "DIFF"
