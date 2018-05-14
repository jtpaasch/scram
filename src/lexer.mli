
val pad : string -> string

val is_blank : string -> bool

val token_of : string -> Token_type.t

val are_grouped : Token_type.t -> Token_type.t -> 'a list -> bool

val collect : Token_type.t -> string list -> string list -> string list * string list

val tokenize : string list -> Token.t list -> Token.t list
