# Scram

A simple cram-like test runner. The syntax for tests is roughly
similar to that of cram tests.

For an overview of the syntax, see [example-test.t](example-test.t).


## Build

Clone the repo, then from the root of the repo:

    make

The runnable executable will be created at `bin/scram`. Confirm it:

    bin/scram --help


## Usage

Run the command and point it to a cram-like test file:

    bin/scram example-test.t

This will print out the contents of the test, with the results
filled in.

The test runner will capture any stdout/stderr produced by the commands
in the test. It will print that out too in the results. Lines in the
results that are prefixed by `1> ` are captured from stdout, and
`2> ` from stderr.


## Logs

By default, the runner will send its main output to stdout, and it will
send any error messages to stderr. You may specify different places
for these. For example, you can send these to files:

    bin/scram example-test.t --main-log out.log --error-log err.log

The runner also has a verbose log, which by default sends its messages
to `/dev/null`. You can send this to stdout:

    bin/scram example-test.t --verbose-log stdout

Or a file:

    bin/scram example-test.t --verbose-log verbose.log


## Library docs

The `make` command builds the OCaml code documentation, which is placed
in a `docs` folder, at the root of the repo.


## Clean

Run `make clean` to delete the `build`, `bin`, and `docs` directories. 