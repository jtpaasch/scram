(** Utility for pretty printing AST nodes. *)

(** Generate a {!Tty_str.t} list from a {!Node.t} list. *)
val pprint : Node.t list -> Tty_str.t list
