(** Breaks test files up into tokens. *)

(** Determines which {!Token_type} a string is an instance of. *)
val token_of : string -> Token_type.t
(** For example, [token_of "   "] will return [Token_type.Blank]. *)

(** Given a list of strings and an accumulator, returns a list of tokens. *)
val tokenize : string list -> Token.t list -> Token.t list
