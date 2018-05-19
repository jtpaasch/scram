Comment lines are fully left-justified. They have no spaces on the
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