(** Implements {!Eval}. *)

exception InvalidNode of string

(** Takes an AST (constructed with {!Ast.build}) and an accumulator,
    runs all the nodes in the AST, and constructs a list of {!Result}s. *)
let rec run ast num_trials acc =
  match ast with
  | [] -> acc
  | hd :: tl ->
    let result = match Node.token hd with
    | Token_type.Blank -> Result.Blank.create (Node.data hd)
    | Token_type.Comment -> Result.Comment.create (Node.data hd)
    | Token_type.Code ->
      let cmd =
        match Node.cmd hd with
        | Some x -> x
        | None -> raise (InvalidNode "cmd cannot be empty") in
      let output =
        match Node.output hd with
        | Some x -> x
        | None -> [] in
      Result.Code.create (Node.data hd) cmd output
    | Token_type.ProfiledCode ->
      let cmd =
        match Node.cmd hd with
        | Some x -> x
        | None -> raise (InvalidNode "cmd cannot be empty") in
      let output =
        match Node.output hd with
        | Some x -> x
        | None -> [] in
      Result.ProfiledCode.create (Node.data hd) cmd output num_trials
    | Token_type.Stats ->
      Result.Stats.create (Node.data hd)
    | Token_type.Diff ->
      Result.Diff.create (Node.data hd)
    | Token_type.Output ->
      raise (InvalidNode "Cannot evaluate an output node.") in
    run tl num_trials (List.append acc [result])
