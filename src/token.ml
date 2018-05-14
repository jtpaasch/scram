type t = { token : Token_type.t; data : string list }

let create token data = { token; data }

let string_of t =
  Printf.sprintf "%s:\n%s"
    (Token_type.string_of t.token) (String.concat "\n- " t.data)
