(** Implements {!Ps}. *)

module Proc = struct

  let int_of_status s =
    match s with
    | Unix.WEXITED n -> n
    | Unix.WSIGNALED n -> n
    | Unix.WSTOPPED n -> n

  let shell cmd out err =
    match Unix.fork () with
    | 0 ->
      Unix.dup2 out Unix.stdout;
      Unix.close out;
      Unix.dup2 err Unix.stderr;
      Unix.close err;
      Unix.execvp "/bin/sh" [| "/bin/sh"; "-c"; cmd |]
    | pid -> pid

  let popen cmd =
    let (stdout_read, stdout_write) = Unix.pipe ~cloexec:true () in
    let (stderr_read, stderr_write) =
      try Unix.pipe ~cloexec:true ()
      with e ->
        Unix.close stdout_read;
        Unix.close stdout_write;
        raise e in
    Unix.set_nonblock stdout_read;
    Unix.set_nonblock stderr_read;
    let out_ch = Unix.in_channel_of_descr stdout_read in
    let err_ch = Unix.in_channel_of_descr stderr_read in
    begin
      try
        let pid = shell cmd stdout_write stderr_write in
        Unix.close stdout_write;
        Unix.close stderr_write;
        (pid, out_ch, err_ch)
      with e ->
        Unix.close stdout_read; Unix.close stdout_write;
        Unix.close stderr_read; Unix.close stderr_write;
        raise e;
    end

  let poll pid =
    let pid', s = Unix.waitpid [Unix.WNOHANG] pid in
    match pid' with
    | 0 -> None
    | _ -> Some (int_of_status s)

end


module Buff = struct

  (** Internally, a {Buff.t} instance has:
      - An [in_channel] that it reads data from.
      - A [Buffer.t] that it puts data in. *)
  type t = {channel: in_channel; buffer: Buffer.t}

  let create channel = {channel; buffer = Buffer.create 80}

  let fill t =
    try
      while true do
        Buffer.add_channel t.buffer t.channel 1
      done
    with
    | Sys_blocked_io -> ()
    | End_of_file -> ()

  let contents t = Buffer.contents t.buffer

end


module Stat = struct

  exception NotAnInt of string
  exception NoSuchDatum of string

  (** Internally, a {Stat.t} instance is simply a record of info reported 
      by the kernel, retrieved from [/proc/[pid]/stat]. 

      Not all fields in [/proc/[pid]/stat] are represented here.
      If more fields are needed, they can be added. *)
  type t = {pid: int; rss: int}

  let pid t = t.pid
  let rss t = t.rss

  let pg_size = ref (-1)

  let get_page_size =
    match !pg_size with
    | (-1) ->
      let size_in_bytes =
        Unix.open_process_in "getconf PAGE_SIZE"
        |> input_line
        |> int_of_string in
      pg_size := size_in_bytes / 1024;
      !pg_size
    | _ -> !pg_size

  let to_int_exn s =
    try
      int_of_string s
    with e ->
      let msg = Printf.sprintf "Cannot convert '%s' to an int." s in
      raise (NotAnInt msg)

  let get_elem_exn data idx msg =
    try
      List.nth data idx
    with e ->
      raise (NoSuchDatum msg)

  let parse_pid data idx =
    let err = Printf.sprintf
      "Can't find PID at index '%d' in /proc/[pid]/stat file." idx in
    let datum = get_elem_exn data idx err in
    to_int_exn datum

  let parse_rss data idx pagesize =
    let err = Printf.sprintf
      "Can't find RSS at index '%d' in /proc/[pid]/stat file." idx in
    let datum = get_elem_exn data idx err in
    let pages = to_int_exn datum in
    pages * pagesize

  let stat_src_exn pid = 
    let stat_file = Printf.sprintf "/proc/%d/stat" pid in
    Files.to_string stat_file

  let stat_src pid =
    try
      let stat_file = Printf.sprintf "/proc/%d/stat" pid in
      let src = Files.to_string stat_file in
      Some src
    with
      | Files.NoSuchFile _ -> None
      | Files.CouldNotRead _ -> None
      | e -> raise e

  let create_record src =
    let pagesize = get_page_size in
    let data = String.split_on_char ' ' src in
    {
      pid = parse_pid data 0;
      rss = parse_rss data 23 pagesize;
    }

  (** Creates a [Stat.t] record. It gets the data by asking the kernel
      for statistics about a process (i.e., it reads /proc/[pid]/stat).

      Arguments:
      - A PID (int) to gather stats about.

      Returns: a {Stat.t} option. It will return [Some t] if it collected
      stats about the given [pid], or [None] if the kernel has no information
      about the requested [pid]. *)
  let create pid =
    match stat_src pid with
    | Some src -> Some (create_record src)
    | None -> None

  (** Creates a [Stat.t] record, just like {!Stat.create}, but this function
      can raise a [SysError("No such file...")] error if the kernel has
      no [/proc/[pid]/stat] record. *)
  let create_exn pid =
    let src = stat_src_exn pid in
    create_record src

end


module Cmd = struct

  let collect_output out_buf err_buf =
    Buff.fill out_buf; Buff.fill err_buf

  let collect_stats pid stats =
    match Stat.create pid with
    | Some s -> List.append [s] stats
    | None -> stats

  let rec while_waiting pid out_buf err_buf stats =
    match Proc.poll pid with
    | None ->
      collect_output out_buf err_buf;
      let new_stats = collect_stats pid stats in
      Unix.sleepf 0.25;
      while_waiting pid out_buf err_buf new_stats
    | Some n ->
      collect_output out_buf err_buf;
      let new_stats = collect_stats pid stats in
      n, new_stats

  (** Runs a command in a shell, returns the exit code, stdout, and stderr.

      Arguments:
      - A string (the command to execute in the shell)

      Returns: a 4-tuple composed of:
      - The exit code (an int)
      - A {!Buff.t} that contains the command's stdout.
        The contents can be retrieved with {!Buff.contents}.
      - A {!Buff.t} that contains the command's stderr.
        The contents can be retrieved with {!Buff.contents}.
      - A {!Ps.Stat.t} list that contains stats about the command
        which are collected as the command executes. *)
  let run cmd =
    let pid, stdout_ch, stderr_ch = Proc.popen cmd in
    let out_buf = Buff.create stdout_ch in
    let err_buf = Buff.create stderr_ch in
    let exit_code, stats = while_waiting pid out_buf err_buf [] in
    close_in stdout_ch;
    close_in stderr_ch;
    (exit_code, out_buf, err_buf, stats)

end
