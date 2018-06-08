(** A utility that packages up a pass/fail (bool) and a reason. *) 

(** Reasons why results succeed or fail. *)
type status =
  | NA
  | NonZeroExit
  | ZeroExit
  | UnexpectedOutput
  | ExpectedOutput

(** A {!Success.t} record carries with it two things:
    - A [bool] indicating whether its success or failure.
    - A [status] indicating why it succeeded or failed. *)
type t = {
  passed: bool;
  reason: status;
}

(** Creates a {!Success.t} record.

    Arguments:
    - A [bool] indicating success or failure.
    - A [status].

    Returns: a {!Success.t} record. 

    For example, [create true status.ZeroExit] creates a {!Success.t}
    record which represents that a result is a success because it had
    a zero exit code. 

    Note: this is a low-level function for creating {!Success.t} records.
    The [get_success] function below should be used for creating success 
    records for commands. *)
val create : bool -> status -> t

(** Get the success (the [bool]) value of a {!Success.t} record. *)
val is_successful : t -> bool

(** Get the reason why (the [status]) of a {!Success.t} record. *)
val why : t -> status

(** Get a string representation of a [status]. *)
val string_of_why : status -> string

(** Check if a command is successful, and return a {!Success.t}
    record representing	that.

    Arguments:
    - The exit code (an	int) of	a command.
    - Any expected output (a list of zero or more strings).
    - Any captured stdout from the command (a list of zero or more strings).
    - Any captured stderr from the command (a list of zero or more strings).

    Returns: a {!Success.t} record. *)
val get_success :
  int ->
  string list ->
  string list ->
  string list ->
  t
