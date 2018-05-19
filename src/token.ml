(** Implements {!Token}. *)

type t = { token : Token_type.t; data : string list }

let create token data = { token; data }


