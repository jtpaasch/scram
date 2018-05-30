(** Implements {!Printer}. *)

exception InvalidResult of string

let tty_strings_of lines = List.map Tty_str.create lines

let lines_of_comments r = tty_strings_of (Result.data r)
let lines_of_blanks r = tty_strings_of (Result.data r)

let lines_of_code r =
  let raw_data =
    List.map (Tty_str.create ~fmt:Tty_str.Bold) (Result.data r) in
  let out =
    match Result.stdout r with
    | None -> []
    | Some x ->
      List.map (fun s ->
        let msg = Printf.sprintf "  1> %s" s in
	Tty_str.create msg
      ) x
    in
  let err =
    match Result.stderr r with
    | None -> []
    | Some x ->
      List.map (fun s ->
        let msg = Printf.sprintf "  2> %s" s in
	Tty_str.create msg
      ) x
    in
  let exit_code =
    match Result.exit_code r with
    | None -> raise (InvalidResult "Exit code cannot be empty")
    | Some x ->
      let msg = Printf.sprintf "  [%d]" x in
      let msg_ttystr = Tty_str.create msg in
      [msg_ttystr] in
  let is_success = Success.is_successful (Result.success r) in
  let why = Success.why (Result.success r) in
  let fmt, pass, reason = match (is_success, why) with
    | (true, stat) -> (Tty_str.Green, "OK", Success.string_of_why stat)
    | (false, stat) -> (Tty_str.Red, "FAILED", Success.string_of_why stat)
    in
  let msg = Printf.sprintf "  ==> %s (%s)" pass reason in
  let msg_ttystr = Tty_str.create ~fmt:fmt msg in
  let pass_str = [msg_ttystr] in
  List.flatten [raw_data; out; err; exit_code; pass_str]

let lines_of_profiled_code r = lines_of_code r

let get_profiled_nodes items =
  List.filter (fun x -> match Result.token x with
    | Token_type.ProfiledCode -> true
    | _ -> false
  ) items

let rec collect_stats nodes counter acc =
  match nodes with
  | [] -> acc
  | hd :: tl ->
    let trials = match Result.trials hd with
    | Some x -> x
    | None ->
      let msg = "ProfiledCode node cannot have empty trial" in
      raise (InvalidResult msg) in
    let new_counter = counter + 1 in
    let avg = Trials.avg trials in
    let total = Trials.total trials in
    let num_trials = Trials.num_trials trials in
    let line = [
      Printf.sprintf "%d" new_counter;
      Printf.sprintf "%.4f" avg;
      Printf.sprintf "%.4f" total;
      Printf.sprintf "%d" num_trials;
    ] in
    let new_acc = List.append acc [line] in
    collect_stats tl new_counter new_acc

let lines_of_stats r processed =
  let header =
    List.map (Tty_str.create ~fmt:Tty_str.Bold) (Result.data r) in
  let profiled_nodes = get_profiled_nodes processed in
  let stats = collect_stats profiled_nodes 0 [] in
  let header_col = ["Id"; "Avg time"; "Total time"; "Num trials"] in
  let rows = List.append [header_col] stats in
  let table_rows = Tty_table.create rows in
  let tty_table_rows =
    List.map (fun s ->
      Tty_str.create (Printf.sprintf "  %s" s)
    ) table_rows in 
  List.append header tty_table_rows

let rec collect_output nodes counter acc =
  match nodes with
  | [] -> acc
  | hd :: tl ->
    let cmd = match Result.cmd hd with
    | Some x -> x
    | None ->
      let msg = "ProfiledCode node cannot have no cmd" in
      raise (InvalidResult msg) in
    let stdout = match Result.stdout hd with
    | Some x -> x
    | None ->
      let msg = "ProfiledCode node cannot have no stdout" in
      raise (InvalidResult msg) in
    let stderr = match Result.stderr hd with
    | Some x -> x
    | None ->
      let msg = "ProfiledCode node cannot have no stderr" in
      raise (InvalidResult msg) in
    let new_counter = counter + 1 in
    let stdout_lines = List.map (Printf.sprintf "1> %s") stdout in
    let stderr_lines = List.map (Printf.sprintf "2> %s") stderr in
    let all_lines = List.append stdout_lines stderr_lines in
    let cmd_str = match (String.length cmd) < 12 with
    | true -> String.sub cmd 0 (String.length cmd) 
    | false ->
      let cmd_short = String.sub cmd 0 12 in
      Printf.sprintf "%s..." cmd_short in
    let header = Printf.sprintf "---------------- [ %s ]" cmd_str in
    let all_output = List.append [header] all_lines in
    let new_acc = List.append acc all_output in
    collect_output tl new_counter new_acc

let lines_of_diff r processed =
  let header =
    List.map (Tty_str.create ~fmt:Tty_str.Bold) (Result.data r) in
  let profiled_nodes = get_profiled_nodes processed in
  let lines = collect_output profiled_nodes 0 [] in
  let all_lines = List.append lines [""] in
  let tty_lines =
    List.map (fun s -> Tty_str.create (Printf.sprintf "  %s" s)) all_lines in
  List.append header tty_lines

let rec build_result nodes processed acc =
  match nodes with
  | [] -> acc
  | hd :: tl ->
    match Result.token hd with
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
    | Token_type.Diff ->
      let output = lines_of_diff hd processed in
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

(** Generate a {!Tty_str.t} from a {!Result.t} list. *)
let pprint title results success =
  let header = test_header title in
  let body = test_body results in
  let footer = test_footer success in
  List.flatten [header; body; footer]
