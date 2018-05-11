(** A log utility. *)

(** Calling [create "name" "target"] creates a log called [name] that
    will write all messages to [target]. The [target] can be the string
    ["stdout"] (in which case the log will write messages to stdout), the
    string ["stderr"] (in which case the log will write messages to stderr),
    or a string path to a file such as ["/path/to/file.log"] (in which
    case the log will write messages to [/path/to/file.log]). *)
val create : string -> string -> unit

val close : string -> unit
val close_all : unit -> unit

(** If you use the [create] function below to create a log named [name],
    then calling [log "name" "A message"] will send [A message] to
    that log named [name]. *)
val log : string -> string -> unit
