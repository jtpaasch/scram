(** Implements {!Execution_printer}. *)

let pprint_output title data = 
  let output =
    match List.length data with
    | 0 -> ["- - - None captured"]
    | _ -> List.map (Printf.sprintf "- - - %s") data in
  List.append [title] output

let pprint_stat stat =
  let header = "- - - Stat collection:" in
  let pid = Printf.sprintf "- - - - PID: %d" (Ps.Stat.pid stat) in
  let rss = Printf.sprintf "- - - - RSS: %dKb" (Ps.Stat.rss stat) in
  [header; pid; rss]

let pprint_stats data =
  let title = "- - Stats:" in
  let stats = List.map pprint_stat data in
  let flattened_stats = List.flatten stats in
  List.append [title] flattened_stats

let pprint exe =
  let cmd = Execution.cmd exe in
  let stdout = Execution.stdout exe in
  let stderr = Execution.stderr exe in
  let exit_code = Execution.exit_code exe in
  let duration = Execution.duration exe in
  let stats = Execution.stats exe in
  let num_stats = Execution.num_stat_collections exe in
  let avg_rss = Execution.avg_rss exe in
  let min_rss = Execution.min_rss exe in
  let max_rss = Execution.max_rss exe in

  let header_str = "- Execution:" in
  let cmd_str = Printf.sprintf "- - Command: %s" cmd in
  let exit_code_str = Printf.sprintf "- - Exit code: %d" exit_code in
  let duration_str = Printf.sprintf "- - Running time: %.3fs" duration in
  let num_stats_str = 
    Printf.sprintf "- - Num stat collections: %d" num_stats in
  let avg_rss_str = Printf.sprintf "- - Avg RSS: %dKb" avg_rss in
  let min_rss_str = Printf.sprintf "- - Min RSS: %dKb" min_rss in
  let max_rss_str = Printf.sprintf "- - Max RSS: %dKb" max_rss in

  let header = [
    header_str; cmd_str; exit_code_str; duration_str;
    num_stats_str; avg_rss_str; min_rss_str; max_rss_str] in
  let stdout_strs = pprint_output "- - Stdout:" stdout in
  let stderr_strs = pprint_output "- - Stderr:" stderr in
  let stats_strs = pprint_stats stats in

  List.flatten [header; stdout_strs; stderr_strs; stats_strs;]
