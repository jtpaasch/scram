(** Implements {!Matcher}. *)

(** Check if at least one item in the list of [tests] is [true]. *)
let has_match (tests : bool list) =
  let matches = List.filter (fun s -> s = true) tests in
  List.length matches > 0

let is_exact_match str_1 str_2 = str_1 = str_2

let is_regex_match str_1 str_2 =
  let r = Str.regexp str_1 in
  Str.string_match r str_2 0

(** Check if two strings are equal. For example, [compare "a" "a"]
    will return [true]. You can use regular expressions in the first
    string. For instance, [compare "^a.*" "abcdef"] will return [true]. *)
let cmp str_1 str_2 =
  let is_exact = is_exact_match str_1 str_2 in
  let is_regex = is_regex_match str_1 str_2 in
  has_match [is_exact; is_regex]
