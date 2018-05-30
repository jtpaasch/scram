(** Implements {!File_printer}. *)

(** Convert a list of strings into a list of {!Tty_str.t} strings. *)
let tty_strings_of lines = List.map Tty_str.create lines

(** Generate a {!Tty_str.t} list from a string list. *)
let pprint lines =
  let header = Tty_str.create ~fmt:Tty_str.Bold 
    "---------------- File contents\n" in
  let body = tty_strings_of lines in
  let footer = Tty_str.create "" in
  List.flatten [[header]; body; [footer]]
