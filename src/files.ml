(** A file reading utility. *)


(** [line ic] returns [Some line] from input channel [ic], or [None]. *)
let line ic =
  try
    let result = input_line ic in
    Some result
  with End_of_file -> None

(** [read ic []] reads all lines from input channel [ic]. *)
let rec read ic acc =
  match line ic with
  | Some l -> read ic (List.append acc [l])
  | None -> acc

(** [load "/path/to/file.txt"] returns a list of all lines in the file. *)
let load f =
  let ic = open_in f in
  try
    read ic []
  with e ->
    close_in ic;
    raise e
