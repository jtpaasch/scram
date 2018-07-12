# Scram

`scram` runs shell commands in a file and checks that they pass (execute successfully).

It is inspired by cram tests, hence the name.


## Requirements

* OCaml 4.05+

If you don't have OCaml on your system, run bash in a docker container that does. For instance:

```
$ docker run --rm -ti -v $(pwd):/srv -w /srv ocaml/opam:ubuntu-16.04_ocaml-4.06.0 bash
```


## Quick start

Build the tool, and then use it to check the sample markdown file 
[example.md](example.md).

```
git clone [this-repo]
cd [repo-dir]
make
bin/scram example.md
```

The file [example.md](example.md) describes all cases `scram` covers.

More detailed explanation/examples come next.

Build/install instructions are farther down, near the end of this README.


## Example: testing README.md files

Suppose you have a `README.md` which has some shell commands in it.
Something like this:

```
To print something to stdout, run the `echo` command:

    $ echo hello world

To print another message, try this:

    $ echo goodbye

```

To check this file, point the `scram` executable at it:

```
bin/scram README.md
```

`scram` will read the file, run the commands it finds in it, and
print output that looks something like this:

```
========================================
Test 'README.md'
----------------------------------------
To print something to stdout, run the `echo` command:

    $ echo hello world
    1> hello world
    [0]
    ==> OK (Exited with a 0 exit code)

To print another message, try this:

    $ echo goodbye
    1> goodbye
    [0]
    ==> OK (Exited with a 0 exit code)

========================================
Test: PASSED
```

You can see that `scram` echos back the contents of the file, but it
fills in information about the commands it ran. Note in particular:

* It prints the captured stdout, prefixed by `1>`
  (stderr gets prefixed by `2>`)
* It prints the captured exit codes in brackets, e.g., `[0]`
* It says if (and why) the commands succeed (or fail)

By default, commands that exit with a zero exit code pass.

The whole check passes if all commands in a file pass.

Note: a command must follow four spaces, a dollar sign, and another space.


## Non-zero exit codes

If a command exits with a non-zero exit code, it will fail.
Consider this `README.md`:

```
List the files:

    $ ls -z

```

This command tries to invoke `ls` with a `-z` option, but `-z` is not
a valid option for `ls`. So this should fail.

Check it with `scram`:

```
bin/scram README.md
```

`scram` will mark it a failure:

```
========================================
Test 'README.md'
----------------------------------------
List the files:

    $ ls -z
    2> ls: illegal option -- z
    2> usage: ls [-ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1] [file ...]
    [1]
    ==> FAILED (Non-zero exit code)

========================================
Test: FAILED
```


## Matching output exactly

You can specify what the output of the command ought to be, by writing
the expected output immediately below the command.
For instance, consider this `README.md`:

```
If you echo `hello world`, it should print `hello world` to stdout:

    $ echo hello world
    hello world

```

This asserts that the command `echo hello world` should output `hello world`.

Check it with `scram`:

```
bin/scram README.md
```

`scram` will mark this as `OK`, since the output is an exact match:

```
========================================
Test 'README.md'
----------------------------------------
If you echo `hello world`, it should print `hello world` to stdout:

    $ echo hello world
    hello world
    1> hello world
    [0]
    ==> OK (Output was as expected)

========================================
Test: PASSED
```

Suppose a command produces output that doesn't match. For instance,
consider this `README.md`:

```
This should output `goodbye`:

    $ echo hello
    goodbye

```

Check it with `scram`:

```
bin/scram README.md
```

`scram` will mark this as a failure, since the output doesn't match:

```
========================================
Test 'README.md'
----------------------------------------
This should output `goodbye`:

    $ echo hello
    goodbye
    1> hello
    [0]
    ==> FAILED (Unexpected output)

========================================
Test: FAILED
```


## Matching output with regular expressions

If you don't want exact matches, you can use regular expressions.
For example, consider this `README.md`:

