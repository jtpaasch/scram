(** Implements {!Token_printer}. *)

let marshal_token tk =
  let tk_type = Token_type.string_of (Token.token tk) in
  let tk_type_str = Printf.sprintf "Token type: %s" tk_type in
  let tk_type_ttystr = Tty_str.create tk_type_str in
  let lines_header = Tty_str.create "Raw data:" in
  let lines = List.map (Printf.sprintf "- %s") (Token.data tk) in
  let lines_ttystrs = List.map Tty_str.create lines in
  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs; [footer]]

(** Generate a {!Tty_str.t} list) from a {!Token.t} list. *)
let pprint tokens =
  let header = 
    Tty_str.create ~fmt:Tty_str.Bold "---------------- Tokens\n" in
  let tokens_output = List.map marshal_token tokens in
  let tokens_ttystrs = List.flatten tokens_output in
  List.flatten [[header]; tokens_ttystrs]