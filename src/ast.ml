(** Implements {!Ast}. *)

exception InvalidToken of string

(** Takes a list of tokens (generated by {!Lexer.tokenize}) and an
    accumulator, and constructs an AST of nodes. *)
let rec build tokens acc =
  match tokens with
  | [] -> acc
  | hd :: tl ->
    let node = match hd.Token.token with
    | Token_type.Blank -> Node.Blank.create hd.Token.data
    | Token_type.Comment -> Node.Comment.create hd.Token.data
    | Token_type.Code -> Node.Code.create hd.Token.data
    | Token_type.ProfiledCode -> Node.ProfiledCode.create hd.Token.data
    | Token_type.Stats -> Node.Stats.create hd.Token.data
    | Token_type.Diff -> Node.Diff.create hd.Token.data
    | Token_type.Output ->
      raise (InvalidToken "Cannot process output token in AST.")
    in
    build tl (List.append acc [node])