```
If you echo `Today is: $(date)` from the command line,
the output should begin with `Today is`:

    $ echo Today is: $(date)
    ^Today is.*

```

Check it with `scram`:

```
bin/scram README.md
```

`scram` will mark the command `OK`, since the output matches
the regular expression:

```
========================================
Test 'README.md'
----------------------------------------
If you echo `Today is: $(date)` from the command line,
the output should begin with `Today is`:

    $ echo Today is: $(date)
    ^Today is.*
    1> Today is: Wed May 30 14:50:56 UTC 2018
    [0]
    ==> OK (Output was as expected)

========================================
Test: PASSED
```


## Profiling commands

You can tell `scram` to profile the execution time of a command.
To do that, put an asterisk before the command.

Consider this `README.md`:

```
Echo two lines:

    *$ echo "Lorem ipsum" && echo "dolor sit"

Echo two lines again:

    *$ echo "Lorem ipsum" && echo "sit dolor"

```

Note: The format is four spaces, an asterisk, a dollar sign,
another space, and then the command.


Check it with `scram`:

```
bin/scram README.md
```

`scram` will pause for a moment, before printing the output:

```
========================================
Test 'README.md'
----------------------------------------
Echo two lines:

    *$ echo "Lorem ipsum" && echo "dolor sit"
    1> Lorem ipsum
    1> dolor sit
    [0]
    ==> OK (Exited with a 0 exit code)

Echo two lines again:

    *$ echo "Lorem ipsum" && echo "sit dolor"
    1> Lorem ipsum
    1> sit dolor
    [0]
    ==> OK (Exited with a 0 exit code)

```

The pause occurs because `scram` runs each of the 
asterisk-marked commands a number of times to calculate
average running time. It also measures and averages
other statistics like memory usage (e.g., resident set size).

You can tell `scram` to print the profile stats with the
`#stats` directive. Alter the `README.md` so it looks like this:

```
Echo two lines:

    *$ echo "Lorem ipsum" && echo "dolor sit"

Echo two lines again:

    *$ echo "Lorem ipsum" && echo "sit dolor"

Print profiling statistics:

    #stats

```

Check it with `scram`:

```
bin/scram README.md
```

The output now looks something like this:

```
========================================
Test 'README.md'
----------------------------------------
Echo two lines:

    *$ echo "Lorem ipsum" && echo "dolor sit"
    1> Lorem ipsum
    1> dolor sit
    [0]
    ==> OK (Exited with a 0 exit code)

Echo two lines again:

    *$ echo "Lorem ipsum" && echo "sit dolor"
    1> Lorem ipsum
    1> sit dolor
    [0]
    ==> OK (Exited with a 0 exit code)

Print profiling statistics:

    #stats
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+
    | Id | Avg time | Total time | Trials | Avg # Stats | Avg RSS | Avg min RSS | Avg max RSS | Min RSS | Max RSS |
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+
    | 1  | 0.2509s  | 1.2547s    | 5      | 1           | 609Kb   | 609Kb       | 609Kb       | 4Kb     | 792Kb   |
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+
    | 2  | 0.2515s  | 1.2576s    | 5      | 1           | 518Kb   | 518Kb       | 518Kb       | 4Kb     | 904Kb   |
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+

========================================
Test: PASSED
```

In the stats table, the first row shows info about the
first asterisk-marked command, and the second row shows
info about the second asterisk-marked command.

You can also tell `scram` to print the output of the profiled commands
side by side, in case you want to visually compare them. To do this, 
use the `#diff` directive. Modify the `README.md` again:

```
Echo two lines:

    *$ echo "Lorem ipsum" && echo "dolor sit"

Echo two lines again:

    *$ echo "Lorem ipsum" && echo "sit dolor"

Print profiling statistics:

    #stats

Show the different output:

    #diff

```

Check it with `scram`:

```
bin/scram README.md
```

`scram` will print output that looks something like this:

