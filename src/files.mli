(** A file reading utility. *)

exception NoSuchFile of string
exception CouldNotRead of string

(** Reads a file and returns its contents as a string.

    Arguments:
    - A path to a file (a string).

    Returns: A string. *)
val to_string : string -> string

(** Reads a file and returns its contents as a list of lines.

    Arguments:
    - A path to a file (a string).

    Returns: A string list.

    Note that the newline character is stripped
    from the end of each line. *)
val to_lines : string -> string list
