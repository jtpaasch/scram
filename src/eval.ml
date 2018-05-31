(** Implements {!Eval}. *)

exception InvalidNode of string

(** Constructs a {!Result.t} list from a {!Node.t} list. A {!Result.t}
    represents a {!Node.t}, after it has been executed/evaluated.
    Effectively, this function represents the process of taking an AST
    of {!Node.t}s, and executing/evaluating it.
    Arguments:
    - A {!Node.t} list (constructed with {!Ast.build}).
    - The number of times to execute each {!Node.t}, when calculating
      its average execution/running time.
    - An accumulator (e.g., an empty {!Result.t} list).
    Returns: A {!Result.t} list. *)
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
