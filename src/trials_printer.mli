(** Utility for pretty printing trials. *)
  
(** Generate a string list from a {!Trials.t} record.

    Arguments:
    - A {!Trials.t} record (e.g., like one collected by a {!Result.t}.

    Returns: a string list.

    For example, suppose [trials] is a trial collected by a {!Result.t}
    node. Then [pprint trials] will return a list of strings that can
    be printed to a TTY or other target. *)
val pprint : Trials.t -> string list
