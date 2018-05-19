(** A utility for printing test results. *)

(** Raised when a result is invalid. *)
exception InvalidResult of string

(** Generates pprintable output of an executed test. There are three
    arguments:
    - A string title for the test.
    - A list of {!Result.t} nodes for the body of the test.
    - A boolean representing whether the test succeeded or failed.
    This returns a {!Tty_str.t} list. *)
val pprint_test : string -> Result.t list -> bool -> Tty_str.t list

(** Generates pprintable output of a file. The argument is a list of
    strings (the lines of the file). This returns a {!Tty_str.t} list). *)
val pprint_file : string list -> Tty_str.t list

(** Generates pprintable output of tokens. The argument is a {!Token.t} list.
    This returns a {!Tty_str.t} list. *)
val pprint_tokens : Token.t list -> Tty_str.t list

(** Generates pprintable output of AST nodes. The argument is a
    {!Nodes.t} list. This returns a {!Tty_str.t} list. *)
val pprint_nodes : Node.t list -> Tty_str.t list

(** Generates pprintable output of the executed AST/results. The argument
    is a {!Result.t} list. This returns a {!Tty_str.t} list. *)
val pprint_results : Result.t list -> Tty_str.t list