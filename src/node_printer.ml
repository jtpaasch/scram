(** Implements {!Node_printer}. *)

let marshal_node n =
  let tk_type = Token_type.string_of (Node.token n) in
  let tk_type_str = Printf.sprintf "Token type: %s" tk_type in
  let tk_type_ttystr = Tty_str.create tk_type_str in
  let lines_header = Tty_str.create "Raw data:" in
  let lines = List.map (Printf.sprintf "- %s") (Node.data n) in
  let lines_ttystrs = List.map Tty_str.create lines in
  let cmd =
    match Node.cmd n with
    | Some x -> Printf.sprintf "Cmd: %s" x
    | None -> "Cmd: N/a" in 
  let cmd_ttystr = Tty_str.create cmd in
  let output_header =
    match Node.output n with
    | Some x -> Tty_str.create "Expected output:"
    | None -> Tty_str.create "Expected output: N/a" in
  let output =
    match Node.output n with
    | Some x -> 
      begin
        match List.length x with
        | 0 -> ["- None specified"]
        | _ -> List.map (Printf.sprintf "- %s") x
      end
    | None -> [] in
  let output_ttystrs = List.map Tty_str.create output in
  let footer = Tty_str.create "" in
  List.flatten [[tk_type_ttystr]; [lines_header]; lines_ttystrs;
    [cmd_ttystr]; [output_header]; output_ttystrs; [footer]]

(** Generate a {!Tty_str.t} list from a {!Node.t} list. *)
let pprint nodes =
  let header = Tty_str.create ~fmt:Tty_str.Bold 
    "---------------- AST Nodes\n" in
  let nodes_output = List.map marshal_node nodes in
  let nodes_ttystrs = List.flatten nodes_output in
  List.flatten [[header]; nodes_ttystrs]
