(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Types

type word =
    UnknownWord of string
  | Word of (string * string list list) list
  | LemWord of string * (string * string list list) list
  | NotWord of string * string list

type line =
    LemmataLine of string list
  | FormatLine of string * string list
  | UnknownLine of string
  | TextLine of word list
  | EmptyLine

let semantic_parser sem =
  let lexbuf = Lexing.from_string sem in
  try
    let f = SemParser.base SemLexer.token lexbuf in
    fun x -> try f x with Invalid_argument s -> raise Pragmatics.TextNotParsed
  with Parsing.Parse_error -> (print_endline ("Invalid semantic action: " ^ sem); (fun _ -> [Syntax_graph.simple_predicate "error"]))

let acc_semantic_parser sem = 
  let lexbuf = Lexing.from_string sem in
  try
    let f = SemParser.acc_base SemLexer.token lexbuf in
    fun x -> try f x with Invalid_argument s -> raise Pragmatics.TextNotParsed
  with Parsing.Parse_error -> (print_endline ("Invalid semantic action: " ^ sem); (fun _ -> [Syntax_graph.simple_predicate "error"]))

let suffixes = StringSet.of_list 
    ["!"; "#"; "*"; ">"; "?";"]"; ";"]

let prefixes = StringSet.of_list 
    ["<"; "["]

let import_lemmata_line line =
  if String.length line < 6 then raise Pragmatics.TextNotParsed;
  if String.sub line 0 6 <> "#lem: " then raise Pragmatics.TextNotParsed;
  LemmataLine (Str.split (Str.regexp "; ") (String.sub line 6 (String.length line - 6)))


(* robi graf na podstawie format_rules *)
let import_format_line line format_rules =
  let sem = Pragmatics.string_meaning (Pragmatics.create_parse_and_find format_rules line "Line") in
  FormatLine (line,sem)
 (* sem - lista stringów. ?? sprawdzić co robi Pragmatics.string_meaning i Pragmatics.create_parse_and_find *)

let rec merge_brackets x = function
    "}" :: list -> merge_brackets (x ^ "}") list
  | y :: list -> if x = "{" then merge_brackets ("{" ^ y) list else x :: (merge_brackets y list)
  | [] -> [x]

let rec get_suffixes s i =
  if i = String.length s then s,"" else
  if StringSet.mem suffixes (String.sub s i 1) then get_suffixes s (i+1) 
  else String.sub s 0 i, String.sub s i (String.length s - i)

let rec move_suffixes x = function
    y :: list -> 
      let y1,y2 = get_suffixes y 0 in 
      if y2 = "" then move_suffixes (x ^ y1) list else (x ^ y1) :: (move_suffixes y2 list)
  | [] -> [x]

let rec get_prefixes s i =
  if i = 0 then "",s else
  if StringSet.mem prefixes (String.sub s (i-1) 1) then get_prefixes s (i-1) 
  else String.sub s 0 i, String.sub s i (String.length s - i)

let rec move_prefixes x = function
    y :: list -> 
      let x1,x2 = get_prefixes x (String.length x) in 
      if x1 = "" then move_prefixes (x2 ^ y) list else x1 :: (move_prefixes (x2 ^ y) list)
  | [] -> [x]

let rec merge_parents2 n x = function
    [] -> raise Pragmatics.TextNotParsed
  | [")"] -> if n > 1 then raise Pragmatics.TextNotParsed else x ^ ")",[]
  | [_] -> raise Pragmatics.TextNotParsed
  | ")" :: "(" :: list -> merge_parents2 n (x ^ ")(") list
  | ")" :: y :: list -> 
      if n = 1 then 
	if y = "-" || y = ":" || y = "{" || y = "}" then 
	  x ^ ")", (y :: list)
	else x ^ ")" ^ y, list
      else merge_parents2 (n-1) (x ^ ")") (y :: list)
  | "(" :: list -> merge_parents2 (n+1) (x ^ "(") list
  | y :: list -> merge_parents2 n (x ^ y) list

(* parsowanie jednego słowa ?? - na później *)
let rec merge_parents x = function
    [] -> [x]
  | "(" :: list -> 
      if x = "-" || x = ":" || x = "{" || x = "}" then 
	x :: (let x,list = merge_parents2 1 "(" list in merge_parents x list)
      else let x,list = merge_parents2 1 (x ^ "(") list in merge_parents x list
  | y :: list -> x :: (merge_parents y list) 

let import_word word sign_rules unknown_word_file =
  try
    let list = Str.full_split (Str.regexp "-\\|:\\|}\\|{\\|(\\|)") word in
    let list = Xlist.map list (function
	Str.Delim x -> x
      | Str.Text x -> x) in
    let list = match list with 
      [x] -> [x]
    | "(" :: list -> merge_parents "" ("(" :: list)
    | x :: list -> merge_parents x list
    | [] -> failwith "import_word" in
    let list = match list with 
      [x] -> [x]
    | x :: list -> merge_brackets x list
    | [] -> failwith "import_word" in
    let list = match list with 
      [x] -> [x]
    | x :: list -> let list = move_suffixes x list in move_prefixes (List.hd list) (List.tl list) 
    | [] -> failwith "import_word" in
    Word(Xlist.map list (fun x -> 
      x,try Pragmatics.string_list_meaning (Pragmatics.create_parse_and_find sign_rules x "Sign") 
      with Pragmatics.TextNotParsed -> (
	Printf.fprintf unknown_word_file "%s\n" x; 
	flush unknown_word_file;
	raise Pragmatics.TextNotParsed)))
  with Pragmatics.TextNotParsed -> 
    Printf.fprintf unknown_word_file "%s\n" word;
    UnknownWord word

let import_notword sign_rules x unknown_word_file =
  try
    NotWord(x,Pragmatics.string_meaning (Pragmatics.create_parse_and_find sign_rules x "Sign"))
  with Pragmatics.TextNotParsed -> 
    Printf.fprintf unknown_word_file "%s\n" x;
    UnknownWord x

let import_text_line line format_rules sign_rules unknown_word_file =
  match Str.full_split (Str.regexp " ") line with
    (Str.Text x) :: list -> (* pierwsze słowo linii - nr linii*)
      let ln = NotWord(x, Pragmatics.string_meaning (Pragmatics.create_parse_and_find format_rules x "LineNumber")) in
      TextLine(ln ::
      (Xlist.map list (function
	  Str.Delim x -> import_notword sign_rules x unknown_word_file
	| Str.Text x -> 
	    if x = "," then import_notword sign_rules x unknown_word_file
	    else import_word x sign_rules unknown_word_file)))
  | _ -> raise Pragmatics.TextNotParsed

let print_test file list =
  Xlist.iter list (function 
      LemmataLine list -> Printf.fprintf file "#lem: %s\n" (String.concat "; " list)
    | FormatLine (s,_) -> Printf.fprintf file "%s\n" s
    | UnknownLine s -> Printf.fprintf file "%s\n" s
    | TextLine list -> (
	Xlist.iter list (function 
	    UnknownWord s -> Printf.fprintf file "%s" s
	  | Word list -> Xlist.iter list (fun (s,_) -> Printf.fprintf file "%s"s)
	  | LemWord (_,list) -> Xlist.iter list (fun (s,_) -> Printf.fprintf file "%s"s)
	  | NotWord (s,_) -> Printf.fprintf file "%s" s);
	Printf.fprintf file "\n")
    | EmptyLine -> Printf.fprintf file "\n")

let print_line_types file id list =
  Printf.fprintf file "%s " id;
  Xlist.iter list (function 
      LemmataLine _ -> Printf.fprintf file "L"
    | FormatLine _ -> Printf.fprintf file "F"
    | UnknownLine _ -> Printf.fprintf file "U"
    | TextLine _ -> Printf.fprintf file "T"
    | EmptyLine -> Printf.fprintf file "E");
  Printf.fprintf file "\n"

let rec find_lemmata l = function
    [] -> [], List.rev l
  | LemmataLine s :: list -> s, (List.rev l) @ list
  | TextLine s :: list -> [], (List.rev l) @ [TextLine s] @ list
  | x :: list -> find_lemmata (x :: l) list

let rec merge_lemmata id lem words =
  if lem = [] then words else
  try
    let lem,lem_words = Xlist.fold words (lem,[]) (fun (lem,lem_words) -> function
	UnknownWord s -> lem, (UnknownWord s) :: lem_words
      | Word list -> if lem = [] then raise Not_found else List.tl lem, (LemWord (List.hd lem, list)) :: lem_words
      | LemWord _ -> failwith "merge_lemmata"
      | NotWord (s,sem) -> lem, (NotWord (s,sem)) :: lem_words) in
    if lem = [] then List.rev lem_words else words
  with Not_found -> (
    Printf.printf "Bad lemata in %s\n" id;
    flush stdout;
    words)

let rec assign_lemata id = function
      LemmataLine _ :: _ -> failwith "assign_lemata"
    | FormatLine(s,sem) :: list -> FormatLine(s,sem) :: (assign_lemata id list)
    | UnknownLine x :: list -> UnknownLine x :: (assign_lemata id list)
    | TextLine x :: list -> 
	let lem, list = find_lemmata [] list in
	(TextLine (merge_lemmata id lem x)) :: (assign_lemata id list)
    | EmptyLine :: list -> EmptyLine :: (assign_lemata id list)
    | [] -> []

let rec insert_sem_names_list step graph start cur last = function
    [x] -> Syntax_graph.insert graph (x, start, last) (Syntax_graph.simple_predicate x) 0, cur
  | x :: list -> 
      insert_sem_names_list step 
	(Syntax_graph.insert graph (x, start, cur) (Syntax_graph.simple_predicate x) 0) cur (cur+step) last list
  | _ -> failwith "insert_sem_names_list"

let rec insert_sem_names step graph start cur last list = 
  Xlist.fold list (graph,cur) (fun (graph,cur) list ->
    insert_sem_names_list step graph start cur last list)

let rec insert_sem_list step sign_graph sign_name_graph start cur last = function
    [n,symbol,names] -> 
      let sign_graph = Syntax_graph.insert sign_graph (symbol, start, last) (Syntax_graph.simple_predicate symbol) 0 in
      let sign_name_graph, new_cur = insert_sem_names step sign_name_graph start cur last names in
      if new_cur <> cur+((n-1)*step) then failwith "insert_sem_list error!!!";
      sign_graph, sign_name_graph, new_cur
  | (n,symbol,names) :: list -> 
      let new_cur = cur+((n-1)*step) in
      let sign_graph = Syntax_graph.insert sign_graph (symbol, start, new_cur) (Syntax_graph.simple_predicate symbol) 0 in
      let sign_name_graph, new_cur2 = insert_sem_names step sign_name_graph start cur new_cur names in
      if new_cur <> new_cur2 then failwith "insert_sem_list error!!!";
      insert_sem_list step sign_graph sign_name_graph new_cur (new_cur+step) last list
  | _ -> failwith "insert_sem_list"

(*let rec insert_sem_list step graph start cur last = function
    [String x] -> Syntax_graph.insert graph (x, start, last) (Syntax_graph.simple_predicate x) 0, cur
  | (String x) :: list -> 
      insert_sem_list step (Syntax_graph.insert graph (x, start, cur) (Syntax_graph.simple_predicate x) 0) cur (cur+step) last list
  | _ -> failwith "insert_sem_list"*)

let graph_size list =
  Xlist.fold list 0 (fun n l -> n + (Xlist.size l) - 1) + 1

let insert_sign_sem (sign_graph, sign_name_graph, show_graph, lem_graph, counter) step s sem unknown_sign_file sign_name_rules = 
  let list2_sem = Xlist.map sem (fun list ->
    Xlist.map list (fun symbol -> 
      try 
	let names = StringMap.find sign_name_rules symbol in
	let n = graph_size names in
	n,symbol,names
      with Not_found -> try 
	let names = StringMap.find sign_name_rules (String.lowercase symbol) in
	let n = graph_size names in
	n,symbol,names
      with Not_found -> (
	Printf.fprintf unknown_sign_file "%s\n" symbol;
	1,symbol,[[symbol]]))) in
  let n = Xlist.fold list2_sem 0 (fun n list ->
    let m = Xlist.fold list 0 (fun m (a,_,_) -> m + a) in
    n + m - 1) + 1 in
  let last = counter + (n * step) in
  let sign_graph,sign_name_graph,cur = Xlist.fold list2_sem (sign_graph,sign_name_graph,counter+step) 
      (fun (sign_graph,sign_name_graph,cur) -> insert_sem_list step sign_graph sign_name_graph counter cur last) in
  if cur <> last then failwith "insert_sem error!!!";
  sign_graph, sign_name_graph,
  Syntax_graph.insert show_graph (s, counter, last) (Syntax_graph.simple_predicate "") 0, 
  lem_graph, last


(*  let n = PredicateSet.fold sem 0 (fun n -> function
      List(x,[]) -> n
    | List("string_list",list) -> n + (Xlist.size list - 1)
    | _ -> failwith "insert_sem") in
  let last = counter + ((n+1) * step) in
  let sign_graph,cur = PredicateSet.fold sem (sign_graph,counter+step) (fun (sign_graph,cur) -> function
      List(x,[]) -> Syntax_graph.insert sign_graph (x, counter, last) (Syntax_graph.simple_predicate x) 0, cur
    | List("string_list",list) -> insert_sem_list step sign_graph counter cur last list
    | _ -> failwith "insert_sem") in
  if cur <> last then failwith "insert_sem error!!!";
  sign_graph,
  Syntax_graph.insert show_graph (s, counter, last) (Syntax_graph.simple_predicate "") 0, 
  lem_graph, last*)

let insert_sem (sign_graph, sign_name_graph, show_graph, lem_graph, counter) step s sem =
  Xlist.fold sem sign_graph (fun sign_graph x ->
      Syntax_graph.insert sign_graph (x, counter, counter + step) (Syntax_graph.simple_predicate s) 0),
  Xlist.fold sem sign_name_graph (fun sign_name_graph x ->
      Syntax_graph.insert sign_name_graph (x, counter, counter + step) (Syntax_graph.simple_predicate s) 0),
  Syntax_graph.insert show_graph (s, counter, counter + step) (Syntax_graph.simple_predicate "") 0,
  lem_graph,
  counter+step

let insert_text_sem (sign_graph, sign_name_graph, show_graph, lem_graph, counter) step s sem show =
  Syntax_graph.insert sign_graph (sem, counter, counter+step) (Syntax_graph.simple_predicate s) 0, 
  Syntax_graph.insert sign_name_graph (sem, counter, counter+step) (Syntax_graph.simple_predicate s) 0, 
  Syntax_graph.insert show_graph (show, counter, counter+step) (Syntax_graph.simple_predicate s) 0, 
  lem_graph,
  counter+step

let insert_lem (sign_graph, sign_name_graph, show_graph, lem_graph, counter) start lem =
  sign_graph, sign_name_graph, show_graph,
  Syntax_graph.insert lem_graph (lem, start, counter) (Syntax_graph.simple_predicate "") 0, 
  counter

let get_signature map = function
    [] -> failwith "get_attributes: empty text"
  | line :: lines -> 
      let n = String.length line in
      if n <= 8 then map, lines else
      if n > 11 & String.sub line 8 3 = " = " then 
	StringMap.add map "signature" (String.sub line 11 (n-11)), lines
      else
	StringMap.add map "signature" (String.sub line 8 (n-8)), lines

let get_version map = function
    [] -> map, []
  | line :: lines -> 
      let n = String.length line in
      if n < 10 then map, line :: lines else
      if String.sub line 0 10 = "#version: " then 
	StringMap.add map "version" (String.sub line 10 (n-10)), lines
      else
	map, line :: lines

let get_language map = function
    [] -> map, []
  | line :: lines -> 
      let n = String.length line in
      if n < 11 then map, line :: lines else
      if String.sub line 0 11 = "#atf: lang " then 
	StringMap.add map "language" (String.sub line 11 (n-11)), lines
      else
	map, line :: lines


let import_line_list 
    unknown_line_file unknown_word_file unknown_sign_file 
    format_rules sign_rules sign_name_rules
    show_file lem_file sign_file sign_name_file attribute_file id list step =
  let attributes, list = get_signature StringMap.empty list in
  let attributes, list = get_version attributes list in
  let attributes, list = get_language attributes list in
  let parsed_list = Xlist.map list (fun line ->
    if line = "" then EmptyLine else
    try import_lemmata_line line with Pragmatics.TextNotParsed ->
      try import_format_line line format_rules with Pragmatics.TextNotParsed -> 
	try import_text_line line format_rules sign_rules unknown_word_file with Pragmatics.TextNotParsed -> 
	  Printf.fprintf unknown_line_file "%s\n" line;
	  flush unknown_line_file;
	  UnknownLine line) in
(*print_test show_file parsed_list;
   print_line_types lem_file id parsed_list;*)
  let parsed_list = assign_lemata id parsed_list in
  let graphs = Syntax_graph.empty, Syntax_graph.empty, Syntax_graph.empty, Syntax_graph.empty, 0 in
  let graphs = insert_text_sem graphs step "@text_begin" "@text_begin" "" in
  let graphs = Xlist.fold parsed_list graphs (fun graphs -> function
      LemmataLine _ -> failwith "import_line_list"
    | FormatLine (s,sem) -> 
	if List.mem "delete" sem then graphs else 
	insert_sem graphs step (s^"\n") sem
    | UnknownLine s -> insert_text_sem graphs step s "#unknown" s
    | TextLine words -> 
	let graphs = Xlist.fold words graphs (fun graphs -> function
	    UnknownWord s -> insert_text_sem graphs step s "unknown" s
	  | Word signs -> 
	      Xlist.fold signs graphs (fun graphs (s,sem) -> 
		insert_sign_sem graphs step s sem unknown_sign_file sign_name_rules) 
	  | LemWord (lem,signs) -> 
	      let _,_,_,_,start = graphs in 
	      let sign_graph, sign_name_graph, show_graph, lem_graph, counter =
		Xlist.fold signs graphs (fun graphs (s,sem) -> 
		  insert_sign_sem graphs step s sem unknown_sign_file sign_name_rules) in
	      insert_lem (sign_graph, sign_name_graph, show_graph, lem_graph, counter) start lem
	  | NotWord (s,sem) -> insert_sem graphs step s sem) in
	insert_text_sem graphs step "@line_end" "@line_end" "@line_end\n"
    | EmptyLine -> graphs) in
  let (sign_graph, sign_name_graph, show_graph, lem_graph, counter) = insert_text_sem graphs step "@text_end" "@text_end" "" in
  let buf = Buffer.create 1000000 in
  Syntax_graph.xml_print buf id sign_graph;
  File.output_string_gzip sign_file (Buffer.contents buf);
  Buffer.clear buf;
  Syntax_graph.xml_print buf id sign_name_graph;
  File.output_string_gzip sign_name_file (Buffer.contents buf);
  Buffer.clear buf;
  Syntax_graph.xml_print buf id show_graph;
  File.output_string_gzip show_file (Buffer.contents buf);
  Buffer.clear buf;
  Syntax_graph.xml_print buf id lem_graph;
  File.output_string_gzip lem_file (Buffer.contents buf);
  Buffer.clear buf;
  Syntax_graph.xml_print_attributes buf id attributes;
  File.output_string_gzip attribute_file (Buffer.contents buf)

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

let parse_sign_name_rules list =
  Xlist.fold list StringMap.empty (fun map -> function
      k :: v -> StringMap.add_inc map k [v] (fun l -> v :: l)
    | _ -> failwith "parse_sign_name_rules")
 
let atf_lexer (atf_filename, show_filename, lem_filename, sign_filename, sign_name_filename, attribute_filename,
	       format_rules_filename, sign_rules_filename,  sign_name_rules_filename, 
	       unknown_line_filename, unknown_word_filename, unknown_sign_filename, step) =
  print_endline "detemining size";
  let size = atf_determine_size atf_filename in
  print_endline ("size: " ^ (string_of_int size));
  let r = ref [] in
  let ids = ref StringSet.empty in
  let a,_,_ = Gc.counters () in
  let memory = ref (a +. 2000000000.) in
  let format_rules = Parser.prepare_for_parsing 
      (Parser.divide_rules_into_layers (Parser.xml_scan format_rules_filename))
      semantic_parser acc_semantic_parser in
  let sign_rules = Parser.prepare_for_parsing 
      (Parser.divide_rules_into_layers (Parser.xml_scan sign_rules_filename))
      semantic_parser acc_semantic_parser in
  let sign_name_rules = parse_sign_name_rules (File.load_table sign_name_rules_filename) in
  let progress = Progress.create "ATF Import" size in
  File.file_out_gzip show_filename (fun show_file ->
    File.file_out_gzip lem_filename (fun lem_file ->
      File.file_out_gzip sign_filename (fun sign_file ->
	File.file_out_gzip sign_name_filename (fun sign_name_file ->
	  File.file_out_gzip attribute_filename (fun attribute_file ->
	    File.file_out unknown_line_filename (fun unknown_line_file ->
	      File.file_out unknown_word_filename (fun unknown_word_file ->
		File.file_out unknown_sign_filename (fun unknown_sign_file ->
		  File.file_in atf_filename (fun atf_file ->
		    File.output_string_gzip sign_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
		    File.output_string_gzip sign_name_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
		    File.output_string_gzip show_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
		    File.output_string_gzip lem_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
		    File.output_string_gzip attribute_file ("<corpus size=\"" ^ (string_of_int size) ^ "\">\n");
		    try
		      for i = 0 to max_int do
			let line = input_line atf_file in
			if String.length line > 0 then
			  if String.get line 0 = '&' && !r <> [] then (
			    let list = List.rev (!r) in
			    r := [];
				(* dzieli tekst na linie i daje je do funkcji import_line_list *)
			    let id = unique_id_of_id (!ids) (get_id i list) in
			    ids := StringSet.add (!ids) id;
			    import_line_list 
			      unknown_line_file unknown_word_file unknown_sign_file 
			      format_rules sign_rules sign_name_rules
			      show_file lem_file sign_file sign_name_file attribute_file id list step;
			    Progress.next progress;
			    let a,b,c = Gc.counters () in
			    if a > (!memory) then (
			      memory := (!memory) +. 2000000000.;
			      Gc.compact ()(*;
					      Printf.printf "%f %f %f\n" a b c;
					      flush stdout*)));
			r := line :: (!r)
		      done
		    with End_of_file -> (
		      if !r <> [] then (
			let list = List.rev (!r) in
			let id = unique_id_of_id (!ids) (get_id (-1) list) in
			import_line_list 
			  unknown_line_file unknown_word_file unknown_sign_file 
			  format_rules sign_rules sign_name_rules
			  show_file lem_file sign_file sign_name_file attribute_file id list step);
		      File.output_string_gzip sign_file "</corpus>\n";
		      File.output_string_gzip sign_name_file "</corpus>\n";
		      File.output_string_gzip show_file "</corpus>\n";
		      File.output_string_gzip lem_file "</corpus>\n";
		      File.output_string_gzip attribute_file "</corpus>\n";
		      Gc.compact ();
		      Progress.destroy progress))))))))))

