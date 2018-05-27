(** Generates tables that can be printed to a tty. *)

(** Takes a list of rows (each row is a list of strings).
    Returns the table as a list of strings. *)
val create : string list list -> string list