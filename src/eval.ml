(** Implements {!Eval}. *)

exception InvalidNode of string

(** Takes an AST (constructed with {!Ast.build}) and an accumulator,
    runs all the nodes in the AST, and constructs a list of {!Result}s. *)
let rec run ast acc =
  match ast with
  | [] -> acc
  | hd :: tl ->
    let result = match hd.Node.token with
    | Token_type.Blank -> Result.Blank.create hd.Node.data
    | Token_type.Comment -> Result.Comment.create hd.Node.data
    | Token_type.Code ->
      let cmd =
        match hd.Node.cmd with
        | Some x -> x
        | None -> raise (InvalidNode "cmd cannot be empty") in
      let output =
        match hd.Node.output with
        | Some x -> x
        | None -> [] in
      Result.Code.create hd.Node.data cmd output
    | Token_type.ProfiledCode ->
      let cmd =
        match hd.Node.cmd with
        | Some x -> x
        | None -> raise (InvalidNode "cmd cannot be empty") in
      let output =
        match hd.Node.output with
        | Some x -> x
        | None -> [] in
      Result.ProfiledCode.create hd.Node.data cmd output
    | Token_type.Stats ->
      Result.Stats.create hd.Node.data
    | Token_type.Output ->
      raise (InvalidNode "Cannot evaluate an output node.") in
    run tl (List.append acc [result])
