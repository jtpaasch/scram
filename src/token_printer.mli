(** Utility for printing tokens. *)

(** Generate a {!Tty_str.t} list) from a {!Token.t} list. *)
val pprint : Token.t list -> Tty_str.t list
