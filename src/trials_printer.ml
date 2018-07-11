(** Implements {!Trials_printer}. *)

let pad s =
  let total_width = 48 in
  let len_s = String.length s in
  let len_pad = (total_width - len_s) - 5 in
  let padding = String.make len_pad '-' in
  String.concat "" ["--- "; s; " "; padding]

let pprint trials =
  let num_trials = Trials.num_trials trials in
  let avg_time = Trials.avg_time trials in
  let total_time = Trials.total_time trials in
  let executions = Trials.executions trials in
  let avg_num_stats = Trials.avg_num_stat_collections trials in
  let avg_rss = Trials.avg_rss trials in
  let avg_min_rss = Trials.avg_min_rss trials in
  let avg_max_rss = Trials.avg_max_rss trials in
  let min_rss = Trials.min_rss trials in
  let max_rss = Trials.max_rss trials in

  let num_trials_str = Printf.sprintf "- Number of trials: %d" num_trials in
  let avg_time_str = Printf.sprintf "- Avg running time: %.3fs" avg_time in
  let total_time_str = Printf.sprintf "- Total time: %.3fs" total_time in
  let avg_num_stats_str =
    Printf.sprintf "- Avg num stat collections: %d" avg_num_stats in
  let avg_rss_str = Printf.sprintf "- Avg RSS: %dKb" avg_rss in
  let avg_min_rss_str = Printf.sprintf "- Avg min RSS: %dKb" avg_min_rss in
  let avg_max_rss_str = Printf.sprintf "- Avg max RSS: %dKb" avg_max_rss in
  let min_rss_str = Printf.sprintf "- Min RSS: %dKb" min_rss in
  let max_rss_str = Printf.sprintf "- Max RSS: %dKb" max_rss in

  let header = [
    num_trials_str; avg_time_str; total_time_str;
    avg_num_stats_str; avg_rss_str; avg_min_rss_str; avg_max_rss_str;
    min_rss_str; max_rss_str;]
    in

  let execs_strs = List.map Execution_printer.pprint executions in
  let output = List.flatten execs_strs in

  List.append header output
