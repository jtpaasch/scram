(** A file reading utility. *)

(** Reads a file and returns its contents (as a list of lines).

    Arguments:
    - A path to a file (a string).

    Returns: A string list.

    Note that the newline character is stripped
    from the end of each line. *)
val load : string -> string list
