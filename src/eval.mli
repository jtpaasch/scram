(** Runs (executes) and evaluates an {!Ast}. *)

(** Raised if an invalid node is encountered. *)
exception InvalidNode of string

(** Takes an AST (constructed with {!Ast.build}) and an accumulator,
    runs all the nodes in the AST, and constructs a list of {!Result}s. *)
val run : Node.t list -> Result.t list -> Result.t list
(** For example, if [nodes] is a list of nodes constructed with
    {!Ast.build}, then you can run/evaluate the nodes by calling
    [let results = run nodes []]. *)
