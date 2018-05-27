(** Implements {!Lexer}. *)

(** Pads a string on the right with extra spaces. *)
let pad s = String.concat "" [s; "        "]

(** Determines if a string contains only whitespace. *)
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
          match String.sub padded_s 2 2 with
          | "$ " -> Token_type.Code
          | _ -> Token_type.Output

(** Determines whether a token [tk_1] and another token [tk_2] should
    be grouped together as part of the same token, given a set of
    already matched tokens [matches]. For some {!Token_type}s, like are
    grouped with like. For instance, blank lines go together with
    blank lines. But lines of code should have its expected output
    grouped with it. *)
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

(** Calling [collect Token_type.Blank [] src] will go through the lines
    of [src], collecting together lines that are instances of the token
    type [Token_type.Blank]. When it reaches the first line that is not
    a match, it returns the blank lines as the [matches], and it returns
    the remaining lines as [the_rest]. *)
let rec collect tk matches the_rest =
  match the_rest with
  | [] -> (matches, [])
  | hd :: tl ->
    let tk_2 = token_of hd in
    match are_grouped tk tk_2 matches with
    | false -> (matches, the_rest)
    | true ->
      let new_matches = List.append matches [hd] in
      collect tk new_matches tl

(** Given a list of lines [src], [tokenize src []] will break
    the lines up into tokens and return the list of tokens. *)
let rec tokenize src acc =
  match src with
  | [] -> acc
  | hd :: tl ->
    let tk = token_of hd in
    let matches, the_rest = collect tk [] src in
    let record = Token.create tk matches in
    tokenize the_rest (List.append acc [record])
