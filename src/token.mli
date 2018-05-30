(** Tokens identified by the {!Lexer}. *)

(** A [Token] is defined by which type of token it is
    (the {!Token_type}), and its data (a list of lines). *)
type t = { token : Token_type.t; data : string list }

(** Creates a token, given a {!Token_type} and a list of strings. *)
val create : Token_type.t -> string list -> t
(** For instance, [create Token_type.Comment ["Comment 1"; "Comment 2"]]
    will create a comment token, whose data (or value) consists
    of the two lines "Comment 1" and "Comment 2". *)

(** Get the token type of the token. *)
val token : t -> Token_type.t

(** Get the raw data of the token. *)
val data : t -> string list
