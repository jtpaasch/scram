(** Represents the execution of a command. An {!Execution.t} record is
    constructed by running a shell command, and capturing information
    about it like its exit code, stdout, and stderr. This information
    is stored in the {!Execution.t} record, so it can be read back later. *)

type t = {
  cmd: string;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  duration: float;
}

(** Get the command string of an execution. *)
val cmd : t -> string

(** Get the stdout captured from an execution. *)
val stdout : t -> string list

(** Get the stderr captured from an execution. *)
val stderr : t -> string list

(** Get the exit code captured from an execution. *)
val exit_code : t -> int

(** Get how long an execution took. *)
val duration : t -> float

(** This function runs a shell command. It captures the command's exit
    code, stdout, stderr, and how long the command took to execute. It
    then returns an {!Execution.t} record which contains this information.
    Arguments:
    - A shell command (a string) to execute in a shell.
    Returns: an {!Execution.t} record. *)
val run : string -> t
