(** Implements {!Log}. *)

type ttyfmt =
  | Plain
  | Red
  | Green
  | Warn
  | Emph

exception NoSuchLog of string

let reset_tag = "\x1b[0m"
let file_opts = [Unix.O_WRONLY; Unix.O_APPEND; Unix.O_CREAT]
let file_perm = 0o600
let hash : (string, out_channel) Hashtbl.t = Hashtbl.create 256

(** Get the start tag for a TTY format. *)
let start_of fmt =
  match fmt with
  | Plain -> ""
  | Red -> "\x1b[31m"
  | Green -> "\x1b[32m"
  | Warn -> "\x1b[33m"
  | Emph -> "\x1b[;1m"

(** Get the end tag for a TTY format. *)
let end_of fmt =
  match fmt with
  | Plain -> ""
  | _ -> reset_tag

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

(** Determine if an out_channel [oc] is connected to a TTY. *)
let is_tty oc =
  let fd = Unix.descr_of_out_channel oc in
  Unix.isatty fd

(** Construct a message with TTY formatting (if the
    the channel [oc] is connected to a TTY). For example,
    [format stdout_ch Red "Lorem ipsum"] will format
    the string "Lorem ipsum" as red text if the channel
    [stdout_ch] is connected to a TTY. *)
let format oc fmt msg =
  let do_fmt = is_tty oc in
  let start_tag =
    match do_fmt with
    | false -> ""
    | true -> start_of fmt
    in
  let end_tag =
    match do_fmt with
    | false -> ""
    | true -> end_of fmt
    in
  Printf.sprintf "%s%s%s\n%!" start_tag msg end_tag

(** Send a [msg] to the log named [key]. For instance, if you created
    a log by calling [create "verbose_log" "stdout"], then calling 
    [log "verbose_log" "Here is a message."] will send the message
    [Here is a message] to stdout. You can optionally specify one
    of the [ttyfmt.t] formats, for example: 
    [log ~fmt:Red "verbose_log" "Here is another message."].*)
let log ?(fmt = Plain) key msg =
  match find key with
  | Some oc ->
    let formatted_msg = format oc fmt msg in
    Printf.fprintf oc "%s\n%!" formatted_msg
  | None -> raise (NoSuchLog (Printf.sprintf "No such log: '%s'\n%!" key))
