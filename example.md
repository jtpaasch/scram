Any lines that are fully left-justified are considered commentary.
You can write as much commentary as you like.

You can also put CLI commands in the file. Commands should be indented
4 spaces, followed by a dollar sign and a space. For example:

    $ echo hello world

If a command doesn't return a 0 exit code, the command will fail.
For example, `ls` has no `-z` option, so this should fail:

    $ ls -z

You can specify the output you expect the command to print to stdout.
To do that, simply write the output immediately after the command.
It should be indented four spaces. For example, this says you expect
the command `echo hello again` to print `hello again` to stdout.

    $ echo hello again
    hello again

You can use regular expressions when you specify the output you expect.
For example, the following says you expect the command's output to start
with `hello`, followed by a space, and then any other characters.

    $ echo hello one more time
    ^hello .*

If a command doesn't produce output that matches what you write below
the command, the command will fail. For instance, here you say that you
expect the output to be `hello`, but of course it will print `goodbye`.

    $ echo goodbye
    hello

If any commands in the file fail, the whole file is considered to fail.
The file is considered to pass if all commands succeed without failure.

You can have `scram` profile a command. To do that, put an asterisk
before the command (so four spaces, one asterisk, then the dollar sign
and a space):

    *$ echo lorem ipsum && echo dolor sit amet

When `scram` executes that command, it will execute the command a number
of times and then compute its average running time. It will also
collect memory statistics (like the resident set size).

You can tell `scram` to profile as many commands as you like. Here
is another one:

    *$ echo lorem ipsum && echo dolor sit

You can tell `scram` to print out the profile statistics. To do that,
use the `#stats` directive (indented 4 spaces):

    #stats

When you run this file with `scram`, `scram` will print out a table of
the profile statistics for all commands marked with an asterisk up to
this point in the file.

You can also tell `scram` to print out the output it's collected from the
profiled commands, in case you want to see how they differ.
Do this with the `#diff` directive (indented 4 spaces):

    #diff
