(** Breaks a list of strings up into tokens. *)

(** Determines which {!Token_type} a string is an instance of.
     For example, [token_of "   "] will return [Token_type.Blank]. *)
val token_of : string -> Token_type.t

(** This function takes a list of raw lines (strings) from a source,
    and tokenizes them.

    Arguments:
    - A list of strings to tokenize (the raw source lines).
    - An accumulator (an empty {!Token.t} list).

    Returns: a {!Token.t} list.

    For example, if [src_lines] is a list of lines from a file,
    [let tokens = tokenize src_lines []] will go through the
    [src_lines] and tokenize them, returning a {!Token.t} list. *)
val tokenize : string list -> Token.t list -> Token.t list
