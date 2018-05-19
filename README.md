# Scram

A simple cram-like test runner. The syntax for tests are inspired (roughly)
by cram tests.

Here is an example test, lifted from [example-test.t](example-test.t):

```
Comment lines are fuly left-justified. They have no spaces on the
left. This line and the one before are comments.

A command follows two spaces, a dollar sign, and another space.

  $ echo hello world

If a command doesn't return a 0 exit code, it will fail.

  $ ls -z

You can specify the command's expected output immediately after a
command. It should be indented two spaces.

  $ echo hello again
  hello again

You can use regular expressions.

  $ echo hello one more time
  ^hello .*

If a command doesn't produce output that matches, the test will fail.

  $ echo goodbye
  hello

If any commands in the file don't pass, the whole test will fail.
```

To run that test, point the `scram` test runner (the executable) at it:

```
bin/scram example-test.t
```

`scram` will then print to the screen output that looks like this:

```
========================================
Test 'example-test.t'
----------------------------------------
Comment lines are fuly left-justified. They have no spaces on the
left. This line and the one before are comments.

A command follows two spaces, a dollar sign, and another space.

  $ echo hello world
  1> hello world
  [0]
  ==> OK (Exited with a 0 exit code)

If a command doesn't return a 0 exit code, it will fail.

  $ ls -z
  2> ls: illegal option -- z
  2> usage: ls [-ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1] [file ...]
  [1]
  ==> FAILED (Non-zero exit code)

You can specify the command's expected output immediately after a
command. It should be indented two spaces.

  $ echo hello again
  hello again
  1> hello again
  [0]
  ==> OK (Output was as expected)

You can use regular expressions.

  $ echo hello one more time
  ^hello .*
  1> hello one more time
  [0]
  ==> OK (Output was as expected)

If a command doesn't produce output that matches, the test will fail.

  $ echo goodbye
  hello
  1> goodbye
  [0]
  ==> FAILED (Unexpected output)

If any commands in the file don't pass, the whole test will fail.

========================================
Test: FAILED
```

You can see that `scram` prints the contents of the test, but it fills
in information about the commands in the file that it ran. Note
in particular:

* Captured stdout is prefixed by `1>`
* Captured stderr is prefixed by `2>`
* Captured exit codes are wrapped in brackets, e.g., `[0]`
* It says if (and why) each command succeed or failed


## Build and install

To build and install, you need OCaml 4.06+.

Clone the repo, then from the root of the repo:

    make

The runnable executable will be created at `bin/scram`. Confirm it:

    bin/scram --help

You may install the executable wherever you like. There are
no dependencies.


## Usage

To run `scram`, point the runner (the executable) to a cram-like test file:

    bin/scram example-test.t

`scram` will run the test in `example-test.t`, and print the results
to the screen, as describe above.


## Logs

By default, `scram` sends its main output to stdout, and it sends
any error messages to stderr. You may specify different places
for these. For example, you can send them to files:

    bin/scram example-test.t --main-log out.log --error-log err.log

Other valid log destinations are `stdout`, `stderr`, `/dev/null`, or a
filepath.

`scram` also has a verbose log, which by default sends its messages
to `/dev/null`. You can send the verbose log to stdout:

    bin/scram example-test.t --verbose-log stdout

Or a file:

    bin/scram example-test.t --verbose-log verbose.log


## Library docs

The `make` command builds the OCaml code documentation, which is placed
in a `docs` folder, at the root of the repo.


## Clean

Run `make clean` to delete the `build`, `bin`, and `docs` directories.
