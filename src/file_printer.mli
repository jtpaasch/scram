(** Utility for pretty printing the contents of a file. *)

(** Generate a {!Tty_str.t} list from a string list.
    Arguments:
    - A string list (the list of strings from a file).
    Returns: a {!Tty_str.t} list. *)
val pprint : string list -> Tty_str.t list
