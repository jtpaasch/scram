(** Implements {!Execution}. *)

type t = {
  cmd: string;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  duration: float;
  stats: Ps.Stat.t list;
  num_stat_collections: int;
  avg_rss: int;
  min_rss: int;
  max_rss: int;
}

let cmd t = t.cmd
let stdout t = t.stdout
let stderr t = t.stderr
let exit_code t = t.exit_code
let duration t = t.duration
let stats t = t.stats
let num_stat_collections t = t.num_stat_collections
let avg_rss t = t.avg_rss
let min_rss t = t.min_rss
let max_rss t = t.max_rss

let strip_final_newline s =
  match String.length s with
  | 0 -> s
  | n ->
    match String.get s (n - 1) with
    | '\n' -> String.sub s 0 (n - 1)
    | _ -> s

let marshal_output buf =
  let raw_str = Ps.Buff.contents buf in
  let trimmed_str = strip_final_newline raw_str in
  match String.trim trimmed_str with
  | "" -> []
  | _ -> String.split_on_char '\n' trimmed_str

let rec sum_ints items acc =
  match items with
  | [] -> acc
  | hd :: tl -> sum_ints tl (acc + hd)

let calc_avg_rss stats =
  let rss's = List.map (Ps.Stat.rss) stats in
  let total_rss = sum_ints rss's 0 in
  let num_stat_collections = List.length stats in
  total_rss / num_stat_collections

let rec calc_min_rss stats acc =
  match stats with
  | [] -> acc
  | hd :: tl ->
    let rss = Ps.Stat.rss hd in
    let new_acc = match acc with
    | (-1) -> rss
    | _ -> acc in
    match rss < acc with
    | false -> calc_min_rss tl new_acc
    | true -> calc_min_rss tl rss

let rec calc_max_rss stats acc =
  match stats with
  | [] -> acc
  | hd :: tl ->
    let rss = Ps.Stat.rss hd in
    let new_acc = match acc with
    | (-1) -> rss
    | _ -> acc in
    match rss >= acc with
    | false -> calc_max_rss tl new_acc
    | true -> calc_max_rss tl rss

(** This function runs a shell command. It captures the command's exit
    code, stdout, stderr, and how long the command took to execute. It
    then returns an {!Execution.t} record which contains this information.

    Arguments:
    - A shell command (a string) to execute in a shell.

    Returns: an {!Execution.t} record. *)
let run cmd =
  let start_time = Unix.gettimeofday () in
  let exit_code, out_buf, err_buf, stats = Ps.Cmd.run cmd in
  let stop_time = Unix.gettimeofday () in
  let duration = stop_time -. start_time in
  let stdout = marshal_output out_buf in
  let stderr = marshal_output err_buf in
  let num_stat_collections = List.length stats in
  let avg_rss = calc_avg_rss stats in
  let min_rss = calc_min_rss stats (-1) in
  let max_rss = calc_max_rss stats (-1) in
  {
    cmd; stdout; stderr; exit_code; duration; stats;
    num_stat_collections; avg_rss; min_rss; max_rss;
  }
