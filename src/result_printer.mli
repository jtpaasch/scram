(** Utility for pretty printing result nodes. *)

(** Generate a {!Tty_str.t} list from a {!Result.t} list. *)
val pprint : Result.t list -> Tty_str.t list
