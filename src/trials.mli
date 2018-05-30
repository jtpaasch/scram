(** Represents a set of profiled code executions. *)

type t = {
  executions: Execution.t list;
  avg_time: float;
  total_time: float;
  num_trials: int;
}

val exe : t -> Execution.t list
val avg : t -> float
val total : t -> float
val num_trials : t -> int

val last : t -> Execution.t

val run : string -> int -> t
