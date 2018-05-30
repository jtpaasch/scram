(** A utility for printing test results. *)

(** Raised when a result is invalid. *)
exception InvalidResult of string

(** Generates pprintable output of an executed test.
    There are three arguments:
    - A string title for the test.
    - A list of {!Result.t} nodes for the body of the test.
    - A boolean representing whether the test succeeded or failed.
    This returns a {!Tty_str.t} list. *)
val pprint : string -> Result.t list -> bool -> Tty_str.t list
