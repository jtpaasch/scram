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

let build token data cmd output stdout stderr exit_code success trials =
  { token; data; cmd; output; stdout; stderr; exit_code; success; trials }

let rec is_successful results =
  match results with
  | [] -> true
  | hd :: tl ->
    match Success.is_successful hd.success with
    | false -> false
    | true -> is_successful tl

(** Helps construct a [Node.Blank] result. *)
module Blank = struct

  (** Takes a list of blank lines taken from a source file,
      and constructs a [Blank] result. *)
  let create data = build
    Token_type.Blank data None None
    None None None (Success.create true Success.NA) None

end

(** Helps construct a [Node.Comment] result. *)
module Comment = struct

  (** Takes a list of comment lines taken from a source file,
      and constructs a [Comment] result. *)
  let create data = build
    Token_type.Comment data None None
    None None None (Success.create true Success.NA) None

end

(** Helps construct a [Node.Code] result. *)
module Code = struct

  (** Takes lines of code/output from a source file,
      and constructs a [Code] result. *)
  let create data cmd output =
    let res = Execution.run cmd in
    let success = Success.get_success 
      res.Execution.exit_code output 
      res.Execution.stdout res.Execution.stderr in
    build
      Token_type.Code data (Some cmd) (Some output)
      (Some res.Execution.stdout) (Some res.Execution.stderr) 
      (Some res.Execution.exit_code) success None

end

(** Helps construct a [Node.ProfiledCode] result. *)
module ProfiledCode = struct

  (** Takes lines of code/output from a source file,
      and constructs a [ProfiledCode] result. *)
  let create data cmd output =
    let trials = Trials.run cmd 5 in
    let res = Trials.last trials in
    let success = Success.get_success 
      res.Execution.exit_code output 
      res.Execution.stdout res.Execution.stderr in
    build
      Token_type.ProfiledCode data (Some cmd) (Some output)
      (Some res.Execution.stdout) (Some res.Execution.stderr) 
      (Some res.Execution.exit_code) success (Some trials)

end

(** Helps construct a [Node.Stats] result. *)
module Stats = struct

  let create data = build
    Token_type.Stats data None None
    None None None (Success.create true Success.NA) None

end

(** Helps construct a [Node.Diff] result. *)
module Diff = struct

  let create data = build
    Token_type.Diff data None None
    None None None (Success.create true Success.NA) None

end
