(** Implements {!Node}. *)

type t = {
  token : Token_type.t;
  data : string list;
  cmd : string;
  output : string list
}

let build token data cmd output = { token; data; cmd; output }

let string_of t =
  Printf.sprintf "TOKEN: %s\nDATA:\n- %s\nCMD: %s\nOUTPUT:\n- %s\n......%!" 
    (Token_type.string_of t.token) 
    (String.concat "\n- " t.data) 
    (t.cmd)
    (String.concat "\n- " t.output)

(** Helps construct [Node_type.Blank] nodes. *)
module Blank = struct

  (** Constructs a [Blank] node. The [data] should be a list of
      blank lines taken from a source test file. *)
  let create data = build Token_type.Blank data "" []

end

(** Helps construct [Node_type.Comment] nodes. *)
module Comment = struct

  (** Constructs a [Comment] node. The [data] should be a list of
      comment lines taken from a source test file. *)
  let create data = build Token_type.Comment data "" []

end

(** Helps construct [Node_type.Code] nodes. *)
module Code = struct

  let pad s = String.concat "" [s; "    "]

  (** Walk through the raw data, and separate the [cmd] from
      the expected [output]. Returns the pair [cmd, output],
      where [cmd] is a string (a command to execute), and
      [output] is a list of strings (expected output). *)
  let rec process data cmd output =
    match data with
    | [] -> (cmd, output)
    | hd :: tl ->
      let padded_s = pad hd in
      match String.sub padded_s 2 2 with
      | "$ " ->
        let cmd_str = String.sub padded_s 4 ((String.length padded_s) - 4) in
        process tl cmd_str output
      | _ ->
        process tl cmd (List.append output [hd])

  (** Constructs a [Code] node. The [data] should be a list of
      lines in the following format: the first line in [data] should
      be of the form ["  $ CMD"], where [CMD] is a command to execute
      in a shell. Any further lines in [data] should be expected
      output from the executed [CMD]. For example, calling
      [create ["  $ echo hi\nhi"; "hi"; "hi"]] will create a [Code]
      node that has the command [echo hi\nhi], and which expects
      as output of that command the lines ["hi"] and ["hi"]. *)
  let create data =
    let cmd, output = process data "" [] in
    build Token_type.Code data cmd output

end
