(** Implements {!Node}. *)

type t = {
  token : Token_type.t;
  data : string list;
  cmd : string option;
  output : string list option;
}


(** Builds an AST node.

    Arguments:
    - A {!Token_type.t}.
    - A list of strings of raw content/data (e.g., taken from
    the source file).
    - An optional command (a string) to execute.
    - An optional list of lines of output the command is expected
    to produce.

    Returns: A {!Node.t} record.

    Note: this is a general function for creating AST {!Node.t} records.
    There are helper modules below that make creating particular types
    of nodes easier. For instance, to create a node of blank lines, use
    {!Blank.create} below. *)
let build token data cmd output = { token; data; cmd; output }

let token t = t.token
let data t = t.data
let cmd t = t.cmd
let output t = t.output

module Blank = struct

  (** Constructs a {!Token_type.t.Blank} node.

      Arguments:
      - A list of blank lines (e.g., taken from a source file).

      Returns: A {!Node.t} record. *)
  let create data = build Token_type.Blank data None None

end

module Comment = struct

  (** Constructs a {!Token_type.t.Comment} node.

      Arguments:
      - A list of commentary lines (e.g., taken from a source file).

      Returns: A {!Node.t} record. *)
  let create data =
    build Token_type.Comment data None None

end

module Code = struct

  let extract_cmd s =
    let len = String.length s in
    match len > 6 with
    | false -> s
    | true -> String.sub s 6 (len - 6)

  let trim_prefixes lines =
    List.map (fun s -> String.sub s 4 ((String.length s) - 4)) lines

  let process data =
    match data with
    | [] -> ("", [])
    | hd :: [] -> (extract_cmd hd, [])
    | hd :: tl -> (extract_cmd hd, trim_prefixes tl)

  (** Constructs a {!Token_type.t.Code} node.

      Arguments:
      - A list of lines of code (e.g., taken from a source file).
      The first line should be a command to execute.
      The remaining lines can be lines of expected output.   

      Returns: A {!Node.t} record. *)
  let create data =
    let cmd, output = process data in
    build Token_type.Code data (Some cmd) (Some output)

end

module ProfiledCode = struct

  let extract_cmd s =
    let len = String.length s in
    match len > 7 with
    | false -> s
    | true -> String.sub s 7 (len - 7)

  let trim_prefixes lines =
    List.map (fun s -> String.sub s 4 ((String.length s) - 4)) lines

  let process data =
    match data with
    | [] -> ("", [])
    | hd :: [] -> (extract_cmd hd, [])
    | hd :: tl -> (extract_cmd hd, trim_prefixes tl)

  (** Constructs a {!Token_type.t.ProfiledCode} node.

      Arguments:
      - A list of lines of code (e.g., taken from a source file).
      The first line should be a command to execute.
      The remaining lines can be lines of expected output.   

      Returns: A {!Node.t} record. *)
  let create data =
    let cmd, output = process data in
    build Token_type.ProfiledCode data (Some cmd) (Some output)

end

module Stats = struct

  (** Constructs a {!Token_type.t.Stats} node.

      Arguments:
      - A list of raw source lines (e.g., taken from a source file)
      containing the [#stats] directive.

      Returns: A {!Node.t} record. *)
  let create data =
    build Token_type.Stats data None None

end

module Diff = struct

  (** Constructs a {!Token_type.t.Diff} node.

      Arguments:
      - A list of raw source lines (e.g., taken from a source file)
      containing the [#diff] directive.

      Returns: A {!Node.t} record. *)
  let create data =
    build Token_type.Diff data None None

end
