(** Implements {!Printer}. *)

exception InvalidResult of string

let tty_strings_of lines = List.map Tty_str.create lines

let lines_of_comments r = tty_strings_of r.Result.data
let lines_of_blanks r = tty_strings_of r.Result.data

let lines_of_code r =
  let raw_data = List.map (Tty_str.create ~fmt:Tty_str.Bold) r.Result.data in
  let out =
    match r.Result.stdout with
    | None -> []
    | Some x ->
      List.map (fun s ->
        let msg = Printf.sprintf "  1> %s" s in
	Tty_str.create msg
      ) x
    in
  let err =
    match r.Result.stderr with
    | None -> []
    | Some x ->
      List.map (fun s ->
        let msg = Printf.sprintf "  2> %s" s in
	Tty_str.create msg
      ) x
    in
  let exit_code =
    match r.Result.exit_code with
    | None -> raise (InvalidResult "Exit code cannot be empty")
    | Some x ->
      let msg = Printf.sprintf "  [%d]" x in
      let msg_ttystr = Tty_str.create msg in
      [msg_ttystr] in
  let is_success = Success.is_successful r.Result.success in
  let why = Success.why r.Result.success in
  let fmt, pass, reason = match (is_success, why) with
    | (true, stat) -> (Tty_str.Green, "OK", Success.string_of_why stat)
    | (false, stat) -> (Tty_str.Red, "FAILED", Success.string_of_why stat)
    in
  let msg = Printf.sprintf "  ==> %s (%s)" pass reason in
  let msg_ttystr = Tty_str.create ~fmt:fmt msg in
  let pass_str = [msg_ttystr] in
  List.flatten [raw_data; out; err; exit_code; pass_str]

let lines_of_profiled_code r = lines_of_code r

let rec collect_stats nodes counter acc =
  match nodes with
  | [] -> acc
  | hd :: tl ->
    let trials = match hd.Result.trials with
    | Some x -> x
    | None ->
      let msg = "ProfiledCode node cannot have empty trial" in
      raise (InvalidResult msg) in
    let new_counter = counter + 1 in
    let avg = Trials.avg trials in
    let total = Trials.total trials in
    let line = [
      Printf.sprintf "%d" new_counter;
      Printf.sprintf "%.4f" avg;
      Printf.sprintf "%.4f" total;
    ] in
    let new_acc = List.append acc [line] in
    collect_stats tl new_counter new_acc

let lines_of_stats r processed =
  let header = List.map (Tty_str.create ~fmt:Tty_str.Bold) r.Result.data in
  let profiled_nodes = List.filter (fun x -> match x.Result.token with
    | Token_type.ProfiledCode -> true
    | _ -> false
  ) processed in
  let stats = collect_stats profiled_nodes 0 [] in
  let header_col = ["Id"; "Avg time"; "Total time"] in
  let rows = List.append [header_col] stats in
  let table_rows = Tty_table.create rows in
  let tty_table_rows =
    List.map (fun s -> Tty_str.create (Printf.sprintf "  %s" s)) table_rows in 
  List.append header tty_table_rows

let rec build_result nodes processed acc =
  match nodes with
  | [] -> acc
  | hd :: tl ->
    match hd.Result.token with
    | Token_type.Comment -> 
      let output = lines_of_comments hd in
      let new_processed = List.append processed [hd] in
      let new_acc = List.append acc output in
      build_result tl new_processed new_acc
    | Token_type.Blank -> 
      let output = lines_of_blanks hd in
      let new_processed = List.append processed [hd] in
      let new_acc = List.append acc output in
      build_result tl new_processed new_acc
    | Token_type.ProfiledCode ->
      let output = lines_of_profiled_code hd in
      let new_processed = List.append processed [hd] in
      let new_acc = List.append acc output in
      build_result tl new_processed new_acc
    | Token_type.Code -> 
      let output = lines_of_code hd in
      let new_processed = List.append processed [hd] in
      let new_acc = List.append acc output in
      build_result tl new_processed new_acc
    | Token_type.Stats ->
      let output = lines_of_stats hd processed in
      let new_processed = List.append processed [hd] in
      let new_acc = List.append acc output in
      build_result tl new_processed new_acc
    | x ->
      let token_str = Token_type.string_of x in
      let msg = Printf.sprintf "Cannot print result of type '%s'" token_str in
      raise (InvalidResult msg)

