(** Implements {!Success}. *)

type status =
  | NA
  | NonZeroExit
  | ZeroExit
  | UnexpectedOutput
  | ExpectedOutput

type t = {
  passed: bool;
  reason: status;
}

(** Creates a {!Success.t} record.

    Arguments:
    - A [bool] indicating success or failure.
    - A [status] status.

    Returns: a {!Success.t} record. *)
let create passed reason = { passed; reason }

let is_successful t = t.passed

let why t = t.reason

let string_of_why s =
  match s with
  | NA -> "N/a"
  | NonZeroExit -> "Non-zero exit code"
  | ZeroExit -> "Exited with a 0 exit code"
  | UnexpectedOutput -> "Unexpected output"
  | ExpectedOutput -> "Output was as expected"

(** Check if the expected output matches stdout or stderr. *)
let check_output output out err =
  let expected_output = String.concat "\n" output in
  let actual_stdout = String.concat "\n" out in
  let actual_stderr = String.concat "\n" err in
  let stdout_is_match = Matcher.cmp expected_output actual_stdout in
  let stderr_is_match = Matcher.cmp expected_output actual_stderr in
  stdout_is_match || stderr_is_match

(** Check if a command is successful, and return a {!Success.t}
    record representing that.

    Arguments:
    - The exit code (an int) of a command.
    - Any expected output (a list of zero or more strings).
    - Any captured stdout from the command (a list of zero or more strings).
    - Any captured stderr from the command (a list of zero or more strings).

    Returns: a {!Success.t} record. *)
let get_success exit_code output out err =
  match exit_code = 0 with
  | false -> create false NonZeroExit
  | true ->
    match List.length output > 0 with
    | false -> create true ZeroExit
    | true ->
      match check_output output out err with
      | true -> create true ExpectedOutput
      | false -> create false UnexpectedOutput
