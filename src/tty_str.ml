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

(** Creates a [Tty_str] record.

    Arguments:
    - [?fmt:ttyfmt] - An optional format from the [ttyfmt] typeabove.
    - The string to represent.

    Returns: a {!Tty_str.t}. *)
let create ?(fmt = Plain) data = { fmt; data }                               

(** Constructs a string from a [Tty_str] object.

    Arguments:
    - [?for_tty:bool] - Indicates whether the string is meant for a TTY.
    If so, the appropriate ASCII formatting tags are inserted into
    the returned string. Otherwise, no ASCII tags are inserted, and the
    returned string is just the plain string.
    - A {!Tty_str.t} string to generate a string from.

    Returns: a string that can be printed in a TTY or other target. *)
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
