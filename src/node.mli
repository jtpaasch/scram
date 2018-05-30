(** Nodes that an {!Ast} can be built from. *)

(** There are submodule helpers for creating particular types of nodes. *)

(** A [Node] consists of a token type {!Token_type}, its raw [data]
    (a list of strings from the source file), a [cmd] (a string to execute
    in the shell), and some expected [output] (a list of strings). *)
type t = {
  token : Token_type.t;
  data : string list;
  cmd : string option;
  output : string list option;
}

(** Builds a node, given a {!Token_type.t}, a list of strings for
    raw data, an optional string to execute, and a list of strings of
    expected output. *)
val build :
  Token_type.t -> string list -> string option -> string list option -> t
(** For example [build Token_type.Comment ["Comment 1"] None []] will
    construct a [Comment] node, which has as raw data the line
    ["Comment 1"]. Or:
    [build Token_type.Code ["  $ echo hi"; "hi"] (Some "echo hi") ["hi"]]
    will construct a [Code] node, which has as raw data the strings
    ["  $ echo hi"] and ["hi"], the command [echo hi], and the
    expected output [hi]. *)

(** Helps construct [Token_type.Blank] nodes. *)
module Blank : sig

  (** Generates a [Blank] node consisting of one or more blank lines.
      For example, [create [" "; "   "; ""]] will create a [Blank]
      node that consists of those three blank lines. *)
  val create : string list -> t

end

(** Helps construct [Token_type.Comment] nodes. *)
module Comment : sig

  (** Generates a [Comment] node consisting of one or more comment lines.
      For example [create ["Comment 1"; "Comment 2"]] will create a
      [Comment] node that consists of those two comment lines. *)
  val create : string list -> t

end

(** Helps construct [Token_type.Code] nodes. *)
module Code : sig

  (** Generates a [Code] node consisting of some code to execute.
      There is one argument: a list of raw lines from a source file.
      This function will extract the [cmd] (the string to execute),
      and any expected output. For instance, if you call
      [create ["  $ echo hi"; "hi" ]], that will create a [Code] node that
      has for its [cmd] the string [echo hi], and which has for its
      expected [output] the string [hi]. *)
  val create : string list -> t

end

(** Helps construct [Token_type.ProfiledCode] nodes. *)
module ProfiledCode : sig

  (** Generates a [ProfiledCode] node consisting of a code line.
      For example [create [" *$ echo hello"]] will create a
      [ProfiledCode] node that consists of the line [ *$ echo hello]. *)
  val create : string list -> t

end

(** Helps construct [Token_type.Stats] nodes. *)
module Stats : sig

  (** Generates a [Stats] node. *)
  val create : string list -> t

end

(** Helps construct [Token_type.Diff] nodes. *)
module Diff : sig

  (** Generates a [Diff] node. *)
  val create : string list -> t

end
