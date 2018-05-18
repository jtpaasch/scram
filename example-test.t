Comment lines have no spaces on the far left. They are fully
left-justified lines. So this line and the one above it are comments.

A command is indented 2 spaces, with a dollar sign and another space,
then the command. If it produces an exit code of 0, the test will pass.

  $ echo hello world

You can specify the command's expected output on the lines after the
command. Expected output must be indented two spaces. If the command
produces output that doesn't match the expected output, the test will fail.

  $ echo hello again
  hello again

You can use regular expressions in your expected output.

  $ echo hello one more time
  ^hello .*

Literal matches are checked for first, then regular expressions.