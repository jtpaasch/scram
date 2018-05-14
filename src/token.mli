
type t = { token : Token_type.t; data : string list }

val create : Token_type.t -> string list -> t

val string_of : t -> string
