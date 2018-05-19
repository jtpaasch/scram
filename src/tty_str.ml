(** Implements {!Tty_str}. *)

type ttyfmt =
    | Plain
    | Red
    | Green
    | Yellow
    | Bold
    | Dim
    | Italic
    | Underline

type t = { fmt : ttyfmt; data: string }                                      

let start_of fmt =
  match fmt with
  | Plain -> ""
  | Red -> "\x1b[31m"
  | Green -> "\x1b[32m"
  | Yellow -> "\x1b[33m"
  | Bold -> "\x1b[1m"
  | Dim -> "\x1b[2m"
  | Italic -> "\x1b[3m"
  | Underline -> "\x1b[4m"

let end_of fmt =
  match fmt with
  | Plain -> ""
  | _ -> "\x1b[0m"

let create ?(fmt = Plain) data = { fmt; data }                               

let string_of ?(for_tty = false) t =
  let start_tag =
    match for_tty with
    | false -> ""
    | true -> start_of t.fmt
    in
  let end_tag =
    match for_tty with
    | false -> ""
    | true -> end_of t.fmt
    in
  Printf.sprintf "%s%s%s" start_tag t.data end_tag