let test_body results = build_result results [] []

let test_header title =
  let line_1 =
    Tty_str.create ~fmt:Tty_str.Bold 
      "========================================" in
  let line_2 =
    Tty_str.create ~fmt:Tty_str.Bold (Printf.sprintf "Test '%s'" title) in
  let line_3 =
    Tty_str.create ~fmt:Tty_str.Bold 
      "----------------------------------------" in
  [line_1; line_2; line_3]

let test_footer success =
  let pass,fmt = match success with
  | true -> ("PASSED", Tty_str.Green)
  | false -> ("FAILED", Tty_str.Red) in
  let line_1 =
    Tty_str.create ~fmt:Tty_str.Bold
    "========================================" in
  let line_2 =
    Tty_str.create ~fmt:fmt (Printf.sprintf "Test: %s" pass) in
  [line_1; line_2]

(** Generate pprintable output (a {!Tty_str.t} list) of test results. *)
let pprint_test title results success =
  let header = test_header title in
  let body = test_body results in
  let footer = test_footer success in
  List.flatten [header; body; footer]

(** Generate pprintable output (a {!Tty_str.t} list) from a string list
    (the contents of a file). *)
let pprint_file lines =
  let header = Tty_str.create ~fmt:Tty_str.Bold 
    "---------------- File contents\n" in
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
  let header = Tty_str.create ~fmt:Tty_str.Bold "---------------- Tokens\n" in
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
  let cmd =
    match n.Node.cmd with
    | Some x -> Printf.sprintf "Cmd: %s" x
    | None -> "Cmd: N/a" in 
  let cmd_ttystr = Tty_str.create cmd in
  let output_header =
    match n.Node.output with
    | Some x -> Tty_str.create "Expected output:"
    | None -> Tty_str.create "Expected output: N/a" in
  let output =
    match n.Node.output with
    | Some x -> 
      begin
        match List.length x with
        | 0 -> ["- None specified"]
        | _ -> List.map (Printf.sprintf "- %s") x
      end
    | None -> [] in
  let output_ttystrs = List.map Tty_str.create output in
  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs;
    [cmd_ttystr]; [output_header]; output_ttystrs; [footer]]

