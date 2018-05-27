(** Represents an execution of a command. *)

type t = {
  cmd: string;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  duration: float;
}

(** Takes a string command to execute, and returns
    a triple of (i) the exit code, (ii) a list of
    lines captured from stdout, and (iii) a list
    of lines captured from stderr. *)
val run : string -> t
