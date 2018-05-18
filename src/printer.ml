(** Implements {!Printer}. *)

(** Raised when a result is invalid. *)
exception InvalidResult of string

let lines_of_comments r = r.Result.data
let lines_of_blanks r = r.Result.data

let lines_of_code r =
  let raw_data = r.Result.data in
  let out = match List.length r.Result.stdout > 0 with
    | false -> []
    | true -> List.map (Printf.sprintf "  1> %s") r.Result.stdout in
  let err = match List.length r.Result.stderr > 0 with
    | false -> []
    | true -> List.map (Printf.sprintf "  2> %s") r.Result.stderr in
  let exit_code = [(Printf.sprintf "  [%d]" r.Result.exit_code)] in
  let pass, reason = match r.Result.success with
    | (true, stat) -> ("PASSED", Result.string_of_status stat)
    | (false, stat) -> ("FAILED", Result.string_of_status stat) in
  let pass_str = [(Printf.sprintf "  ==> %s (%s)" pass reason)] in
  List.flatten [raw_data; out; err; exit_code; pass_str]

let rec build_result results acc =
  match results with
  | [] -> acc
  | hd :: tl ->
    match hd.Result.token with
    | Token_type.Comment -> 
      let output = lines_of_comments hd in
      build_result tl (List.append acc output)
    | Token_type.Blank -> 
      let output = lines_of_blanks hd in
      build_result tl (List.append acc output)
    | Token_type.Code -> 
      let output = lines_of_code hd in
      build_result tl (List.append acc output)
    | x ->
      let token_str = Token_type.string_of x in
      let msg = Printf.sprintf "Cannot print result of type '%s'" token_str in
      raise (InvalidResult msg)

let header title =
  let line_1 = Printf.sprintf "---------- Running test '%s'" title in
  let line_2 = "" in
  String.concat "\n" [line_1; line_2]

let test results =
  let lines = build_result results [] in
  String.concat "\n" lines

let footer success =
  let pass = match success with
  | true -> "PASSED"
  | false -> "FAILED" in
  let line_1 = "" in
  let line_2 = "================" in
  let line_3 = Printf.sprintf "Test: %s" pass in
  String.concat "\n" [line_1; line_2; line_3]
