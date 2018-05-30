(** The main program CLI/interface. *)

let program_name = "scram"

let verbose_log_target = ref "/dev/null"
let main_log_target = ref "stdout"
let error_log_target = ref "stderr"
let num_trials = ref 5
let test_file = ref ""

(** Setup the CLI arguments/options. *)
let cli () =
  let usage = Printf.sprintf
    "USAGE: %s [options] TEST_FILE\n\n  Run a scram TEST_FILE.\n\nOPTIONS:"
    program_name in
  let specs = [

    ("--verbose-log", Arg.Set_string verbose_log_target,
     "Where to send the verbose log. Default: /dev/null");

    ("--main-log", Arg.Set_string main_log_target,
     "Where to send the main log. Default: stdout");

    ("--error-log", Arg.Set_string error_log_target,
     "Where to send the error log. Default: stderr");

    ("--num-trials", Arg.Set_int num_trials,
     "Num times to run profiled commands. Default: 5");

  ] in
  Arg.parse specs (fun a -> test_file := a) usage

(** The main entrypoint to the program. *)
let main () =

  (* Make sure to quit through [exit], so all exit handlers are called. *)
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
  let msg = Printf.sprintf "---------------- Starting %s\n" program_name in
  let msg_ttystr = Tty_str.create ~fmt:Tty_str.Bold msg in
  Logs.log "verbose" [msg_ttystr];

  (* Make sure a test file was specified. *)
  match String.trim !test_file with
  | "" ->
    let msg =
      Printf.sprintf "Specify a TEST FILE. See '%s --help'." program_name in
    let msg_ttystr = Tty_str.create ~fmt:Tty_str.Red msg in
    Logs.log "error" [msg_ttystr];
    exit 2
  | _ -> ();

  (* Open/read the test file. *)
  let msg = Printf.sprintf "- Opening test file: '%s'" !test_file in
  let msg_ttystr = Tty_str.create msg in
  Logs.log "verbose" [msg_ttystr];

  let src =
    try
      Files.load !test_file
    with _ ->
      let msg =
        Printf.sprintf "Error: couldn't open '%s'. See '%s --help'."
        !test_file program_name in
      let msg_ttystr = Tty_str.create ~fmt:Tty_str.Red msg in
      Logs.log "error" [msg_ttystr];
      exit 2
    in
  Logs.log "verbose" [(Tty_str.create "- File opened/read.\n")];

  let file_output = File_printer.pprint src in
  Logs.log "verbose" file_output;

  let tokens = Lexer.tokenize src [] in
  let tokens_output = Token_printer.pprint tokens in
  Logs.log "verbose" tokens_output;

  let nodes = Ast.build tokens [] in
  let nodes_output = Node_printer.pprint nodes in
  Logs.log "verbose" nodes_output;

  let results = Eval.run nodes !num_trials [] in
  let results_output = Result_printer.pprint results in
  Logs.log "verbose" results_output;

  let success = Result.is_successful results in

  let test_output = Printer.pprint !test_file results success in
  Logs.log "main" test_output;

  let exit_code = match success with
  | true -> 0
  | false -> 1 in
  exit exit_code

let handle_errors f () =
  Printexc.register_printer
    (function
      | Logs.NoSuchLog msg -> Some (Printf.sprintf "%s" msg)
      | Ast.InvalidToken msg -> Some (Printf.sprintf "%s" msg)
      | Result.InvalidNode msg -> Some (Printf.sprintf "%s" msg)
      | Eval.InvalidNode msg -> Some (Printf.sprintf "%s" msg)
      | Printer.InvalidResult msg -> Some (Printf.sprintf "%s" msg)
      | _ -> None
    );
  try
    Unix.handle_unix_error f ()
  with e ->
    let msg = Printexc.to_string e in
    Printf.printf "Error. %s\n%!" msg;
    exit 1

let () = handle_errors main ()
