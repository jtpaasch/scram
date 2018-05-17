(** Implements {!Result}. *)

type t = {
  token: Token_type.t;
  data: string list;
  cmd: string;
  output: string list;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  success: bool;
  diff: string list
}

let build token data cmd output stdout stderr exit_code success diff =
  { token; data; cmd; output; stdout; stderr; exit_code; success; diff }

let string_of_data data =
  match List.length data > 0 with
  | false -> ""
  | true ->
    let data_str = List.map (fun l -> Printf.sprintf "| %s" l) data in
    Printf.sprintf "%s" (String.concat "\n" data_str)

let string_of_output output =
  match List.length output > 0 with
  | false -> ""
  | true ->
    let result = List.map (Printf.sprintf "|   %s") output in
    Printf.sprintf "%s\n" (String.concat "\n" result)

let string_of_stdout stdout =
  match List.length stdout > 0 with
  | false -> ""
  | true ->
    let result = List.map (Printf.sprintf "|   1> %s") stdout in
    Printf.sprintf "%s\n" (String.concat "\n" result)

let string_of_stderr stderr =
  match List.length stderr > 0 with
  | false -> ""
  | true ->
    let result = List.map (Printf.sprintf "|   2> %s") stderr in
    Printf.sprintf "%s\n" (String.concat "\n" result)

let string_of_exit_code exit_code =
  match exit_code with
  | -1 -> ""
  | n -> Printf.sprintf "|   Exit code: %d\n" exit_code

let string_of_diff diff =
  match List.length diff > 0 with
  | false -> ""
  | true ->
    let result = List.map (Printf.sprintf "|   +- %s") diff in
    Printf.sprintf "%s" (String.concat "\n" result)

let string_of t =
  match t.token with
  | Token_type.Blank -> Printf.sprintf "%s" (string_of_data t.data)
  | Token_type.Comment -> Printf.sprintf "%s" (string_of_data t.data)
  | Token_type.Code -> 
    Printf.sprintf "%s\n%s%s%s%s"
      (string_of_data t.data)
      (string_of_stdout t.stdout) (string_of_stderr t.stderr)
      (string_of_exit_code t.exit_code) (string_of_diff t.diff)
  | Token_type.Output -> raise (Failure "Cannot stringify output node.")

(** Helps construct a [Node.Blank] result. *)
module Blank = struct

  (** Takes a list of blank lines taken from a source file,
      and constructs a [Blank] result. *)
  let create data = build Token_type.Blank data "" [] [] [] 0 true []

end

(** Helps construct a [Node.Comment] result. *)
module Comment = struct

  (** Takes a list of comment lines taken from a source file,
      and constructs a [Comment] result. *)
  let create data = build Token_type.Comment data "" [] [] [] 0 true []

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

  (** Takes a list of data (raw command lines taken from a source file),
      a [cmd] (a string command to execute), and a list of expected
      [output] lines (a list of strings). It executes the [cmd] and
      constructs a [Code] result. *)
  let create data cmd output =
    let exit_code, out_buf, err_buf = Ps.Cmd.run cmd in
    let stdout = marshal_output out_buf in
    let stderr = marshal_output err_buf in
    build
      Token_type.Code data cmd output
      stdout stderr exit_code
      false ["something"; "foo"; "bar"]

end
