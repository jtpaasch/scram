(** Implements {!Log}. *)

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

(** Closes a named logs stream.

    Arguments:
    - The name (a string) of the log to close.

    Returns: nothing. *)
let close key =
  match find key with
  | Some oc ->
    close_out oc;
    Hashtbl.remove hash key
  | None -> ()

(** This function will close all log channels that have been opened.
    To ensure that all logs are closed when the program terminates,
    you can register this function with [at_exit], e.g., something
    like this in your main file:

    {[
      let () =
        at_exit Logs.close_all;
        main ()
    ]}

    *)
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

(** This function creates a log stream with a given name and a
    target channel to write messages to.

    Arguments:
    - A name for the log (a string).
    - A target to write messages to. The target must be a string,
      but valid values are "stdout", "stderr", or a path to a file.
      If the string is not "stdout" or "stderr," this function will
      assume it is a file path, and try to create/open it for writing.

    Returns: nothing.

    Examples: [create "debug" "stderr"] will create a log stream
    called [debug] that will write its messages to [stderr], while
    [create "events" "/tmp/events.log"] will create a log stream
    called [events] that write to the file [/tmp/events.log]. *)
let create key target =
  match find key with
  | Some oc -> ()
  | None ->
    let oc = channel_of target in
    register key oc

(** Determine if an out_channel [oc] is connected to a TTY. *)
let is_tty oc =
  let fd = Unix.descr_of_out_channel oc in
  Unix.isatty fd

(** Sends a list of messages to a named log stream. The messages
    must be {!Tty_str.t} strings, so that they can be properly
    formatted for printing if the log's target is a TTY.

    Arguments:
    - The name (a string) of the log to write to.
    - A list of messages (i.e., a list of {!Tty_str.t} strings).

    Returns: nothing. *)
let log key ttymsgs =
  match find key with
  | Some oc ->
    begin
      match is_tty oc with
      | false ->
        List.iter (fun s -> 
          let msg = Tty_str.string_of ~for_tty:false s in
          Printf.fprintf oc "%s\n%!" msg) 
        ttymsgs
      | true ->
        List.iter (fun s -> 
          let msg = Tty_str.string_of ~for_tty:true s in
          Printf.fprintf oc "%s\n%!" msg)
        ttymsgs
    end
  | None -> raise (NoSuchLog (Printf.sprintf "No such log: '%s'\n%!" key))
