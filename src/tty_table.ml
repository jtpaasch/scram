(* A utility for building a table that can be printed on a TTY.
   Use it by calling [create], and passing it a list of string lists.
   The argument is a list of rows, where each row is a list of strings.
   The [create] function returns a string you can print to a TTY. *)

let rec range n acc =
  let len = List.length acc in
  match len < n with
  | false -> acc
  | true -> range n (List.append acc [len])

let width rows =
  match rows with
  | [] -> 0
  | _ ->
    match List.nth rows 0 with
    | [] -> 0
    | row -> List.length row

let rec longest items res =
  match items with
  | [] -> res
  | hd :: tl ->
    match hd > res with
    | true -> longest tl hd
    | false -> longest tl res

let get_cols idx rows =
  List.map (fun r -> List.nth r idx) rows

let pad len s =
  let len_to_pad = len - (String.length s) in
  let padding = String.init len_to_pad (fun _ -> ' ') in
  String.concat "" [s; padding]

let dashes n = String.init n (fun _ -> '-')

let longest_cell idx rows =
  let cols = get_cols idx rows in
  let widths = List.map String.length cols in
  longest widths 0

let build_border widths =
  let borders = List.map (fun width ->
    let line_of_dashes = dashes width in
    Printf.sprintf "+-%s-" line_of_dashes
  ) widths in
  let joined_borders = String.concat "" borders in
  Printf.sprintf "%s+" joined_borders

let build_cells idxs widths row =
  let cells = List.map (fun idx ->
    let width = List.nth widths idx in
    let cell = List.nth row idx in
    let padded_cell = pad width cell in
    Printf.sprintf "| %s " padded_cell
  ) idxs in
  let joined_cells = String.concat "" cells in
  Printf.sprintf "%s|" joined_cells

let build_row idxs widths row =
  let border = build_border widths in
  let cells = build_cells idxs widths row in
  [border; cells]

let build_lines idxs widths rows =
  let rows = List.map (build_row idxs widths) rows in
  let border = build_border widths in
  let all_lines = List.flatten rows in
  List.append all_lines [border]

let create rows =
  let num_cols = width rows in
  let idxs = range num_cols [] in
  let widths = List.map (fun idx -> longest_cell idx rows) idxs in
  build_lines idxs widths rows
