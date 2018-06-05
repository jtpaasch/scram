(** Utility for matching strings. *)

(** Check if two strings are equal. For example, [cmp "a" "a"]
    will return [true]. You can use regular expressions in the first
    string. For instance, [cmp "^a.*" "abcdef"] will return [true].

    Arguments:
    - A string (can be a regular expression).
    - A second string.

    Returns: A boolean indicating
    if the second string matches the first. *)
val cmp : string -> string -> bool
