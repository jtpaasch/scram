(** Implements {!Result}. *)

type status =
  | NA
  | NonZeroExit
  | ZeroExit
  | UnexpectedOutput
  | ExpectedOutput

type t = {
  token: Token_type.t;
  data: string list;
  cmd: string option;
  output: string list option;
  stdout: string list option;
  stderr: string list option;
  exit_code: int option;
  success: Success.t;
  trials: Trials.t option;
}

exception InvalidNode of string

(** Builds a result record.

    Arguments:
    - A {!Token_type.t} type.
    - A list of raw content/data (the original strings taken from
    a source file).
    - An optional command (a string) to execute in a shell.
    - An optional list of strings the command is expected to output.
    - An optional list of strings captured from the command's stdout.
    - An optional list of strings captured from the command's stderr.
    - An optional exit code (an int) captured from the command.
    - A {!Success.t} record, indicating if the result succeeded.
    - An optional {!Trials.t} record, if the result was profiled.

    Returns: A {!Result.t} record.

    Note: this is a general function for building {!Result.t} records. There
    are helper modules below for creating particular types of results. *)
let build token data cmd output stdout stderr exit_code success trials =
  { token; data; cmd; output; stdout; stderr; exit_code; success; trials }

let token t = t.token
let data t = t.data
let cmd t = t.cmd
let output t = t.output
let stdout t = t.stdout
let stderr t = t.stderr
let exit_code t = t.exit_code
let success t = t.success
let trials t = t.trials

let rec is_successful results =
  match results with
  | [] -> true
  | hd :: tl ->
    match Success.is_successful hd.success with
    | false -> false
    | true -> is_successful tl

(** Helps construct {!Token_type.t.Blank} results. *)
module Blank = struct

  (** Creates a {!Result.t} node of type {!Token_type.t.Blank}.

      Arguments:
      - A list of blank lines (strings) from the original file.

      Returns: a {!Result.t} record. *)
  let create data = build
    Token_type.Blank data None None
    None None None (Success.create true Success.NA) None

end

(** Helps construct {!Token_type.t.Comment} results. *)
module Comment = struct

  (** Creates a {!Result.t} node of type {!Token_type.t.Comment}.

      Arguments:
      - A list of blank lines (strings) from the original file.

      Returns: a {!Result.t} record. *)
  let create data = build
    Token_type.Comment data None None
    None None None (Success.create true Success.NA) None

end

(** Helps construct {!Token_type.t.Code} results. *)
module Code = struct

  (** Creates a {!Result.t} node of type {!Token_type.t.Code}.

      Arguments:
      - A list of the raw contents/data (i.e., lines (strings) from
      the original file).
      - A command (a string) to execute in a shell.
      - Any output (a list of strings) the command is expected to produce.

      Returns: a {!Result.t} record. *)
  let create data cmd output =
    let res = Execution.run cmd in
    let success = Success.get_success 
      (Execution.exit_code res) output 
      (Execution.stdout res) (Execution.stderr res) in
    build
      Token_type.Code data (Some cmd) (Some output)
      (Some (Execution.stdout res)) (Some (Execution.stderr res)) 
      (Some (Execution.exit_code res)) success None

end

(** Helps construct {!Token_type.t.ProfiledCode} results. *)
module ProfiledCode = struct

  (** Creates a {!Result.t} node of type {!Token_type.t.ProfiledCode}.
      Profiled code is just like code, except the command is profiled.
      That is, it is executed a number of times (time trials), and the
      average running time is computed.

      Arguments:
      - A list of the raw contents/data (i.e., lines (strings) from
      the original file).
      - A command (a string) to execute in a shell.
      - Any output (a list of strings) the command is expected to produce.

      Returns: a {!Result.t} record. *)
  let create data cmd output num_trials =
    let trials = Trials.run cmd num_trials in
    let res = Trials.last trials in
    let success = Success.get_success 
      (Execution.exit_code res) output 
      (Execution.stdout res) (Execution.stderr res) in
    build
      Token_type.ProfiledCode data (Some cmd) (Some output)
      (Some (Execution.stdout res)) (Some (Execution.stderr res)) 
      (Some (Execution.exit_code res)) success (Some trials)

end

(** Helps construct {!Token_type.t.Stats} results. *)
module Stats = struct

  (** Creates a {!Result.t} node of type {!Token_type.t.Stats}.

      Arguments:
      - A list of the raw contents/data (i.e., lines (strings) from
      the original file). This should really just contain
      the one string ["#stats"].

      Returns: a {!Result.t} record. *)
  let create data = build
    Token_type.Stats data None None
    None None None (Success.create true Success.NA) None

end

(** Helps construct {!Token_type.t.Diff} results. *)
module Diff = struct

  (** Creates a {!Result.t} node of type {!Token_type.t.Diff}.

      Arguments:
      - A list of the raw contents/data (i.e., lines (strings) from
      the original file). This should really just contain
      the one string ["#diff"].

      Returns: a {!Result.t} record. *)
  let create data = build
    Token_type.Diff data None None
    None None None (Success.create true Success.NA) None

end
