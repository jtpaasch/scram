(** The result of executing a {!Node} in an {!Ast}. *)

(** Reasons for why a particular node would pass or fail. *)
type status =
  | NA
  | NonZeroExit
  | ZeroExit
  | UnexpectedOutput
  | ExpectedOutput

(** A [Result] has a [Token_type] and raw [data], as well as a [cmd]
    to execute with a list of expected lines of [output]. In addition,
    it also has the actual [stdout] (a list of lines) and [stderr]
    (another list of lines) from the executed [cmd], the [exit_code]
    of the executed [cmd], a [success] (bool) indicator of whether the
    [cmd] ran as expected, and a [diff] of the actual results with
    the expected [output]. *)
type t = {
  token: Token_type.t;
  data: string list;
  cmd: string;
  output: string list;
  stdout: string list;
  stderr: string list;
  exit_code: int;
  success: bool * status;
  diff: string list }

(** Raised if an invalid node is encountered. *)
exception InvalidNode of string

(** Builds a result. The parameters are all the data that go in the
    {!Result.t} record. *)
val build : Token_type.t ->
            string list ->
	    string ->
	    string list ->
	    string list ->
	    string list ->
	    int ->
	    (bool * status) ->
	    string list -> t

(** Generates a string representation of a {!status}. *)
val string_of_status : status -> string

(** Check if all results are successful or not. *)
val is_successful : t list -> bool

(** Helps construct a [Node.Blank] result. *)
module Blank : sig

  (** Takes a list of blank lines taken from a source file,
      and constructs a [Blank] result. *)
  val create : string list -> t

end

(** Helps construct a [Node.Comment] result. *)
module Comment : sig

  (** Takes a list of comment lines taken from a source file,
      and constructs a [Comment] result. *)
  val create : string list -> t

end

(** Helps construct a [Node.Code] result. *)
module Code : sig

  (** Takes a list of data (raw command lines taken from a source file),
      a [cmd] (a string command to execute), and a list of expected
      [output] lines (a list of strings). It executes the [cmd] and
      constructs a [Code] result. *)
  val create : string list -> string -> string list -> t

end
