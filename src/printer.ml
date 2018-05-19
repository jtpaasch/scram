(** Implements {!Printer}. *)

exception InvalidResult of string

let tty_strings_of lines = List.map Tty_str.create lines

let lines_of_comments r = tty_strings_of r.Result.data
let lines_of_blanks r = tty_strings_of r.Result.data

let lines_of_code r =
  let raw_data = List.map (Tty_str.create ~fmt:Bold) r.Result.data in
  let out = match List.length r.Result.stdout > 0 with
    | false -> []
    | true ->
      List.map (fun s ->
        let msg = Printf.sprintf "  1> %s" s in
	Tty_str.create msg
      ) r.Result.stdout
    in
  let err = match List.length r.Result.stderr > 0 with
    | false -> []
    | true ->
      List.map (fun s ->
        let msg = Printf.sprintf "  2> %s" s in
	Tty_str.create msg
      ) r.Result.stderr
    in
  let exit_code =
    let msg = Printf.sprintf "  [%d]" r.Result.exit_code in
    let msg_ttystr = Tty_str.create msg in
    [msg_ttystr] in
  let fmt, pass, reason = match r.Result.success with
    | (true, stat) -> (Tty_str.Green, "OK", Result.string_of_status stat)
    | (false, stat) -> (Tty_str.Red, "FAILED", Result.string_of_status stat)
    in
  let msg = Printf.sprintf "  ==> %s (%s)" pass reason in
  let msg_ttystr = Tty_str.create ~fmt:fmt msg in
  let pass_str = [msg_ttystr] in
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

let test_body results = build_result results []

let test_header title =
  let line_1 =
    Tty_str.create ~fmt:Bold "========================================" in
  let line_2 =
    Tty_str.create ~fmt:Bold (Printf.sprintf "Test '%s'" title) in
  let line_3 =
    Tty_str.create ~fmt:Bold "----------------------------------------" in
  [line_1; line_2; line_3]

let test_footer success =
  let pass,fmt = match success with
  | true -> ("PASSED", Tty_str.Green)
  | false -> ("FAILED", Tty_str.Red) in
  let line_1 = Tty_str.create "" in
  let line_2 =
    Tty_str.create ~fmt:Tty_str.Bold
    "========================================" in
  let line_3 =
    Tty_str.create ~fmt:fmt (Printf.sprintf "Test: %s" pass) in
  [line_1; line_2; line_3]

(** Generate pprintable output (a {!Tty_str.t} list) of test results. *)
let pprint_test title results success =
  let header = test_header title in
  let body = test_body results in
  let footer = test_footer success in
  List.flatten [header; body; footer]

(** Generate pprintable output (a {!Tty_str.t} list) from a string list
    (the contents of a file). *)
let pprint_file lines =
  let header = Tty_str.create ~fmt:Bold "---------------- File contents\n" in
  let body = tty_strings_of lines in
  let footer = Tty_str.create "" in
  List.flatten [[header]; body; [footer]]

let marshal_token tk =
  let tk_type = Token_type.string_of tk.Token.token in
  let tk_type_str = Printf.sprintf "Token type: %s" tk_type in
  let tk_type_ttystr = Tty_str.create tk_type_str in
  let lines_header = Tty_str.create "Raw data:" in
  let lines = List.map (Printf.sprintf "- %s") tk.Token.data in
  let lines_ttystrs = List.map Tty_str.create lines in
  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs; [footer]]

(** Generate pprintable output (a {!Tty_str.t} list) from
    a {!Token.t} list. *)
let pprint_tokens tokens =
  let header = Tty_str.create ~fmt:Bold "---------------- Tokens\n" in
  let tokens_output = List.map marshal_token tokens in
  let tokens_ttystrs = List.flatten tokens_output in
  List.flatten [[header]; tokens_ttystrs]

let marshal_node n =
  let tk_type = Token_type.string_of n.Node.token in
  let tk_type_str = Printf.sprintf "Token type: %s" tk_type in
  let tk_type_ttystr = Tty_str.create tk_type_str in
  let lines_header = Tty_str.create "Raw data:" in
  let lines = List.map (Printf.sprintf "- %s") n.Node.data in
  let lines_ttystrs = List.map Tty_str.create lines in
  let cmd = Printf.sprintf "Cmd: %s" n.Node.cmd in
  let cmd_ttystr = Tty_str.create cmd in
  let output_header = Tty_str.create "Expected output:" in
  let output = List.map (Printf.sprintf "- %s") n.Node.output in
  let output_ttystrs = List.map Tty_str.create output in
  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs;
    [cmd_ttystr]; [output_header]; output_ttystrs; [footer]]

(** Generate pprintable output (a {!Tty_str.t} list) from a {!Node.t} list. *)
let pprint_nodes nodes =
  let header = Tty_str.create ~fmt:Bold "---------------- AST Nodes\n" in
  let nodes_output = List.map marshal_node nodes in
  let nodes_ttystrs = List.flatten nodes_output in
  List.flatten [[header]; nodes_ttystrs]

let marshal_result r =
  let tk_type = Token_type.string_of r.Result.token in
  let tk_type_str = Printf.sprintf "Token type: %s" tk_type in
  let tk_type_ttystr = Tty_str.create tk_type_str in
  let lines_header = Tty_str.create "Raw data:" in
  let lines = List.map (Printf.sprintf "- %s") r.Result.data in
  let lines_ttystrs = List.map Tty_str.create lines in
  let cmd = Printf.sprintf "Cmd: %s" r.Result.cmd in
  let cmd_ttystr = Tty_str.create cmd in
  let output_header = Tty_str.create "Expected output:" in
  let output = List.map (Printf.sprintf "- %s") r.Result.output in
  let output_ttystrs = List.map Tty_str.create output in
  let stdout_header = Tty_str.create "Captured stdout:" in
  let stdout_data = List.map (Printf.sprintf "- %s") r.Result.stdout in
  let stdout_ttystrs = List.map Tty_str.create stdout_data in
  let stderr_header = Tty_str.create "Captured stderr:" in
  let stderr_data = List.map (Printf.sprintf "- %s") r.Result.stderr in
  let stderr_ttystrs = List.map Tty_str.create stderr_data in
  let exit_code = Printf.sprintf "Exit code: %d" r.Result.exit_code in
  let exit_code_ttystr = Tty_str.create exit_code in
  let pass, reason =
    match r.Result.success with
    | (true, stat) -> ("Passed", Result.string_of_status stat)
    | (false, stat) -> ("Failed", Result.string_of_status stat) in
  let success = Printf.sprintf "Test result: %s (%s)" pass reason in
  let success_ttystr = Tty_str.create success in
  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs;
    [cmd_ttystr]; [output_header]; output_ttystrs; [stdout_header];
    stdout_ttystrs; [stderr_header]; stderr_ttystrs; [exit_code_ttystr];
    [success_ttystr]; [footer]]

(** Generate pprintable output (a {!Tty_str.t} list) from a
    {!Result.t} list. *)
let pprint_results results =
  let header =
    Tty_str.create ~fmt:Bold "---------------- Execution Results\n" in
  let results_output = List.map marshal_result results in
  let results_ttystrs = List.flatten results_output in
  List.flatten [[header]; results_ttystrs]
