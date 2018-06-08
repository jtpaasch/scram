(** Tokens identified by {!Lexer.tokenize}. 

    A token represents a chunk of adjacent lines from a source file that
    belong together. For instance, a token of type {!Token_type.t.Comment}
    represents a comment that spans one or more lines.

    Note that tokens are assigned to groups of lines rather than individual
    lines, since, say, a comment can actually span multiple adjacent lines, 
    or a chunk of blank space can span multiple adjacent than one line. *)

(** A {!Token.t} carries with it the type of token it is
    (the {!Token_type}), and its raw contents/data (a list of lines
    taken from a source file). *)
type t = { token : Token_type.t; data : string list }

(** Creates a {!Token.t} record.

    Arguments:
    - Raw contents/data (lines of strings taken from a source file).

    Returns: a {!Token.t} record. 

    For example, [create Token_type.Comment ["Comment 1"; "Comment 2"]]
    will create a comment token, whose data (or value) consists
    of the two lines "Comment 1" and "Comment 2". *)
val create : Token_type.t -> string list -> t

(** Get the {!Token_type.t} of the token. *)
val token : t -> Token_type.t

(** Get the raw contents/data of the token. *)
val data : t -> string list
