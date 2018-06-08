(** Generates tables that can be printed to a tty.

    For example, create a table from a list of rows:

    {[
      let table = create [
        ["col 1"; "col 2"; "col 3"];
	["1"; "foo"; "bar"];
	["2"; "biz"; "baz"];
      ];;
    ]}

    The result is a list of strings. Print them:

    {[
      List.map (Printf.printf "%s\n%!") table
    ]}

    That will output:

    {[
      +-------+-------+-------+
      | col 1 | col 2 | col 3 |
      +-------+-------+-------+
      | 1     | foo   | bar   |
      +-------+-------+-------+
      | 2     | biz   | baz   |
      +-------+-------+-------+
    ]}
    
*)

(** Takes a list of rows (each row is a list of strings).
    Returns the table as a list of strings.

    Arguments:
    - A list of rows (a list of string list).

    Returns: a list of strings. *)
val create : string list list -> string list