(** The main program CLI/interface.

    This program takes a file (like a README.md file) as input. It reads
    the file, and executes any shell commands it finds in it. Finally,
    it prints out the contents of the file, with the output/results of
    the commands pasted in.

    If all commands in the file succeed, it reports success. If any
    commands do not succeed, it reports failure.

    For example, suppose you have a README.md file with these contents:

    {[
      Here are some examples of bash commands.

      First, print a message to the screen:

        $ echo hello world

      That should print the words "hello world" on the next line:

        $ echo hello world
        hello world

      That is the end of the examples.
    ]}

    If you run this program on that file, it will read the file,
    execute the shell commands in it, and print out something
    like this:

    {[
      ========================================
      Test 'README.md'
      ----------------------------------------
      Here are some examples of bash commands.

      First, print a message to the screen:

        $ echo hello world
	1> hello world
	[0]
	==> OK (Exited with a 0 exit code)

      That should print the words "hello world" on the next line:

        $ echo hello world
        hello world
	1> hello again
	[0]
	==> OK (Output was as expected)
	
      That is the end of the examples.
      ========================================
      Test: PASSED
    ]}
    
    For a fuller description of usage, see the README.md.

    Processing modules:
    - This program first uses the {!Files} module to open and read
    the input file.
    - Then it uses the {!Lexer} module to break the source lines
    up into tokens. E.g., it breaks up the file into chunks of blank lines,
    commentary lines, and shell commands that can be executed.
    - It next uses the {!Ast} module to build an AST of nodes from
    the tokens. The AST is very simple: it is really just a sequence
    of nodes. Some are blank lines nodes, some are commentary nodes,
    and some are shell command nodes.
    - It then uses the {!Eval} module to evaluate the AST. To do this,
    it goes through the nodes in the AST, and it executes any shell
    command nodes in the AST. When it executes the commands, it captures
    their exit codes, stdout, stderr, and the like. It then builds
    a list of {!Result} nodes, which are basically just copies of
    the AST nodes, decorated with any captured command output.
    - Finally, the {!Printer} module walks the {!Result} nodes and
    constructs a pretty-printable version of the data. The program
    prints that to the screen.

    Data modules:
    - {!Token_type}: these are the types of tokens the {!Lexer} can
    identify in source files.
    - {!Token}: these represent concrete tokens that the {!Lexer} finds
    in a source file.
    - {!Node}: these represent AST nodes that the {!Ast} module builds
    from {!Token}s.
    - {!Result}: these represent the AST nodes, after they have been
    executed/evaluated. As noted already, they are basically just copies
    of {!Node}s, but they are decorated with any output captured from
    the executed commands.

    Accessory modules:
    - {!Matcher}: A simple module that helps match strings literally
    and with regular expressions.
    - {!Success}: this packages the success (a boolean) of a command
    with the reason why it succeeded or failed.
    - {!Execution}: this executes shell commands, and packages up
    information about the execution (like the exit code, stdout/stderr).
    - {!Trials}: this module profiles the execution time of a command.
    To do this, it runs the command a number of times, and then
    calculates the average running time. The average time, and the
    execution trials, are all packed up by this module.
    - There are a few [*_printer] modules, which generate pretty-printable
    versions of tokens, nodes, and results.

    Some utilities:
    - The {!Logs} module provides logging functions.
    - The {!Ps} module provides the low-level utilities for running shell
    commands and capturing the relevant output.
    - The {!Tty_str} module provides a way to package TTY formatting
    up with strings, so that the strings can be formatted when they
    need to be printed to a TTY.
    - The {!Tty_table} module provides a way to format a list of
    strings into a TTY-printable table.

    Logs:
    - Main log: the primary output of the program is sent here. By
    default, this log writes to stdout.
    - Error log: errors are sent here. By default this log writes to stderr.
    - Verbose log: detailed information about all processing goes here.
    By default, this log writes to /dev/null.
    - The target of these logs can be changed through command line
    arguments. For instance, the verbose log can be sent to stdout,
    or the main log can be sent to a file.

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
      Files.to_lines !src_file
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
