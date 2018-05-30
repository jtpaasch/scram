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
  cmd: string option;
  output: string list option;
  stdout: string list option;
  stderr: string list option;
  exit_code: int option;
  success: Success.t;
  trials: Trials.t option;
}

(** Raised if an invalid node is encountered. *)
exception InvalidNode of string

(** Builds a result. The parameters are all the data that go in the
    {!Result.t} record. *)
val build : Token_type.t ->
            string list ->
	    string option ->
	    string list option ->
	    string list option ->
	    string list option ->
	    int option ->
	    Success.t ->
	    Trials.t option ->
	    t

(** Checks if a whole set of results is successful. *)
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

  (** Takes a list of lines of raw data (taken from a source file),
      and a [cmd] (a string command to execute). *)
  val create : string list -> string -> string list -> t

end

(** Helps construct a [Node.ProfiledCode] result. *)
module ProfiledCode : sig

  (** Takes a list of one line of raw data (taken from a source file),
      and a [cmd] (a string command to execute). *)
  val create : string list -> string -> string list -> t

end

(** Helps construct a [Node.Stats] result. *)
module Stats : sig

  (** Constructs a [Stats] result. *)
  val create : string list -> t

end

(** Helps construct a [Node.Diff] result. *)
module Diff : sig

  (** Constructs a [Diff] result. *)
  val create : string list -> t

end