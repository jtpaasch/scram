(** Implements {!Files}. *)

let line ic =
  try
    let result = input_line ic in
    Some result
  with End_of_file -> None

let rec read ic acc =
  match line ic with
  | Some l -> read ic (List.append acc [l])
  | None -> acc

(** Reads a file and returns its contents (as a list of lines).
    Arguments:
    - A path to a file (a string).
    Returns: A string liste. *)
let load f =
  let ic = open_in f in
  try
    read ic []
  with e ->
    close_in ic;
    raise e
