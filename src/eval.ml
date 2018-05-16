(** Implements {!Eval}. *)

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
      Result.Code.create hd.Node.data hd.Node.cmd hd.Node.output
    | Token_type.Output ->
      raise (Failure "Cannot evaluate an output node.") in
      run tl (List.append acc [result])
