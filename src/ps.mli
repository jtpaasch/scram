(** A utility for running shell commands. *)

(** As an example, you can run the command [echo hello]:

        [Cmd.run "echo hello";;]

    The [Cmd.run] function returns a triple: an exit code,
    a stdout buffer, and a stderr buffer.

        [let code, out_buf, err_buf = Cmd.run "echo hello";;]

    The exit code is an integer.

        [Printf.printf "Exit code: %d\n%!" code;;]

    Each of the buffers can be read with [Buff.read]. For example:

        [Printf.printf "Stdout: %s\n%!" (Buff.read out_buff);;]

    *)

(** A helper module for moving data from an [in_channel] to a [Buffer]. *)
module Buff : sig

  (** Reads everything from a channel (in chunks), and stores it in
      a buffer. It takes one argument: a pair [(in_channel, buf)].
      E.g., [read (ic, buf)] reads everything from the in channel [ic],
      and puts it in the buffer [buf]. *)
  val read : in_channel * Buffer.t -> unit

  (** Gets a copy of the contents in the buffer (as a string). *)
  val contents : in_channel * Buffer.t -> string

end

(** A module that runs shell commands. *)
module Cmd : sig

  (** Takes a command (as a string), and runs it in the shell. It returns
      a triple of three things: an exit code (an [int]), an in channel/buffer
      pair that holds the command's stdout, and an in channel/buffer pair
      that holds the command's stderr. *)
  val run : string -> int * (in_channel * Buffer.t) * (in_channel * Buffer.t)
  (** You can treat each in channel/buffer pair as a single object, and
  use [Buff.read] to retrieve its string contents, since [Buff.read] takes an
  in channel/buffer pair for its argument. *)

end
