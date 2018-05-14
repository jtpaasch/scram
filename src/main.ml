(** The main program CLI/interface. *)

let program_name = "scram"

let verbose_log_target = ref "/dev/null"
let main_log_target = ref "stdout"
let error_log_target = ref "stderr"

let test_file = ref ""

(** Setup the CLI arguments/options. *)
let cli () =
  let usage = Printf.sprintf
    "USAGE: %s [options] TEST_FILE\n\n  Run scram tests.\n\nOPTIONS:"
    program_name in
  let specs = [
    ("--verbose-log", Arg.Set_string verbose_log_target,
     "Where to send the verbose log. Default: /dev/null");
    ("--main-log", Arg.Set_string main_log_target,
     "Where to send the main log. Default: stdout");
    ("--error-log", Arg.Set_string error_log_target,
     "Where to send the error log. Default: stderr");
  ] in
  Arg.parse specs (fun a -> test_file := a) usage

(** The main entrypoint to the program. *)
let main () =

  (* Make sure to go through [exit], so all exit handlers are called. *)
  Sys.(set_signal sighup (Signal_handle exit));
  Sys.(set_signal sigint (Signal_handle exit));

  (* Parse the command line parameters. *)
  cli ();

  (* Set up some log channels. *)
  Logs.create "verbose" !verbose_log_target;
  Logs.create "main" !main_log_target;
  Logs.create "error" !error_log_target;
  at_exit Logs.close_all;

  (* Start reporting to the verbose log. *)
  Logs.log "verbose" (Printf.sprintf "Starting %s." program_name);

  (* Make sure a test file was specified. *)
  match String.trim !test_file with
  | "" ->
    Logs.log "error" 
      (Printf.sprintf "Specify a TEST FILE. See '%s --help'." program_name);
    exit 2
  | _ -> ();

  (* Open/read the test file. *)
  Logs.log "verbose" (Printf.sprintf "Opening test file: '%s'." !test_file);
  let src =
    try
      Files.load !test_file
    with _ ->
      Logs.log "error" (Printf.sprintf "Couldn't open: '%s'." !test_file);
      exit 2
    in

  Logs.log "verbose" (Printf.sprintf "Contents of file '%s':" !test_file);
  Logs.log "verbose" "------";
  List.iter (fun l -> Logs.log "verbose" l) src;
  Logs.log "verbose" "------"

let () = Unix.handle_unix_error main ()
