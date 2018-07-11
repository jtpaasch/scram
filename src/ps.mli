(** A utility for running shell commands. *)

(** As an example, you can run the command [echo hello]:

    {[
      Cmd.run "echo hello";;
    ]}

    The [Cmd.run] function returns a triple: an exit code,
    a stdout buffer, and a stderr buffer.

    {[
      let code, out_buf, err_buf = Cmd.run "echo hello";;
    ]}

    The exit code is an integer.

    {[
      Printf.printf "Exit code: %d\n%!" code;;
    ]}

    Each of the buffers can be read with [Buff.contents]. For example:

    {[
      Printf.printf "Stdout: %s\n%!" (Buff.contents out_buf);;
    ]}

*)

(** A module that wraps stdout/stderr collected by {!Cmd.run}. *)
module Buff : sig

  type t

  (** Create a {!Buff.t} instance.

      Arguments:
      - An [in_channel].

      Returns: a {!Buff.t} instance. *)
  val create : in_channel -> t

  (** Populates a {!Buff.t} instance with data.

      Arguments:
      - A {!Buff.t} instance.

      Returns: Nothing. After this function is called,
      the provided {!Buff.t} is populated with data.

      For example, if [out_buf] is a {!Buff.t} instance,
      then [fill out_buf] will populate [out_buf] with data.
      The contents can then be retrieved with {!Buff.contents}. *)
  val fill : t -> unit

  (** Returns a copy of the contents of a {!Buff.t} instance (as a string).

      Arguments:
      - A {!Buff.t} instance.

      Returns: a copy of the string contents of {!Buff.t}.

      For example, if [out_buf] is an {!Buff.t} instance, and you have
      called [Buff.read out_buf], then [Buff.contents out_buf] will
      return the contents of [out_buf], as a string. *)
  val contents : t -> string

end

(** A module that wraps stats about a command's execution. *)
module Stat : sig

  (** These exceptions can be raised while the module is attempting to
      parse [/proc/[pid]/stat], if it encounters something unexpected. *)
  exception NotAnInt of string
  exception NoSuchDatum of string

  type t

  (** Returns the [pid] reported by the kernel for the process. *)
  val pid : t -> int

  (** Returns the resident set size reported by the kernel for the process. *)
  val rss : t -> int

  (** Creates a [Stat.t] record. It gets the data by asking the kernel
      for statistics about a process (i.e., it reads /proc/[pid]/stat).

      Arguments:
      - A PID (int) to gather stats about.

      Returns: a {Stat.t} option. It will return [Some t] if it collected
      stats about the given [pid], or [None] if the kernel has no information
      about the requested [pid]. *)
  val create : int -> t option

  (** Creates a [Stat.t] record, just like {!Stat.create}, but this function
      can raise a [SysError("No such file...")] error if the kernel has
      no [/proc/[pid]/stat] record. *) 
  val create_exn : int -> t

end

(** A module that runs shell commands. *)
module Cmd : sig

  (** Runs a command in a shell, returns the exit code, stdout, and stderr.

      Arguments:
      - A string (the command to execute in the shell)

      Returns: a triple composed of:
      - The exit code (an int)
      - A {!Buff.t} that contains the command's stdout.
      The contents can be retrieved with {!Buff.contents}.
      - A {!Buff.t} that contains the command's stderr.
      The contents can be retrieved with {!Buff.contents}.

      See {!Ps} for usage examples. *)
  val run : string -> int * Buff.t * Buff.t * Stat.t list

end
