(** Represents a set of profiled code executions. 

    A command is executed multiple times (these are the trials),
    and an average running time is computed. Additionally, as each
    execution occurs, certain execution stats like the resident set
    size are collected and averaged too. All of this is packaged up 
    packaged up into a {!Trials.t} record.

    To run a trial, use the [run] function. For example:

    {[
      run "echo hello" 5
    ]}

    That will profile the command [echo hello] (by running five trials).
    It will then package up the information it computes, and return it
    all in a {!Trials.t} instance.

    Trials are created by the {!Result.ProfiledCode.create} function. *)

(** A {!Trials.t} record carries with it information like the following:
    - A list of [executions].
      Each of these is one {!Execution.t} of the same command.
    - The [avg_time] (a float) of execution.
    - The [total_time] (as a float) of all executions.
    - The [num_trials] (an int), i.e., the number of executions.
    - The [max_rss] (an int), i.e., the max resident set size encountered
      across all executions in the trial.
    - And so on. *)
type t

(** Get the [executions] of a {!Trials.t} record. *)
val executions : t -> Execution.t list

(** Get the [avg_time] of a {!Trials.t} record. *)
val avg_time : t -> float

(** Get the [total_time] of a {!Trials.t} record. *)
val total_time : t -> float

(** Get the [num_trials] of a {!Trials.t} record. *)
val num_trials : t -> int

(** Get the [avg_num_stat_collections] of a {!Trials.t} record. *)
val avg_num_stat_collections : t -> int

(** Get the [num_trials] of a {!Trials.t} record. *)
val avg_rss : t -> int

(** Get the [num_trials] of a {!Trials.t} record. *)
val avg_max_rss : t -> int

(** Get the [num_trials] of a {!Trials.t} record. *)
val avg_min_rss : t -> int

(** Get the [num_trials] of a {!Trials.t} record. *)
val max_rss : t -> int

(** Get the [num_trials] of a {!Trials.t} record. *)
val min_rss : t -> int

(** Get the final execution in a {!Trials.t} record's [executions] list. *)
val last : t -> Execution.t

(** Get the nth execution in a {!Trials.t} record's [executions] list. *)
val nth : t -> int -> Execution.t

(** Run/create a {!Trials.t} record.

    Arguments:
    - A command (a string) to execute in a shell.
    - The number of times (int) to run the command.

    Returns: a {!Trials.t} record.

    For example, [run "echo hello" 5] will run the command [echo hello]
    five times, compute the average running time, and return that information
    in a {!Trials.t} record. *)
val run : string -> int -> t
