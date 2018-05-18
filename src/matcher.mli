(** Utilities for matching strings. *)

(** Check if two strings are exact clones. *)
val is_exact_match : string -> string -> bool
(** For example, [is_exact_match "a\nb" "a\nb"] will return [true], but
    [is_exact_match "a\nb" "a\n"] will return [false]. *)

(** Check if two strings match, where the first is a regex pattern. *)
val is_regex_match : string -> string -> bool
(** For example, [is_regex_match "^a.*" "abc def"] will return [true],
    but [is_regex_match "^a.*" "fed cba"] will return [false]. *)

(** Check if two strings are equal. Checks for an exact match
    first, then checks for a regular expression match (the first
    string can include regex patterns). *)
val cmp : string -> string -> bool
