(** Implements {!Trials}. *)

type t = {
  executions: Execution.t list;
  avg_time: float;
  total_time: float;
  num_trials: int;
  avg_num_stat_collections: int;
  avg_rss: int;
  avg_max_rss: int;
  avg_min_rss: int;
  max_rss: int;
  min_rss: int;
}

let executions t = t.executions
let avg_time t = t.avg_time
let total_time t = t.total_time
let num_trials t = t.num_trials

let avg_num_stat_collections t = t.avg_num_stat_collections
let avg_rss t = t.avg_rss
let avg_min_rss t = t.avg_min_rss
let avg_max_rss t = t.avg_max_rss
let min_rss t = t.min_rss
let max_rss t = t.max_rss

let last t =
  let execs = executions t in
  let num_execs = List.length execs in
  List.nth execs (num_execs - 1)

let nth t i =
  let execs = executions t in
  List.nth execs i

let rec sum_floats items acc =
  match items with
  | [] -> acc
  | hd :: tl -> sum_floats tl (acc +. hd)

let rec sum_ints items acc =
  match items with
  | [] -> acc
  | hd :: tl -> sum_ints tl (acc + hd)

let calc_total_time execs =
  let times = List.map (fun x -> Execution.duration x) execs in
  sum_floats times 0.0

let calc_avg_time execs total_time =
  let num_trials = List.length execs in
  total_time /. (float_of_int num_trials)

let calc_avg_int_field execs getter =
  let num_trials = List.length execs in
  let all_values = List.map getter execs in
  let total = sum_ints all_values 0 in
  total / num_trials

let rec find_int_by_cmp l getter comparer acc =
  match l with
  | [] -> acc
  | hd :: tl ->
    let value = getter hd in
    let new_acc = match acc with
    | (-1) -> value
    | _ -> acc in
    match comparer value new_acc with
    | true -> find_int_by_cmp tl getter comparer value
    | false -> find_int_by_cmp tl getter comparer new_acc

let rec do_executions cmd counter acc =
  match counter > 0 with
  | true ->
    begin
      let res = Execution.run cmd in
      let new_counter = counter - 1 in
      let new_acc = List.append acc [res] in
      do_executions cmd new_counter new_acc
    end
  | false -> acc

(** Run/create a {!Trials.t} record.

    Arguments:
    - A command (a string) to execute in a shell.
    - The number of times (int) to run the command.

    Returns: a {!Trials.t} record. *)
let run cmd num_trials =
  let execs = do_executions cmd num_trials [] in
  let total_time = calc_total_time execs in
  let avg_time = calc_avg_time execs total_time in
  let avg_num_stat_collections =
    calc_avg_int_field execs Execution.num_stat_collections in
  let avg_rss = calc_avg_int_field execs Execution.avg_rss in
  let avg_min_rss = calc_avg_int_field execs Execution.min_rss in
  let avg_max_rss = calc_avg_int_field execs Execution.max_rss in
  let min_rss = find_int_by_cmp execs Execution.min_rss (<=) (-1) in
  let max_rss = find_int_by_cmp execs Execution.max_rss (>=) (-1) in
  {
    executions = execs; avg_time; total_time; num_trials;
    avg_num_stat_collections; avg_rss; avg_min_rss; avg_max_rss;
    min_rss; max_rss;
  }
