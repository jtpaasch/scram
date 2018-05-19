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

    If you leave off [~for_tty:true] (or specify [~for_tty:false]),
    then the string will not have any ASCII formatting tags inserted
    into it. It will just be the plain string "Some text". *)

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

(** Creates a [Tty_str] record. Here are some examples:
    - [create "A plain string"]
    - [create ~fmt:Red "A red string"]
    - [create ~fmt:Bold "A bold string"] *)
val create : ?fmt:ttyfmt -> string -> t

(** Constructs a string from a [Tty_str] object. If you specify
    [~for_tty:true], then the appropriate ASCII formatting tags
    will be inserted into the final string. Otherwise, no ASCII
    tags are inserted into the result. *)
val string_of : ?for_tty:bool -> t -> string
