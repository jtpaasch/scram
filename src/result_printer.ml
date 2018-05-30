(** Implements {!Result_printer}. *)

let marshal_result r =
  let tk_type = Token_type.string_of (Result.token r) in
  let tk_type_str = Printf.sprintf "Token type: %s" tk_type in
  let tk_type_ttystr = Tty_str.create tk_type_str in

  let lines_header = Tty_str.create "Raw data:" in
  let lines = List.map (Printf.sprintf "- %s") (Result.data r) in
  let lines_ttystrs = List.map Tty_str.create lines in

  let cmd =
    match Result.cmd r with
    | None -> "Cmd: N/a"
    | Some x -> Printf.sprintf "Cmd: %s" x in
  let cmd_ttystr = Tty_str.create cmd in

  let output_header =
    match Result.output r with
    | None -> Tty_str.create "Expected output: N/a"
    | Some x -> Tty_str.create "Expected output:" in
  let output =
    match Result.output r with
    | None -> []
    | Some x ->
      match List.length x with
      | 0 -> ["- None specified"]
      | _ -> List.map (Printf.sprintf "- %s") x in
  let output_ttystrs = List.map Tty_str.create output in

  let stdout_header =
    match Result.stdout r with
    | None -> Tty_str.create "Captured stdout: N/a"
    | Some x -> Tty_str.create "Captured stdout:" in
  let stdout_data =
    match Result.stdout r with
    | None -> []
    | Some x ->
      match List.length x with
      | 0 -> ["- None captured"]
      | _ -> List.map (Printf.sprintf "- %s") x in
  let stdout_ttystrs = List.map Tty_str.create stdout_data in

  let stderr_header =
    match Result.stderr r with
    | None -> Tty_str.create "Captured stderr: N/a"
    | Some x -> Tty_str.create "Captured stderr:" in
  let stderr_data =
    match Result.stderr r with
    | None -> []
    | Some x ->
      match List.length x with
      | 0 -> ["- None captured"]
      | _ -> List.map (Printf.sprintf "- %s") x in
  let stderr_ttystrs = List.map Tty_str.create stderr_data in

  let exit_code =
    match Result.exit_code r with
    | None -> "Exit code: N/a"
    | Some x -> Printf.sprintf "Exit code: %d" x in
  let exit_code_ttystr = Tty_str.create exit_code in

  let pass, reason =
    let is_success = Success.is_successful (Result.success r) in
    let why = Success.why (Result.success r) in
    match (is_success, why) with
    | (true, stat) -> ("Passed", Success.string_of_why stat)
    | (false, stat) -> ("Failed", Success.string_of_why stat) in
  let success = Printf.sprintf "Test result: %s (%s)" pass reason in
  let success_ttystr = Tty_str.create success in

  let profile_header =
    match Result.trials r with
    | None -> "Profile: N/a"
    | Some x -> "Profile:" in
  let profile_header_ttystr = Tty_str.create profile_header in

  let profile =
    match Result.trials r with
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
    match Result.trials r with
    | None -> "Trials: N/a"
    | Some x -> "Trials:" in
  let trials_header_ttystr = Tty_str.create trials_header in

  let trials =
    match Result.trials r with
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

(** Generate a {!Tty_str.t} list from a {!Result.t} list. *)
let pprint results =
  let header =
    Tty_str.create ~fmt:Tty_str.Bold 
    "---------------- Execution Results\n" in
  let results_output = List.map marshal_result results in
  let results_ttystrs = List.flatten results_output in
  List.flatten [[header]; results_ttystrs]
