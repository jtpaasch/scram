(** A utility for creating strings with TTY formatting. To create a
    [Tty_str] string, use the [create] function, and specify a
    {t.ttyfmt} format. For example, to make a string "Some text"
    with a red color:

    {[  let msg = Tty_str.create ~fmt:Red "Some text.";; ]}

    When you're ready to use this as a string, convert it to a string:

    {[  let msg_str = Tty_str.string_of ~for_tty:true msg;; ]}

    That will generate a string, with the proper ASCII formatting tags
    inserted at the beginning and end of the string. You can print
    this in a TTY, and it will display red. 

    If you leave off [~for_tty:true] (or specify [~for_tty:false]), then
    it will not have any ASCII formatting tags inserted into it. If you
    print it (even in a TTY), it will just be the plain string "Some text",
    without any red color. *)

(** The different formatting options. *)
type ttyfmt =
    | Plain
    | Red
    | Green
    | Yellow
    | Bold
    | Dim
    | Italic
    | Underline

(** Each [Tty_str] record carries with it the string contents
    (the [data] field) and a format (the [fmt] field). *)
type t = { fmt : ttyfmt; data: string }                                      

(** Creates a [Tty_str] record. 

    Arguments:
    - [?fmt:ttyfmt] - An optional format from the [ttyfmt] type above.
    - The string to represent.

    Returns: a {!Tty_str.t}. 

    Here are some examples:
    - [create "A plain string"]
    - [create ~fmt:Red "A red string"]
    - [create ~fmt:Bold "A bold string"] *)
val create : ?fmt:ttyfmt -> string -> t

(** Constructs a string from a [Tty_str] object. 

    Arguments:
    - [?for_tty:bool] - Indicates whether the string is meant for a TTY.
    If so, the appropriate ASCII formatting tags are inserted into
    the returned string. Otherwise, no ASCII tags are inserted, and the
    returned string is just the plain string. 
    - A {!Tty_str.t} string to generate a string from. 

    Returns: a string that can be printed in a TTY or other target. *)
val string_of : ?for_tty:bool -> t -> string
