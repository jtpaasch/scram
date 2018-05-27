(** A utility that packages up a pass/fail (bool) and a reason. *) 

type status =
  | NA
  | NonZeroExit
  | ZeroExit
  | UnexpectedOutput
  | ExpectedOutput

type t = {
  passed: bool;
  reason: status;
}

val create : bool -> status -> t

val is_successful : t -> bool

val why : t -> status

val string_of_why : status -> string

val get_success :
  int ->
  string list ->
  string list ->
  string list ->
  t
