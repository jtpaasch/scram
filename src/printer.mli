(** A utility for printing test results. *)

(** Raised when a result is invalid. *)
exception InvalidResult of string

(** Generate a header string. The argument is a title/name for the test.
    For instance, [header "my-test.t"] will generate a header for a
    test, with the title [my-test.t]. *)
val header : string -> string

(** Generate a string that represents the entirety of the results.
    The argument is a list of {!Result} nodes. *)
val test : Result.t list -> string

(** Generate a string that represents a footer string for a test.
    The argument is a [bool] that indicates whether the test passed. *)
val footer : bool -> string
