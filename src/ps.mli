(** A utility for running shell commands. *)

(** As an example, you can run the command [echo hello]:

    {[  Cmd.run "echo hello";; ]}

    The [Cmd.run] function returns a triple: an exit code,
    a stdout buffer, and a stderr buffer.

    {[  let code, out_buf, err_buf = Cmd.run "echo hello";; ]}

    The exit code is an integer.

    {[  Printf.printf "Exit code: %d\n%!" code;; ]}

    Each of the buffers can be read with [Buff.contents]. For example:

    {[  Printf.printf "Stdout: %s\n%!" (Buff.contents out_buff);; ]}

    *)

(** A helper for moving data from an [in_channel] to a [Buffer]. *)
module Buff : sig

  (** Transfers everything from an in_channel to a buffer.

      Arguments:
      - A pair [(in_channel, buf)], where [in_channel] is an
      in_channel, and [buf] is a standard buffer, [Buffer.t].

      Returns: Nothing. After this function is called,
      the provided [buf] is populated with data from the channel.

      For example, if [ic] is an in_channel and [b] is an empty buffer,
      then [read (ic, b)] will transfer all the lines in [ic] to [b]. *)
  val read : in_channel * Buffer.t -> unit

  (** Returns a copy of the contents of a buffer (as a string).

      Arguments:
      - A pair [(in_channel, buf)], where [in_channel] is an
      in_channel, and [buf] is a standard buffer, [Buffer.t].

      Returns: a copy of the string contents of [buf].

      For example, if you have called [read (ic, b)] to transfer
      the contents of [ic] to [b], then [contents (ic, b)] will
      return a copy of the string contents of [b]. *)
  val contents : in_channel * Buffer.t -> string

end

(** A module that runs shell commands. *)
module Cmd : sig

  (** Runs a command in a shell, returns the exit code, stdout, and stderr.

      Arguments:
      - A string (the command to execute in the shell)

      Returns: a triple composed of:
      - The exit code (an int)
      - A "buffer" (which is actually a pair of [(in_channel, Buffer.t)])
      that contains the command's stdout. The contents can be retrieved
      with {!Buff.contents}.
      - A "buffer" (which is actually a pair of [(in_channel, Buffer.t)])
      that contains the command's stderr. The contents can be retrieved
      with {!Buff.contents}.

      See the top of the file for usage examples. *)
  val run : string -> int * (in_channel * Buffer.t) * (in_channel * Buffer.t)

end
