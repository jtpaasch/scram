(** Implements {!Lexer}. *)

let pad s = String.concat "" [s; "        "]

let is_blank s =
  match String.trim s with
  | "" -> true
  | _ -> false

(** Identifies which {!Token_type} a string is an instance of. *)
let token_of s =
  match is_blank s with
  | true -> Token_type.Blank
  | false ->
    let padded_s = pad s in
    let fst_three = String.sub padded_s 0 3 in
    match fst_three with
    | " *$" -> Token_type.ProfiledCode
    | _ ->
      let fst_two = String.sub padded_s 0 2 in
      match is_blank fst_two with
      | false -> Token_type.Comment
      | true ->
        match String.sub padded_s 2 6 = "#stats" with
        | true -> Token_type.Stats
        | false ->
          match String.sub padded_s 2 5 = "#diff" with
          | true -> Token_type.Diff
          | false ->
            match String.sub padded_s 2 2 with
            | "$ " -> Token_type.Code
            | _ -> Token_type.Output

(** Determines whether a token [tk_1] and another token [tk_2] should
    be grouped together as part of the same token, given a set of
    already matched tokens [matches]. For some {!Token_type}s, like are
    grouped with like. For instance, blank lines go together with
    blank lines. But with code, the expected output should be grouped
    with it too. *)
let are_grouped tk_1 tk_2 matches =
  match matches with
  | [] -> true
  | _ ->
    match tk_1 with
    | Token_type.Blank -> tk_2 = Token_type.Blank
    | Token_type.Comment -> tk_2 = Token_type.Comment
    | Token_type.Code -> tk_2 = Token_type.Output
    | Token_type.ProfiledCode -> tk_2 = Token_type.Output
    | _ -> false

(** This function takes as arguments a designated {!Token_type.t}, and a 
    list of lines (strings). Then it peels off from the front of the list
    the zero or more lines that belong with the specified token.

    For instance, if you ask this function to peel off [Token_type.Blank]
    lines, it will peel blank line after blank line off the front of the 
    list (if there are any), until it finds a non-blank line.

    It returns a pair: a list of matched lines (if any), and a list of
    the rest of the lines. 

    Note: this function peels off all lines that should be collected
    together under a single token, and sometimes those lines are not all
    of the same type. For example, a [Token_type.Code] can have 
    [Token_type.Output] lines associated with it too. The [are_grouped]
    function above determines which lines get grouped together. *)
let rec collect tk acc src_lines =
  match src_lines with
  | [] -> (acc, [])
  | hd :: tl ->
    let tk_2 = token_of hd in
    match are_grouped tk tk_2 acc with
    | false -> (acc, src_lines)
    | true ->
      let new_acc = List.append acc [hd] in
      collect tk new_acc tl

(** This function takes a list of raw lines (strings) from a source,
    and tokenizes them.

    Arguments:
    - A list of strings to tokenize (the raw source lines).
    - An accumulator (an empty {!Token.t} list).

    Returns: a {!Token.t} list.

    For example, if [src_lines] is a list of lines from a file,
    [let tokens = tokenize src_lines []] will go through the
    [src_lines] and tokenize them, returning a {!Token.t} list. *)
let rec tokenize src_lines acc =
  match src_lines with
  | [] -> acc
  | hd :: tl ->
    let tk = token_of hd in
    let matches, the_rest = collect tk [] src_lines in
    let record = Token.create tk matches in
    tokenize the_rest (List.append acc [record])
