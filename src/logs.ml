(** A log utility. *)

let hash : (string, out_channel) Hashtbl.t =
  Hashtbl.create 256

let channel target =
  match target with
  | "stdout" -> stdout
  | "stderr" -> stderr
  | filename ->
    open_out_gen [Open_creat; Open_text; Open_append] 0o640 filename

let create name target =
  let ch = channel target in
  Hashtbl.add hash name ch

let close name =
  Printf.printf "Closing '%s' log channel.\n" name;
  let ch = Hashtbl.find hash name in
  close_out ch

let close_all = fun () ->
  Hashtbl.iter (fun name _ -> close name) hash

let log name msg =
  let ch = Hashtbl.find hash name in
  Printf.fprintf ch "%s\n%!" msg
