(** The types of tokens the {!Lexer} can identify. *)

(** The {!Lexer} can identify blank lines, comment lines, lines
    of code, or lines of expected output. *)
type t = Blank | Comment | Code | Output

(** Generates a string representation of a {!Token_type.t}. *)
val string_of : t -> string
