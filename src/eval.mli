(** Runs (executes) and evaluates an {!Ast}. *)

(** Raised if an invalid node is encountered. *)
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

    Returns: A {!Result.t} list.

    For example, if [nodes] is a list of nodes constructed with
    {!Ast.build}, then you can execute/evaluate the nodes with:
    [let results = run nodes []]. *)
val run : Node.t list -> int -> Result.t list -> Result.t list
