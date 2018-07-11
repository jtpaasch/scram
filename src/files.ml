(** Implements {!Files}. *)

exception NoSuchFile of string
exception CouldNotRead of string

let open_in_exn f =
  try open_in f
  with Sys_error e ->
    let msg = Printf.sprintf "No such file: '%s'" f in
    raise (NoSuchFile msg)

let line ic =
  try
    let result = input_line ic in
    Some result
  with End_of_file -> None

let rec read_lines_to_end ic acc =
  match line ic with
  | Some l -> read_lines_to_end ic (List.append acc [l])
  | None -> acc

let read_chars_to_end b c =
  try
    while true do
      Buffer.add_channel b c 1
    done
  with End_of_file -> ()

(** Reads a file and returns its contents as a string.

    Arguments:
    - A path to a file (a string).

    Returns: A string. *)
let to_string f =
  let ic = open_in_exn f in
  let buf = Buffer.create 32 in
  read_chars_to_end buf ic;
  Buffer.contents buf

(** Reads a file and returns its contents as a list of lines.

    Arguments:
    - A path to a file (a string).

    Returns: A string list. *)
let to_lines f =
  let ic = open_in_exn f in
  try
    read_lines_to_end ic []
  with e ->
    close_in ic;
    raise e
