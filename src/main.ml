(** The main program CLI/interface. *)

let program_name = "scram"

let verbose_log_target = ref "/dev/null"
let main_log_target = ref "stdout"
let error_log_target = ref "stderr"

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
  Logs.log "verbose" (Printf.sprintf "- Starting %s." program_name);

  (* Make sure a test file was specified. *)
  match String.trim !test_file with
  | "" ->
    Logs.log "error" 
      (Printf.sprintf "Specify a TEST FILE. See '%s --help'." program_name);
    exit 2
  | _ -> ();

  (* Open/read the test file. *)
  Logs.log "verbose" (Printf.sprintf "- Opening test file: '%s'." !test_file);
  let src =
    try
      Files.load !test_file
    with _ ->
      let msg =
        Printf.sprintf "Error: couldn't open '%s'. See '%s --help'."
        !test_file program_name in
      Logs.log "error" msg;
      exit 2
    in

  let header = Printer.header !test_file in
  Logs.log "main" header;

  Logs.log "verbose" "|------------- CONTENTS";
  List.iter (fun l ->
    let raw_str = Printf.sprintf "| %s" l in
    Logs.log "verbose" raw_str
  ) src;
  Logs.log "verbose" "|------------ END CONTENTS";

  (** Tokenize the file. *)
  Logs.log "verbose" "- Breaking up file into tokens.";
  Logs.log "verbose" "|------------- TOKENS";
  let tokens = Lexer.tokenize src [] in

  List.iter (fun a ->
    let token_str = Token.string_of a in
    Logs.log "verbose" token_str
  ) tokens;
  Logs.log "verbose" "|-------- END TOKENS";

  (** Build an AST from the tokens. *)
  Logs.log "verbose" "- Constructing an AST from the tokens.";
  Logs.log "verbose" "|------------- AST NODES";
  let nodes = Ast.build tokens [] in

  List.iter (fun a ->
    let node_str = Node.string_of a in
    Logs.log "verbose" node_str
  ) nodes;
  Logs.log "verbose" "|-------- END AST NODES";

  (** Run/evaluate the AST. *)
  Logs.log "verbose" "- Executing/evaluating the AST.";
  Logs.log "verbose" "|------------- RESULTS";
  let results = Eval.run nodes [] in

  List.iter (fun a ->
    let result_str = Result.string_of a in
    Logs.log "verbose" result_str
  ) results;
  Logs.log "verbose" "|-------- END AST NODES";
  Logs.log "verbose" "";

  let final_output = Printer.test results in
  Logs.log "main" final_output;

  let success = Result.is_successful results in
  let footer = Printer.footer success in
  Logs.log "main" footer;

  let exit_code = match success with
  | true -> 0
  | false -> 1 in
  exit exit_code

let () = Unix.handle_unix_error main ()