```
========================================
Test 'README.md'
----------------------------------------
Echo two lines:

    *$ echo "Lorem ipsum" && echo "dolor sit"
    1> Lorem ipsum
    1> dolor sit
    [0]
    ==> OK (Exited with a 0 exit code)

Echo two lines again:

    *$ echo "Lorem ipsum" && echo "sit dolor"
    1> Lorem ipsum
    1> sit dolor
    [0]
    ==> OK (Exited with a 0 exit code)

Print profiling statistics:

    #stats
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+
    | Id | Avg time | Total time | Trials | Avg # Stats | Avg RSS | Avg min RSS | Avg max RSS | Min RSS | Max RSS |
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+
    | 1  | 0.2509s  | 1.2547s    | 5      | 1           | 609Kb   | 609Kb       | 609Kb       | 4Kb     | 792Kb   |
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+
    | 2  | 0.2515s  | 1.2576s    | 5      | 1           | 518Kb   | 518Kb       | 518Kb       | 4Kb     | 904Kb   |
    +----+----------+------------+--------+-------------+---------+-------------+-------------+---------+---------+

Show the different output:

    #diff
    ---------------- [ echo "Lorem ... ]
    1> Lorem ipsum
    1> dolor sit
    ---------------- [ echo "Lorem ... ]
    1> Lorem ipsum
    1> sit dolor

========================================
Test: PASSED
```


## Summary of syntax

* `scram` sees any empty line, or any line that consists only of
  whitespace characters, as a blank line.
* `scram` sees any fully left-justified lines as commentary.
* `scram` identifies commands by looking exactly for strings
  that follow four spaces, a dollar sign, and another space,
  i.e.,`[space][space][space][space][dollar-sign][space][command-string]`.
* `scram` identifies commands to profile by looking exactly
  for strings that follow four spaces, an asterisk, a dollar sign,
  and another space, i.e.,
  `[space][space][space][space][asterisk][dollar-sign][space][command-string]`.
* Lines of expected output (literal or regular expression) must 
  be indented four spaces, and they must immediately follow 
  a command (or a command marked by an asterisk).
* The stats directive is the string `#stats`, indented four spaces.
* The diff directive is the string `#diff`, indented four spaces.


## Build and install

To build and install, you need OCaml 4.05+.

If you don't have OCaml on your system, run bash in a docker container that does. For instance:

```
$ docker run --rm -ti -v $(pwd):/srv -w /srv ocaml/opam:ubuntu-16.04_ocaml-4.06.0 bash
```

Clone the repo, then from the root of the repo:

```
make
```

The runnable executable will be created inside the repo,
at `bin/scram`. Confirm it:

```
bin/scram --help
```

You may install the executable wherever you like. There are
no dependencies.

This of course can be done in an ocaml docker container.


## Usage

To run `scram`, point the runner (the executable) to a file, for instance:

```
bin/scram example.md
```

`scram` will then run `example.md`, and print the results to the screen.


## Number of trials

As mentioned above, `scram` profiles a command by running it a number
of times and then calculating its average running time.

You can change the number of trials with the `--num-trials` parameter.
For instance, to profile a command by running it through 10 time trials:

```
bin/scram example.md --num-trials 10
```


## Logs

By default, `scram` sends its main output to stdout, and it sends
any error messages to stderr. You may specify different places
for these. For example, you can send them to files:

```
bin/scram example.md --main-log out.log --error-log err.log
```

Other valid log destinations are `stdout`, `stderr`, `/dev/null`, or a
filepath.

`scram` also has a verbose log, which by default sends its messages
to `/dev/null`. You can send the verbose log to stdout:

```
bin/scram example.md --verbose-log stdout
```

Or any other valid log destination, like a file:

```
bin/scram example.md --verbose-log verbose.log
```

## Library docs

The `make` command builds the OCaml code documentation, which is placed
in a `docs` folder, at the root of the repo.


## Clean

Run `make clean` to delete the `build`, `bin`, and `docs` directories.
