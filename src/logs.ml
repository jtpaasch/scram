(** A logging utility. *)

exception NoSuchLog of string

let file_opts = [Unix.O_WRONLY; Unix.O_APPEND; Unix.O_CREAT]
let file_perm = 0o600
let hash : (string, out_channel) Hashtbl.t = Hashtbl.create 256

(** Registers a log. The [key] is a name (a string) for the log,
    and [oc] is an [out_channel] to write log messages to. *)
let register key oc = Hashtbl.add hash key oc

(** Look up a log by its [key] (the string name of the log). Returns
    [Some out_channel], or [None]. *)
let find key =
  try
    Some (Hashtbl.find hash key)
  with Not_found -> None

(** Close a log channel named [key]. Does nothing if there is no such log. *)
let close key =
  match find key with
  | Some oc ->
    close_out oc;
    Hashtbl.remove hash key
  | None -> ()

(** Close all registered log channels. *)
let close_all = fun () ->
  Hashtbl.iter (fun key _ -> close key) hash

(** Calling [file_out_channel "/path/to/file.log"] will open an [out_channel]
    to [/path/to/file.log] for writing. *)
let file_out_channel path =
  let fd = Unix.openfile path file_opts file_perm in
  Unix.out_channel_of_descr fd

(** Opens an [out_channel] to the specified [target]. The [target] can
    be a string ["stdout"], ["stderr"], or ["/path/to/file.log"]. *)
let channel_of target =
  match target with
  | "stdout" -> Unix.out_channel_of_descr Unix.stdout
  | "stderr" -> Unix.out_channel_of_descr Unix.stderr
  | path -> file_out_channel path

(** Create a log channel. The [key] is a name (a string) for the log,
    and [target] is a string that specifies where to write the log,
    which can be ["stdout"], ["stderr"], or ["/path/to/file.log"]. 
    For instance, calling [create "verbose_log" "stdout"] will create
    a log called [verbose_log] that writes to stdout. *)
let create key target =
  match find key with
  | Some oc -> ()
  | None ->
    let oc = channel_of target in
    register key oc
(** If the specified [key] [target] log have already been created, this 
    will silently do nothing. *)

(** Send a [msg] to the log named [key]. For instance, if you created
    a log by calling [create "verbose_log" "stdout"], then calling 
    [log "verbose_log" "Here is a message."] will send the message
    [Here is a message] to stdout. *)
let log key msg =
  match find key with
  | Some oc -> Printf.fprintf oc "%s\n%!" msg
  | None -> raise (NoSuchLog (Printf.sprintf "No such log: '%s'\n%!" key))
