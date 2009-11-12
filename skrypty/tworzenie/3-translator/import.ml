(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd

let split_into_chars s =
  List.rev (Int.fold 0 (String.length s - 1) [] (fun list i ->
    (String.sub s i 1) :: list))

let split_into_words s =
    let lex = Lexing.from_string s in
    let r = ref [] in
    try    
      while true do
	r := (WordLexer.token lex) :: (!r)
      done;
      !r
    with End_of_file -> List.rev (!r)

let import_line_list file id list step split_fun =
  let graph = Syntax_graph.insert Syntax_graph.empty ("@text_start", 0, step) (Syntax_graph.simple_predicate "") 0 in
  let graph,counter = Xlist.fold list (graph,step) (fun (graph,counter) line ->
    let graph = Syntax_graph.insert graph ("@line_start", counter, counter+step) (Syntax_graph.simple_predicate "") 0 in
    let graph,counter = Xlist.fold (split_fun line) (graph,counter+step) (fun (graph,counter) c ->
      Syntax_graph.insert graph (c, counter, counter+step) (Syntax_graph.simple_predicate c) 0, counter+step) in
    Syntax_graph.insert graph ("@line_end", counter, counter+step) (Syntax_graph.simple_predicate "\n") 0, counter+step) in
  let graph = Syntax_graph.insert graph ("@text_end", counter, counter+step) (Syntax_graph.simple_predicate "") 0 in
  let buf = Buffer.create 1000000 in
  Syntax_graph.xml_print buf id graph;
  File.output_string_gzip file (Buffer.contents buf)

let check s i = 
   String.get s i < '0' || String.get s i > '9'

let print_error line i = 
  failwith ("get_id: bad first line '" ^ line ^ "' " ^ (string_of_int i))

let get_id i = function
    [] -> failwith ("get_id: empty text " ^ (string_of_int i))
  | line :: _ -> 
      try
	if String.get line 1 <> 'P' || check line 2 || check line 3 || check line 4 ||
	check line 5 || check line 6 || check line 7 then print_error line i
	else if String.length line = 8 then String.sub line 1 7
	else if String.get line 8 <> ' ' then print_error line i
	else String.sub line 1 7
      with _ -> print_error line i

let unique_id_of_id set id =
  let rec u_rec i = 
    if StringSet.mem set (id ^ "." ^ (string_of_int i)) then u_rec (i+1) else id ^ "." ^ (string_of_int i) in
  if StringSet.mem set id then u_rec 1 else id

let atf_determine_size atf_filename =
  File.file_in atf_filename (fun atf_file ->
    let r = ref 0 in
    try
      while true do 
	let line = input_line atf_file in
	if String.length line > 0 then
	  if String.get line 0 = '&' then incr r
      done;
      !r
    with End_of_file -> !r)

let atf_import (atf_filename, xml_filename, step, split_fun) =
  print_endline "detemining size";
  let size = atf_determine_size atf_filename in
  print_endline ("size: " ^ (string_of_int size));
  let progress = Progress.create "ATF Import" size in
  let r = ref [] in
  let ids = ref StringSet.empty in
  let a,_,_ = Gc.counters () in
  let memory = ref (a +. 2000000000.) in
  File.file_in atf_filename (fun atf_file ->
    File.file_out_gzip xml_filename (fun xml_file ->
      File.output_string_gzip xml_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
      try
	for i = 0 to max_int do
	  let line = input_line atf_file in
	  if String.length line > 0 then
	    if String.get line 0 = '&' && !r <> [] then (
	      let list = List.rev (!r) in
	      r := [];
	      let id = unique_id_of_id (!ids) (get_id i list) in
	      ids := StringSet.add (!ids) id;
	      import_line_list xml_file id list step split_fun;
	      Progress.next progress;
	      let a,b,c = Gc.counters () in
	      if a > (!memory) then (
		memory := (!memory) +. 2000000000.;
		Gc.compact ();
		Printf.printf "%f %f %f\n" a b c;
		flush stdout));
	  r := line :: (!r)
	done
      with End_of_file -> (
	if !r <> [] then (
	  let list = List.rev (!r) in
	  let id = unique_id_of_id (!ids) (get_id (-1) list) in
	  import_line_list xml_file id list step split_fun);
	File.output_string_gzip xml_file "</corpus>\n";
	Gc.compact ();
	Progress.destroy progress)))

let import_line file id line step split_fun =
  let graph = Syntax_graph.empty in
  let graph = Syntax_graph.insert graph ("@line_start", 0, step) (Syntax_graph.simple_predicate "@line_start") 0 in
  let graph,counter = Xlist.fold (split_fun line) (graph,step) (fun (graph,counter) c ->
    Syntax_graph.insert graph (c, counter, counter+step) (Syntax_graph.simple_predicate c) 0, counter+step) in
  let graph = Syntax_graph.insert graph ("@line_end", counter, counter+step) (Syntax_graph.simple_predicate "@line_end") 0 in
  let buf = Buffer.create 100000 in
  Syntax_graph.xml_print buf id graph;
  File.output_string_gzip file (Buffer.contents buf)

let lines_determine_size atf_filename =
  File.file_in atf_filename (fun atf_file ->
    let r = ref 0 in
    try
      while true do 
	let _ = input_line atf_file in
	incr r
      done;
      !r
    with End_of_file -> !r)

let lines_import (atf_filename, xml_filename, step, split_fun) =
  print_endline "detemining size";
  let size = lines_determine_size atf_filename in
  print_endline ("size: " ^ (string_of_int size));
  let progress = Progress.create "Lines Import" size in
  let a,_,_ = Gc.counters () in
  let memory = ref (a +. 2000000000.) in
  File.file_in atf_filename (fun atf_file ->
    File.file_out_gzip xml_filename (fun xml_file ->
      File.output_string_gzip xml_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
      try
	for i = 0 to max_int do
	  let line = input_line atf_file in
	  import_line xml_file (string_of_int i) line step split_fun;
	  Progress.next progress;
	  let a,b,c = Gc.counters () in
	  if a > (!memory) then (
	    memory := (!memory) +. 2000000000.;
	    Gc.compact ();
	    Printf.printf "%f %f %f\n" a b c;
	    flush stdout)
	done
      with End_of_file -> (
	File.output_string_gzip xml_file "</corpus>\n";
	Gc.compact ();
	Progress.destroy progress)))

let folder_import (dirname, xml_filename, step, split_fun) = 
  print_endline dirname;
  let files = Sys.readdir dirname in
  let size = Array.length files in
  print_endline ("size: " ^ (string_of_int size));
  let r = ref [] in
  let progress = Progress.create "Folder Import" size in
  let a,_,_ = Gc.counters () in
  let memory = ref (a +. 2000000000.) in
  File.file_out_gzip xml_filename (fun xml_file ->
    File.output_string_gzip xml_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
    Array.iter (fun filename ->
  print_endline filename;
      File.file_in (dirname ^ "/" ^ filename) (fun atf_file ->
	try
	  for i = 0 to max_int do
	    let line = input_line atf_file in
	    r := line :: (!r)
	  done
	with End_of_file -> (
	  let list = List.rev (!r) in
	  r := [];
	  import_line_list xml_file filename list step split_fun;
	  Progress.next progress;
	  let a,b,c = Gc.counters () in
	  if a > (!memory) then (
	    memory := (!memory) +. 2000000000.;
	    Gc.compact ();
	    Printf.printf "%f %f %f\n" a b c;
	    flush stdout)))) files;
    File.output_string_gzip xml_file "</corpus>\n";
    Gc.compact ();
    Progress.destroy progress)
