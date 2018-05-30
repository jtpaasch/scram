(** The types of tokens the {!Lexer} can identify. *)

(** The {!Lexer} can identify the following types of tokens. *)
type t =
  | Blank         (* Blank lines. *)
  | Comment       (* Comment lines. *)
  | ProfiledCode  (* Code to execute and profile. *)
  | Code          (* Code to execute (without profiling). *)
  | Output        (* Output expected from executed code. *)
  | Stats         (* A directive to show profile stats. *)
  | Diff          (* A directive to show diff of profiled code output. *)

(** Generates a string representation of a {!Token_type.t}. *)
val string_of : t -> string