(** Generate pprintable output (a {!Tty_str.t} list) from a {!Node.t} list. *)
let pprint_nodes nodes =
  let header = Tty_str.create ~fmt:Tty_str.Bold 
    "---------------- AST Nodes\n" in
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

  let cmd =
    match r.Result.cmd with
    | None -> "Cmd: N/a"
    | Some x -> Printf.sprintf "Cmd: %s" x in
  let cmd_ttystr = Tty_str.create cmd in

  let output_header =
    match r.Result.output with
    | None -> Tty_str.create "Expected output: N/a"
    | Some x -> Tty_str.create "Expected output:" in
  let output =
    match r.Result.output with
    | None -> []
    | Some x ->
      match List.length x with
      | 0 -> ["- None specified"]
      | _ -> List.map (Printf.sprintf "- %s") x in
  let output_ttystrs = List.map Tty_str.create output in

  let stdout_header =
    match r.Result.stdout with
    | None -> Tty_str.create "Captured stdout: N/a"
    | Some x -> Tty_str.create "Captured stdout:" in
  let stdout_data =
    match r.Result.stdout with
    | None -> []
    | Some x ->
      match List.length x with
      | 0 -> ["- None captured"]
      | _ -> List.map (Printf.sprintf "- %s") x in
  let stdout_ttystrs = List.map Tty_str.create stdout_data in

  let stderr_header =
    match r.Result.stderr with
    | None -> Tty_str.create "Captured stderr: N/a"
    | Some x -> Tty_str.create "Captured stderr:" in
  let stderr_data =
    match r.Result.stderr with
    | None -> []
    | Some x ->
      match List.length x with
      | 0 -> ["- None captured"]
      | _ -> List.map (Printf.sprintf "- %s") x in
  let stderr_ttystrs = List.map Tty_str.create stderr_data in

  let exit_code =
    match r.Result.exit_code with
    | None -> "Exit code: N/a"
    | Some x -> Printf.sprintf "Exit code: %d" x in
  let exit_code_ttystr = Tty_str.create exit_code in

  let pass, reason =
    let is_success = Success.is_successful r.Result.success in
    let why = Success.why r.Result.success in
    match (is_success, why) with
    | (true, stat) -> ("Passed", Success.string_of_why stat)
    | (false, stat) -> ("Failed", Success.string_of_why stat) in
  let success = Printf.sprintf "Test result: %s (%s)" pass reason in
  let success_ttystr = Tty_str.create success in

  let profile_header =
    match r.trials with
    | None -> "Profile: N/a"
    | Some x -> "Profile:" in
  let profile_header_ttystr = Tty_str.create profile_header in

  let profile =
    match r.trials with
    | None -> []
    | Some x ->
      let count = List.length (Trials.exe x) in
      let total = Trials.total x in
      let avg = Trials.avg x in
      let num_trials = Printf.sprintf "- Num trials: %d" count in
      let total = Printf.sprintf "- Total time: %.4f secs" total in
      let avg = Printf.sprintf "- Avg time: %.4f secs" avg in
      [num_trials; total; avg] in
  let profile_ttystrs = List.map Tty_str.create profile in

  let trials_header = 
    match r.trials with
    | None -> "Trials: N/a"
    | Some x -> "Trials:" in
  let trials_header_ttystr = Tty_str.create trials_header in

  let trials =
    match r.trials with
    | None -> []
    | Some x ->
      List.map (fun trial ->
        let cmd = trial.Execution.cmd in
        let dur = trial.Execution.duration in
        let out = trial.Execution.stdout in
        let err = trial.Execution.stderr in
        let ex_code = trial.Execution.exit_code in
        let header_str = "- Trial:" in
        let cmd_str = Printf.sprintf "- - Cmd: %s" cmd in
        let dur_str = Printf.sprintf "- - Duration: %.5f" dur in
        let ex_code_str = Printf.sprintf "- - Exit code: %d" ex_code in
        let out_header_str = "- - Stdout:" in
        let out_str =
          match List.length out with
          | 0 -> ["- - - None captured"]
          | _ -> List.map (fun x ->
            Printf.sprintf "- - - %s" x) out in
        let err_header_str = "- - Stderr:" in
        let err_str =
          match List.length err with
          | 0 -> ["- - - None captured"]
          | _ -> List.map (fun x ->
            Printf.sprintf "- - - %s" x) err in
        let all_strs = List.flatten [[header_str]; [cmd_str]; [ex_code_str]; 
          [out_header_str]; out_str; [err_header_str]; err_str; [dur_str]] in 
        String.concat "\n" all_strs
      ) x.Trials.executions in
  let trials_ttystr = List.map Tty_str.create trials in

  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs;
    [cmd_ttystr]; [output_header]; output_ttystrs; [stdout_header];
    stdout_ttystrs; [stderr_header]; stderr_ttystrs; [exit_code_ttystr];
    [profile_header_ttystr]; profile_ttystrs; 
    [trials_header_ttystr]; trials_ttystr; 
    [success_ttystr]; [footer]]

(** Generate pprintable output (a {!Tty_str.t} list) from a
    {!Result.t} list. *)
let pprint_results results =
  let header =
    Tty_str.create ~fmt:Tty_str.Bold "---------------- Execution Results\n" in
  let results_output = List.map marshal_result results in
  let results_ttystrs = List.flatten results_output in
  List.flatten [[header]; results_ttystrs]
