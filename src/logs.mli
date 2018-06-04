(** A log utility. *)

(** Raised when a named log doesn't exist. *)
exception NoSuchLog of string

(** This function creates a log stream with a given name and a
    target channel to write messages to.

    Arguments:
    - A name for the log (a string).
    - A target to write messages to. The target must be a string,
      but valid values are "stdout", "stderr", or a path to a file.
      If the string is not "stdout" or "stderr," this function will
      assume it is a file path, and try to create/open it for writing.

    Returns: nothing.

    For example, [create "debug" "stderr"] will create a log stream
    called [debug], which will write its messages to [stderr]. You
    can then send messages to the [debug] stream with the [log] function
    below.
    
    Another example: [create "events" "/tmp/events.log"] will create
    a log stream called [events], which will write its messages to the
    file [/tmp/events.log].

    You can have logs write to nowhere, e.g., [create "mylog" "/dev/null"]
    will create a log stream called [mylog] that writes to [/dev/null].

    Note: any log stream you open with this [create] function must be
    explicitly closed, using the [close] or [close_all] functions below. *)
val create : string -> string -> unit

(** Closes a named logs stream.

    Arguments:
    - The name (a string) of the log to close.

    Returns: nothing.

    For example, if you created a log called [mylog], then [close "mylog"]
    will close it. *)
val close : string -> unit

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
val close_all : unit -> unit

(** Sends a list of messages to a named log stream. The messages
    must be {!Tty_str.t} strings, so that they can be properly
    formatted for printing if the log's target is a TTY.

    Arguments:
    - The name (a string) of the log to write to.
    - A list of messages (i.e., a list of {!Tty_str.t} strings).

    Returns: nothing.

    For example, if you created a log called [mylog], and you have a
    list of [Tty_str] strings called [msgs], then [log "mylog" msgs]
    will send each [msg] to [mylog]'s target channel.

    Note: if the log's target channel is a TTY, then each [msg] will be
    formatted for TTY output. If the target channel is not a TTY,
    then each [msg] will be sent without any TTY formatting. *)
val log : string -> Tty_str.t list -> unit