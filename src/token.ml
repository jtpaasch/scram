(** Implements {!Token}. *)

type t = { token : Token_type.t; data : string list }

let create token data = { token; data }

let string_of t =
  let token_type_str = Token_type.string_of t.token in
  let lines = List.map (Printf.sprintf "| - %s") t.data in
  let data_str = String.concat "\n" lines in
  Printf.sprintf
    "|...................\n| Token type: %s\n| Lines of data:\n%s\n|"
    token_type_str data_str

