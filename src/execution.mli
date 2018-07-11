(** Represents the execution of a command. An {!Execution.t} record is
    constructed by running a shell command, and capturing information
    about it like its exit code, stdout, and stderr. This information
    is stored in the {!Execution.t} record, so it can be read back later. *)

(** Each execution record carries with it information captured from the
    execution of a shell command. E.g., it has the command (a string) that
    was executed, the exit code, stdout and stderr, and the like. *)	
type t

(** Get the command string of an execution. *)
val cmd : t -> string

(** Get the stdout captured from an execution. *)
val stdout : t -> string list

(** Get the stderr captured from an execution. *)
val stderr : t -> string list

(** Get the exit code captured from an execution. *)
val exit_code : t -> int

(** Get the stats captured from an execution. *)
val stats : t -> Ps.Stat.t list

(** Get the number times stats were collected durning an execution. *)
val num_stat_collections : t -> int

(** Get the avg resident set size of an execution. *)
val avg_rss : t -> int

(** Get the min resident set size of an execution. *)
val min_rss : t -> int

(** Get the max resident set size of an execution. *)
val max_rss : t -> int

(** Get how long an execution took. *)
val duration : t -> float

(** This function runs a shell command. It captures the command's exit
    code, stdout, stderr, and how long the command took to execute. It
    then returns an {!Execution.t} record which contains this information.

    Arguments:
    - A shell command (a string) to execute in a shell.

    Returns: an {!Execution.t} record.

    For example, [run "echo hello"] will execute the shell command
    ["echo hello"], and it will capture the command's exit code, stdout,
    stderr, etc. Then it will  package that up into an {!Execution.t}
    record, and return it. *)
val run : string -> t
