To run a command, put it after a dollar sign, indented two spaces.

  $ echo hello world

To profile a command, put an asterisk before it.

 *$ echo hey

Another command to profile:

 *$ echo boo

To print stats about the profiled commands, use the "#stats" directive.

  #stats

To print a diff of the profiled commands' output, use the "#diff" directive.

  #diff
