(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)
exception Invalid_format of string
open Unix

let file_out filename f =
  let file = open_out filename in
  let x = f file in
  close_out file;
  x

let file_out_gzip filename f =
  let file = Gzip.open_out filename in
  let x = f file in
  Gzip.close_out file;
  x

let file_out_append filename f =
  let file = open_out_gen [Open_wronly; Open_append; Open_creat] ((6*8+4)*8+4) filename in
  let x = f file in
  close_out file;
  x

let file_in filename f =
  let file = open_in filename in
  let x = f file in
  close_in file;
  x

let file_in_gzip filename f =
  let file = Gzip.open_in filename in
  let x = f file in
  Gzip.close_in file;
  x

let files_out filenames f =
  let files = Xlist.map filenames open_out in
  let x = f files in
  Xlist.iter files close_out;
  x
  
let files_in filenames f =
  let files = Xlist.map filenames open_in in
  let x = f files in
  Xlist.iter files close_in;
  x

let load_table filename = 
  try
    file_in filename (fun file ->
      StdParser.table StdLexer.token (Lexing.from_channel file))
  with Parsing.Parse_error -> raise (Invalid_format filename)

let load_list_of_tables filename = 
  try
    file_in filename (fun file ->
      StdParser.three_dim StdLexer.token (Lexing.from_channel file))
  with Parsing.Parse_error -> raise (Invalid_format filename)

let load_list filename =
  Xlist.map (load_table filename) (function
      [x] -> x
    |  _ -> raise (Invalid_format filename))

let size filename = (stat filename).st_size 

let load_file filename =
  let size = (stat filename).st_size in
  let buf = String.create size in
  file_in filename (fun file -> 
  ignore (really_input file buf 0 size));
  buf

let is_simple s =
  not ((String.contains s ' ') || 
  (String.contains s ',') || 
  (String.contains s ';') || 
  (String.contains s '\t') || 
  (String.contains s '\n') || 
  (String.contains s '@') ||
  (String.contains s '"') || 
  (String.contains s '\\') || 
  (String.length s = 0))  

let output_string_gzip file s =
  Gzip.output file s 0 (String.length s)

let fprint_table file table =
  Xlist.iter table (fun line ->
    Printf.fprintf file "%s\n"
      (String.concat " " (Xlist.map line (fun s -> 
	if is_simple s then s else "\"" ^ s ^ "\""))))

let fprint_list_of_tables file list_table =
  Xlist.iter list_table (fun table ->
    Printf.fprintf file "@\n";
    fprint_table file table)

let fprint_list file list =
  Xlist.iter list (fun s ->
    Printf.fprintf file "%s\n"
      (if is_simple s then s else "\"" ^ s ^ "\""))
(*
let iter filename_in f =
  file_in filename_in (fun file ->
    let lex = Lexing.from_channel file in
    let _ = StdParser.beginning StdLexer.token lex in
    try
      while true do
        f (StdParser.next_table StdLexer.token lex)
      done
    with 
      Parsing.Parse_error -> raise (Invalid_format filename_in)
    | End_of_file -> ())

let map filename_in filename_out f =
  file_in filename_in (fun file ->
    file_out filename_out (fun file_out ->
      let lex = Lexing.from_channel file in
      let _ = StdParser.beginning StdLexer.token lex in
      try
	while true do
	  Printf.fprintf file_out "@\n";
          fprint_table file_out (f (StdParser.next_table StdLexer.token lex))
	done
      with 
	Parsing.Parse_error -> raise (Invalid_format filename_in)
      | End_of_file -> ()))

let map2 filename_in1 filename_in2 filename_out1 filename_out2 f =
  file_in filename_in1 (fun file1 ->
  file_in filename_in2 (fun file2 ->
    file_out filename_out1 (fun file_out1 ->
    file_out filename_out2 (fun file_out2 ->
      let lex1 = Lexing.from_channel file1 in
      let lex2 = Lexing.from_channel file2 in
      let _ = StdParser.beginning StdLexer.token lex1 in
      let _ = StdParser.beginning StdLexer.token lex2 in
      try
	while true do
	  Printf.fprintf file_out1 "@\n";
	  Printf.fprintf file_out2 "@\n";
	  let l1, l2 = f (StdParser.next_table StdLexer.token lex1) (StdParser.next_table StdLexer.token lex2) in
          fprint_table file_out1 l1;
          fprint_table file_out2 l2
	done
      with 
	Parsing.Parse_error -> raise (Invalid_format (filename_in1 ^ "or " ^ filename_in2))
      | End_of_file -> ()))))

let fold filename_in fold_start f =
  let r = ref fold_start in
  file_in filename_in (fun file ->
    let lex = Lexing.from_channel file in
    let _ = StdParser.beginning StdLexer.token lex in
    try
      while true do
        r := f (!r) (StdParser.next_table StdLexer.token lex)
      done
    with 
      Parsing.Parse_error -> raise (Invalid_format filename_in)
    | End_of_file -> ());
  (!r)

let fold2 filename_in1 filename_in2 fold_start f =
  let r = ref fold_start in
  file_in filename_in1 (fun file1 ->
  file_in filename_in2 (fun file2 ->
    let lex1 = Lexing.from_channel file1 in
    let lex2 = Lexing.from_channel file2 in
    let _ = StdParser.beginning StdLexer.token lex1 in
    let _ = StdParser.beginning StdLexer.token lex2 in
    try
      while true do
        r := f (!r) (StdParser.next_table StdLexer.token lex1) (StdParser.next_table StdLexer.token lex2)
      done
    with 
      Parsing.Parse_error -> raise (Invalid_format (filename_in1 ^ " or " ^ filename_in2))
    | End_of_file -> ()));
  (!r)

let partition filename_in filename_out1 filename_out2 f =
  file_in filename_in (fun file ->
    file_out filename_out1 (fun file_out1 ->
      file_out filename_out2 (fun file_out2 ->
	let lex = Lexing.from_channel file in
	let _ = StdParser.beginning StdLexer.token lex in
	try
	  while true do
	    let table = StdParser.next_table StdLexer.token lex in
	    let file_out = if f table then file_out1 else file_out2 in
	    Printf.fprintf file_out "@\n";
            fprint_table file_out table
	  done
	with 
	  Parsing.Parse_error -> raise (Invalid_format filename_in)
	| End_of_file -> ())))



*)
