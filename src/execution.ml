(** Implements {!Execution}. *)

type t = {
  cmd: string;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  duration: float;
}

let cmd t = t.cmd
let stdout t = t.stdout
let stderr t = t.stderr
let exit_code t = t.exit_code
let duration t = t.duration

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

(** This function runs a shell command. It captures the command's exit
    code, stdout, stderr, and how long the command took to execute. It
    then returns an {!Execution.t} record which contains this information.
    Arguments:
    - A shell command (a string) to execute in a shell.
    Returns: an {!Execution.t} record. *)
let run cmd =
  let start_time = Unix.gettimeofday () in
  let exit_code, out_buf, err_buf = Ps.Cmd.run cmd in
  let stop_time = Unix.gettimeofday () in
  let duration = stop_time -. start_time in
  let stdout = marshal_output out_buf in
  let stderr = marshal_output err_buf in
  { cmd; stdout; stderr; exit_code; duration }
