
let pad s = String.concat "" [s; "    "]

let is_blank s =
  match String.trim s with
  | "" -> true
  | _ -> false

let token_of s =
  match is_blank s with
  | true -> Token_type.Blank
  | false ->
    let padded_s = pad s in
    let fst_two = String.sub padded_s 0 2 in
    match is_blank fst_two with
    | false -> Token_type.Comment
    | true ->
      let snd_two = String.sub padded_s 2 2 in
      match snd_two with
      | "$ " -> Token_type.Code
      | _ -> Token_type.Output

let are_grouped tk_1 tk_2 matches =
  match matches with
  | [] -> true
  | _ ->
    match tk_1 with
    | Token_type.Blank -> tk_2 = Token_type.Blank
    | Token_type.Comment -> tk_2 = Token_type.Comment
    | Token_type.Code -> tk_2 = Token_type.Output
    | _ -> false

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

let rec tokenize src acc =
  match src with
  | [] -> acc
  | hd :: tl ->
    let tk = token_of hd in
    let matches, the_rest = collect tk [] src in
    let record = Token.create tk matches in
    tokenize the_rest (List.append acc [record])
