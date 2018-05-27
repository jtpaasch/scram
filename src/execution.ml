(** Implements {!Execution}. *)

type t = {
  cmd: string;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  duration: float;
}

let strip_final_newline s =
  match String.length s with
  | 0 -> s
  | n ->
    match String.get s (n - 1) with
    | '\n' -> String.sub s 0 (n - 1)
    | _ -> s

(** Gathers the contents of an output buffer. *)
let marshal_output buf =
  let raw_str = Ps.Buff.contents buf in
  let trimmed_str = strip_final_newline raw_str in
  match String.trim trimmed_str with
  | "" -> []
  | _ -> String.split_on_char '\n' trimmed_str

let run cmd =
  let start_time = Unix.gettimeofday () in
  let exit_code, out_buf, err_buf = Ps.Cmd.run cmd in
  let stop_time = Unix.gettimeofday () in
  let duration = stop_time -. start_time in
  let stdout = marshal_output out_buf in
  let stderr = marshal_output err_buf in
  { cmd; stdout; stderr; exit_code; duration }
