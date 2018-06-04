(** Utility for pretty printing the contents of a file. *)

(** Generate a {!Tty_str.t} list from a string list.

    Arguments:
    - A string list (the list of strings from a file).

    Returns: a {!Tty_str.t} list.

    For example, suppose [lines_of_file] is this list:
    [["Lorem ipsum"; "doler sit amet."]]. Then [pprint lines_of_file]
    will return a {!Tty_str.t} list (see {!Tty_str} for more on
    printing [Tty_str] strings to a terminal). *)
val pprint : string list -> Tty_str.t list
