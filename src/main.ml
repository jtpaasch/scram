(** The main program CLI/interface.

    This program takes a file as input. It then reads the file
    into a string of lines, which it parses as follows:
    - It first uses the {!Lexer} module to break the source lines up
    into tokens. E.g., it breaks up the file into chunks of blank lines,
    commentary lines, and shell commands that can be executed.
    - It next uses the {!Ast} module to build an AST of nodes from
    the tokens. The AST is very simple: it is really just a sequence
    of nodes.
    - It then uses the {!Eval} module to evaluate the AST. To do this,
    it goes through the nodes in the AST, and it executes any shell
    commands in the AST. When it executes the commands, it captures
    their exit codes, stdout, stderr, and the like. It then builds
    a list of {!Result} nodes, which are basically just copies of
    the AST nodes, decorated with the captured command output.
    - Finally, this program walks the {!Result} nodes and prints the
    data to the screen.

    Primary modules:
    - {!Token_type}: these are the types of tokens the {!Lexer} can
    identify in source files.
    - {!Token}: these represent concrete tokens that the {!Lexer} finds
    in a source file.
    - {!Node}: these are AST nodes that the {!Ast} module builds from
    {!Token}s.
    - {!Result}: these represent the AST nodes, after they have been
    executed/evaluated. As noted already, they are basically just copies
    of {!Node}s, but they are decorated with any output captured from
    the executed commands.

    Accessory modules:
    - {!Matcher}: A simple module that helps match strings literally
    and with regular expressions.
    - {!Success}: this packages the success (a boolean) of a command
    with the reason why (a string) it succeeded or failed.
    - {!Execution}: this packages up information about the execution
    of a shell command, e.g., it includes its stdout, stderr, exit code,
    and running/execution time.
    - {!Trials}: this program can profile the execution time of a command.
    When it does so, it runs the command a number of times, and then
    calculates the average running time. The average time, and the trials,
    are all handled by this {!Trials} module.

    Some utilities:
    - The {!Logs} module provides logging functions.
    - The {!Ps} module provides the low-level utilities for running shell
    commands and capturing the relevant output.
    - The {!Tty_str} module provides a way to package TTY formatting
    up with strings, so that the strings can be formatted when they
    need to be printed to a TTY.
    - The {!Tty_table} module provides a way to format a list of
    strings into a TTY-printable table.

*)

let program_name = "scram"

let verbose_log_target = ref "/dev/null"
let main_log_target = ref "stdout"
let error_log_target = ref "stderr"
let num_trials = ref 5
let src_file = ref ""

(** Setup the CLI arguments/options. *)
let cli () =
  let usage = Printf.sprintf
    "USAGE: %s [options] SRC_FILE\n\n  Check the shell commands in a SRC_FILE.\n\nOPTIONS:"
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
  Arg.parse specs (fun a -> src_file := a) usage

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

  (* Make sure a source file was specified. *)
  match String.trim !src_file with
  | "" ->
    let msg =
      Printf.sprintf "Specify a SRC FILE. See '%s --help'." program_name in
    let msg_ttystr = Tty_str.create ~fmt:Tty_str.Red msg in
    Logs.log "error" [msg_ttystr];
    exit 2
  | _ -> ();

  (* Open the source file. *)
  let msg = Printf.sprintf "- Opening test file: '%s'" !src_file in
  let msg_ttystr = Tty_str.create msg in
  Logs.log "verbose" [msg_ttystr];

  (** Read the source file. *)
  let src =
    try
      Files.load !src_file
    with _ ->
      let msg =
        Printf.sprintf "Error: couldn't open '%s'. See '%s --help'."
        !src_file program_name in
      let msg_ttystr = Tty_str.create ~fmt:Tty_str.Red msg in
      Logs.log "error" [msg_ttystr];
      exit 2
    in
  Logs.log "verbose" [(Tty_str.create "- File opened/read.\n")];

  let file_output = File_printer.pprint src in
  Logs.log "verbose" file_output;

  (** Break the source lines up into tokens. *)
  let tokens = Lexer.tokenize src [] in
  let tokens_output = Token_printer.pprint tokens in
  Logs.log "verbose" tokens_output;

  (** Build an AST from the tokens. *)
  let nodes = Ast.build tokens [] in
  let nodes_output = Node_printer.pprint nodes in
  Logs.log "verbose" nodes_output;

  (** Execute/evaluate the AST. *)
  let results = Eval.run nodes !num_trials [] in
  let results_output = Result_printer.pprint results in
  let success = Result.is_successful results in
  Logs.log "verbose" results_output;

  (** Print the final results to the main log. *)
  let test_output = Printer.pprint !src_file results success in
  Logs.log "main" test_output;

  (** Exit with the correct exit code. *)
  let exit_code = match success with
  | true -> 0
  | false -> 1 in
  exit exit_code

(** Handle custom errors, and any unix errors. *)
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
