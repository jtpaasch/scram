(** Nodes that an {!Ast} can be built from. *)

(** A [Node] carries with it a token type {!Token_type}, some raw [data]
    (a list of strings from the source file), an optional [cmd] (a string
    to execute in a shell), and some optional expected [output] (a list
    of strings that the [cmd] is expected to produce as output). *)
type t

(** Builds an AST node.

    Arguments:
    - A {!Token_type.t}.
    - A list of strings of raw content/data
    (e.g., taken from the source file).
    - An optional command (a string) to execute.
    - An optional list of lines of output the command
    is expected to produce.

    Returns: A {!Node.t} record.

    Note: this is a general function for creating AST {!Node.t} records.
    There are helper modules below that make creating particular types
    of nodes easier. For instance, to create a node of blank lines, use
    {!Blank.create} below. *)
val build :
  Token_type.t ->
  string list ->
  string option ->
  string list option ->
  t

(** Get the token type of a node. *)
val token : t -> Token_type.t

(** Get the raw data of the node. *)
val data : t -> string list

(** Get the command of the node. *)
val cmd : t -> string option

(** Get the expected output of the node. *)
val output : t -> string list option

(** Helps construct {!Token_type.t.Blank} nodes. *)
module Blank : sig

  (** Constructs a {!Token_type.t.Blank} node.

      Arguments:
      - A list of blank lines (e.g., taken from a source file).

      Returns: A {!Node.t} record.

      For example, [create [""; "  "; ""]] will construct a
      [Token_type.Blank] node whose raw content/data is the provided
      three blank lines. *)
  val create : string list -> t

end

(** Helps construct {!Token_type.t.Comment} nodes. *)
module Comment : sig

  (** Constructs a {!Token_type.t.Comment} node.

      Arguments:
      - A list of blank lines (e.g., taken from a source file).

      Returns: A {!Node.t} record.

      For example, [create ["This is some textual"; "commentary."]]
      will construct a [Token_type.Comment] node whose raw content/data
      is the provided two lines of text. *)
  val create : string list -> t

end

(** Helps construct {!Token_type.t.Code} nodes. *)
module Code : sig

  (** Constructs a {!Token_type.t.Code} node.

      Arguments:
      - A list of lines of code (e.g., taken from a source file).
      The first line should be a command to execute.
      The remaining lines (if any) should be lines of expected output.

      Returns: A {!Node.t} record, populated with a [cmd] and
      any expected [output].

      For example, [create ["  $ echo hi & echo hi"; "hi"; "hi"]] will
      construct a {!Token_type.t.Code} node whose raw content/data is the
      three provided lines. However, this function will extract from
      that raw data (a) the command "echo hi & echo hi", and (b) two
      lines of expected output, namely "hi" and "hi". So the final
      {!Node.t} record that this function returns will be decorated with
      a [cmd] and expected [output], in addition to the raw data.

      Note that there need not be any output in the raw data. For example,
      [create ["  $ echo hi"]] will construct a [Token_type.Code] node
      with just a [cmd] (namely [echo hi]), and no [output]. *)
  val create : string list -> t

end

(** Helps construct {!Token_type.t.ProfiledCode} nodes. *)
module ProfiledCode : sig

  (** Constructs a {!Token_type.t.ProfiledCode} node.

      Arguments:
      - A list of lines of code (e.g., taken from a source file).
      The first line should be a command to execute.
      The remaining lines can be lines of expected output.

      Returns: A {!Node.t} record.

      [ProfiledCode] nodes are constructed exactly like regular [Code]
      nodes, so see {!Code.create} for examples. The only difference
      is that profiled code commands marked with an asterisk in the raw
      source file. *)
  val create : string list -> t

end

(** Helps construct {!Token_type.t.Stats} nodes. *)
module Stats : sig

  (** Constructs a {!Token_type.t.Stats} node.

      Arguments:
      - A list of raw source lines (e.g., taken from a source file)
      containing the [#stats] directive.

      Returns: A {!Node.t} record.

      For example, [create ["#stats"]] will create a {!Token_type.t.Stats}
      node whose raw content/data is the line [#stats].*)
  val create : string list -> t

end

(** Helps construct {!Token_type.t.Diff} nodes. *)
module Diff : sig

  (** Constructs a {!Token_type.t.Diff} node.

      Arguments:
      - A list of raw source lines (e.g., taken from a source file)
      containing the [#diff] directive.

      Returns: A {!Node.t} record.
      
      For example, [create ["#diff"]] will create a {!Token_type.t.Diff}
      node whose raw content/data is the line [#diff].*)
  val create : string list -> t

end
