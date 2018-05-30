# Scram

`scram` runs shell commands in a file and checks that they pass (execute successfully).

It is inspired by cram tests, hence the name.


## Quick start

Build the tool (assuming you have OCaml 4.05+), and then
use it to check the sample markdown file [example.md](https://raw.githubusercontent.com/jtpaasch/scram/master/example.md).

```
git clone [this-repo]
cd [repo-dir]
make
bin/scram example.md
```

The file [example.md](https://raw.githubusercontent.com/jtpaasch/scram/master/example.md) describes all cases `scram` covers.

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

Note: a command must follow two spaces, a dollar sign, and another space.


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

`scram` will mark this as `Ok`, since the output is an exact match:

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

`scram` will mark the command `Ok`, since the output matches
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

Note: The format is one space, an asterisk, a dollar sign,
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
average running time.

You can tell `scram` to print the profile stats with the
`#stats` directive. Alter the `README.md` so it looks like this:

```
Echo two lines:

 *$ echo "Lorem ipsum" && echo "dolor sit"

Echo two lines again:

 *$ echo "Lorem ipsum" && echo "sit dolor"

Print info about how long these commands take to run:

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

Print info about how long these commands take to run:

  #stats
  +----+----------+------------+------------+
  | Id | Avg time | Total time | Num trials |
  +----+----------+------------+------------+
  | 1  | 0.2514   | 1.2569     | 5          |
  +----+----------+------------+------------+
  | 2  | 0.2511   | 1.2553     | 5          |
  +----+----------+------------+------------+

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

Print info about how long these commands take to run:

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

Print info about how long these commands take to run:

  #stats
  +----+----------+------------+------------+
  | Id | Avg time | Total time | Num trials |
  +----+----------+------------+------------+
  | 1  | 0.2514   | 1.2569     | 5          |
  +----+----------+------------+------------+
  | 2  | 0.2511   | 1.2553     | 5          |
  +----+----------+------------+------------+

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

* `scram` sees any line that has zero or more whitespace 
  characters as a blank line, which it ignores.
* `scram` sees any fully left-justified lines as commentary, 
  which it ignores.
* `scram` identifies commands by looking exactly for strings
  that follow two spaces, a dollar sign, and another space,
  i.e.,`[space][space][dollar-sign][space][command-string]`.
* `scram` identifies commands to profile by looking exactly
  for strings that follow one space, an asterisk, a dollar sign,
  and another space, i.e.,
  `[space][asterisk][dollar-sign][space][command-string]`.
* Lines of expected output (literal or regular expression) must 
  be indented two spaces, and they must immediately follow 
  a command (or a profiled command).
* The stats directive is the string `#stats`, indented two spaces.
* The diff directive is the string `#diff`, indented two spaces.


## Build and install

To build and install, you need OCaml 4.05+.

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
