(** Implements {!Node}. *)

type t = {
  token : Token_type.t;
  data : string list;
  cmd : string option;
  output : string list option;
}

let build token data cmd output = { token; data; cmd; output }

let token t = t.token
let data t = t.data
let cmd t = t.cmd
let output t = t.output

(** Helps construct [Node_type.Blank] nodes. *)
module Blank = struct

  (** Constructs a [Blank] node. The [data] should be a list of
      blank lines taken from a source test file. *)
  let create data = build Token_type.Blank data None None

end

(** Helps construct [Node_type.Comment] nodes. *)
module Comment = struct

  (** Constructs a [Comment] node. The [data] should be a list of
      comment lines taken from a source test file. *)
  let create data =
    build Token_type.Comment data None None

end

(** Helps construct [Node_type.Code] nodes. *)
module Code = struct

  let extract_cmd s =
    let len = String.length s in
    match len > 4 with
    | false -> s
    | true -> String.sub s 4 (len - 4)

  let trim_prefixes lines =
    List.map (fun s -> String.sub s 2 ((String.length s) - 2)) lines

  let process data =
    match data with
    | [] -> ("", [])
    | hd :: [] -> (extract_cmd hd, [])
    | hd :: tl -> (extract_cmd hd, trim_prefixes tl)

  (** Constructs a [Code] node. The [data] should be a list of
      one code line taken from a source test file. *)
  let create data =
    let cmd, output = process data in
    build Token_type.Code data (Some cmd) (Some output)

end

(** Helps construct [Node_type.ProfiledCode] nodes. *)
module ProfiledCode = struct

  let extract_cmd s =
    let len = String.length s in
    match len > 4 with
    | false -> s
    | true -> String.sub s 4 (len - 4)

  let trim_prefixes lines =
    List.map (fun s -> String.sub s 2 ((String.length s) - 2)) lines

  let process data =
    match data with
    | [] -> ("", [])
    | hd :: [] -> (extract_cmd hd, [])
    | hd :: tl -> (extract_cmd hd, trim_prefixes tl)

  (** Constructs a [ProfiledCode] node. The [data] should be a list of
      one code line taken from a source test file. *)
  let create data =
    let cmd, output = process data in
    build Token_type.ProfiledCode data (Some cmd) (Some output)

end

(** Helps construct [Node_type.Stats] nodes. *)
module Stats = struct

  let create data =
    build Token_type.Stats data None None

end

(** Helps construct [Node_type.Diff] nodes. *)
module Diff = struct

  let create data =
    build Token_type.Diff data None None

end
