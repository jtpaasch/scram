(** Implements {!Matcher}. *)

let at_least_one_is_true (flags : bool list) =
  let truths = List.filter (fun s -> s = true) flags in
  List.length truths > 0

let is_exact_match str_1 str_2 = str_1 = str_2

let is_regex_match str_1 str_2 =
  let r = Str.regexp str_1 in
  Str.string_match r str_2 0

(** Check if two strings are equal. For example, [cmp "a" "a"]
    will return [true]. You can use regular expressions in the first
    string. For instance, [cmp "^a.*" "abcdef"] will return [true].

    Arguments:
    - A string (can be a regular expression).
    - A second string.

    Returns: A boolean indicating
    if the second string matches the first. *)
let cmp str_1 str_2 =
  let is_exact = is_exact_match str_1 str_2 in
  let is_regex = is_regex_match str_1 str_2 in
  at_least_one_is_true [is_exact; is_regex]
