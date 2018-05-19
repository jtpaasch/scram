(** A log utility. *)

(** Raised when a log doesn't exist. *)
exception NoSuchLog of string

(** Calling [create "name" "target"] creates a log called [name] that
    will write all messages to [target]. The [target] can be the string
    ["stdout"] (in which case the log will write messages to stdout), the
    string ["stderr"] (in which case the log will write messages to stderr),
    or a string path to a file such as ["/path/to/file.log"] (in which
    case the log will write messages to [/path/to/file.log]). *)
val create : string -> string -> unit
(** All log channels created this way must be closed, using the [close]
    or [close_all] functions below. *)

(** If you have created a log named [name], calling [close "name"] will
    close the log channel. *)
val close : string -> unit

(** This will close all log channels that have been opened. You can register
    it with [at_exit], e.g., [at_exit Logs.close_all]. *)
val close_all : unit -> unit

(** If you have created a log named [name] and a list of [Tty_str]
    strings called [msgs], then [log "name" msgs] will send each [msg]
    to that log. If the log is connected to a TTY, then any TTY formatting
    will be applied to each [msg]. Otherwise, the plain string of [msg]
    will be sent. *)
val log : string -> Tty_str.t list -> unit