(** Implements {!Token}. *)

type t = { token : Token_type.t; data : string list }

(** Creates a {!Token.t} record. 

    Arguments:
    - Raw contents/data (lines of strings taken from a source file).

    Returns: a {!Token.t} record. *)
let create token data = { token; data }

(** Get the {!Token_type.t} of a token. *)
let token t = t.token

(** Get the raw data of a token. *)
let data t = t.data
