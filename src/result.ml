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
  cmd: string;
  output: string list;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  success: bool * status;
  diff: string list
}

exception InvalidNode of string

let build token data cmd output stdout stderr exit_code success diff =
  { token; data; cmd; output; stdout; stderr; exit_code; success; diff }

let string_of_status s =
  match s with
  | NA -> "N/a"
  | NonZeroExit -> "Non-zero exit code"
  | ZeroExit -> "Exited with a 0 exit code"
  | UnexpectedOutput -> "Unexpected output"
  | ExpectedOutput -> "Output was as expected"

let string_of t =
  let sep_str = "|.....................\n" in
  let token_str =
    Printf.sprintf "| Token type: %s\n" (Token_type.string_of t.token) in
  let data_lines = List.map (Printf.sprintf "| - %s\n") t.data in
  let output_lines = List.map (Printf.sprintf "| - %s\n") t.output in
  let stdout_lines = List.map (Printf.sprintf "| - %s\n") t.stdout in
  let stderr_lines = List.map (Printf.sprintf "| - %s\n") t.stderr in
  let passed = match t.success with
    | (pass, stat) -> 
      Printf.sprintf "| Success: %b (%s)\n" pass (string_of_status stat) in
  Printf.sprintf "%s%s%s%s%s%s%s%s%s%s%s%s%s|"
    sep_str
    token_str
    "| Lines of data:\n"
    (String.concat "" data_lines)
    (Printf.sprintf "| Cmd: %s\n" t.cmd)
    "| Expected output:\n"
    (String.concat "" output_lines)
    "| Actual stdout:\n"
    (String.concat "" stdout_lines)
    "| Actual stderr:\n"
    (String.concat "" stderr_lines)
    (Printf.sprintf "| Exit code: %d\n" t.exit_code)
    passed

let rec is_successful results =
  match results with
  | [] -> true
  | hd :: tl ->
    match hd.success with
    | (false, _) -> false
    | (true, _) -> is_successful tl

(** Helps construct a [Node.Blank] result. *)
module Blank = struct

  (** Takes a list of blank lines taken from a source file,
      and constructs a [Blank] result. *)
  let create data = build Token_type.Blank data "" [] [] [] 0 (true, NA) []

end

(** Helps construct a [Node.Comment] result. *)
module Comment = struct

  (** Takes a list of comment lines taken from a source file,
      and constructs a [Comment] result. *)
  let create data = build Token_type.Comment data "" [] [] [] 0 (true, NA) []

end

(** Helps construct a [Node.Code] result. *)
module Code = struct

  let strip_final_newline s =
    match String.length s with
    | 0 -> s
    | n ->
      match String.get s (n - 1) with
      | '\n' -> String.sub s 0 (n - 1)
      | _ -> s

  (** Gathers the contents of an output buffer. *)
  let marshal_output buf =
    let raw_str = Ps.Buff.contents buf in
    let trimmed_str = strip_final_newline raw_str in
    match String.trim trimmed_str with
    | "" -> []
    | _ -> String.split_on_char '\n' trimmed_str

  (** Check if the expected output matches stdout or stderr. *)
  let check_output output out_buf err_buf =
    let expected_output = String.concat "\n" output in
    let actual_stdout = Ps.Buff.contents out_buf in
    let actual_stderr = Ps.Buff.contents err_buf in
    let stdout_is_match = Matcher.cmp expected_output actual_stdout in
    let stderr_is_match = Matcher.cmp expected_output actual_stderr in
    stdout_is_match || stderr_is_match

  (** Check if the code is successful. *)
  let is_successful exit_code output out_buf err_buf =
    match exit_code = 0 with
    | false -> (false, NonZeroExit)
    | true ->
      match List.length output > 0 with
      | false -> (true, ZeroExit)
      | true -> 
        match check_output output out_buf err_buf with
        | true -> (true, ExpectedOutput)
        | false -> (false, UnexpectedOutput)

  (** Takes a list of data (raw command lines taken from a source file),
      a [cmd] (a string command to execute), and a list of expected
      [output] lines (a list of strings). It executes the [cmd] and
      constructs a [Code] result. *)
  let create data cmd output =
    let exit_code, out_buf, err_buf = Ps.Cmd.run cmd in
    let stdout = marshal_output out_buf in
    let stderr = marshal_output err_buf in
    let passed = is_successful exit_code output out_buf err_buf in
    build
      Token_type.Code data cmd output
      stdout stderr exit_code
      passed []

end
