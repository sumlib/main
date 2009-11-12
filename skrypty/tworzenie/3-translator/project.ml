(********************************************************)
(*                                                      *)
(*  Copyright 2007, 2008 Wojciech Jaworski.             *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Types

type project = {
    mutable filename: string;
    mutable name: string;
    mutable corpus_filename: string;
    mutable loaded_corpus: graph StringMap.t;
    mutable showed_corpus: (graph_node * graph_node * variable list) list StringMap.t;
    mutable parsed_corpus: graph StringMap.t;
    mutable rules_filename: string;
    mutable rules: RuleSet.t;
    mutable showed_corpus_model_changed: (unit -> unit) list;
    mutable rules_model_changed: (unit -> unit) list;
    mutable subcorpora: subcorpus StringMap.t;
    mutable end_line: string;
    mutable white: string}

let set_rules project rules =
  project.rules <- rules;
  Xlist.iter project.rules_model_changed (fun model_changed -> model_changed ())

let set_showed_corpus project showed_corpus =
  project.showed_corpus <- showed_corpus;
  Xlist.iter project.showed_corpus_model_changed (fun model_changed -> model_changed ())

let fold_xml project s f =
  Syntax_graph.xml_fold project.corpus_filename s (fun s (id,graph) -> f s id graph)

let fold_loaded project s f =
  let progress = Progress.create "Fold Loaded" (StringMap.size project.loaded_corpus) in
  let v = StringMap.fold project.loaded_corpus s (fun s id graph ->
    Progress.next progress;
    f s id graph) in
  Progress.destroy progress;
  v

let fold_showed project s f =
  let progress = Progress.create "Fold Showed" (StringMap.size project.showed_corpus) in
  let v = StringMap.fold project.showed_corpus s (fun s id graph ->
    Progress.next progress;
    f s id graph) in
  Progress.destroy progress;
  v

let fold_parsed project s f =
  let progress = Progress.create "Fold Parsed" (StringMap.size project.parsed_corpus) in
  let v = StringMap.fold project.parsed_corpus s (fun s id graph ->
    Progress.next progress;
    f s id graph) in
  Progress.destroy progress;
  v

let fold_selection selection s f =
  let progress = Progress.create "Fold Selected" (StringSet.size selection) in
  let v = StringSet.fold selection s (fun s id ->
    Progress.next progress;
    f s id) in
  Progress.destroy progress;
  v

let check_semantics sem =
  let lexbuf = Lexing.from_string sem in
  try
    let _ = SemParser.base SemLexer.token lexbuf in ()
  with 
    Parsing.Parse_error -> invalid_arg "Invalid semantics"
  | SemLexer.Fail _ -> invalid_arg "Invalid semantics"

let check_acc_semantics sem =
  let lexbuf = Lexing.from_string sem in
  try
    let _ = SemParser.acc_base SemLexer.token lexbuf in () 
  with 
    Parsing.Parse_error -> invalid_arg "Invalid accumulation semantics"
  | SemLexer.Fail _ -> invalid_arg "Invalid accumulation semantics"

let semantic_parser sem =
  let lexbuf = Lexing.from_string sem in
  try
    let f = SemParser.base SemLexer.token lexbuf in
    fun x -> try f x with Invalid_argument s -> [Syntax_graph.simple_predicate ("error: " ^ s)]
  with Parsing.Parse_error -> (print_endline ("Invalid semantic action: " ^ sem); (fun _ -> [Syntax_graph.simple_predicate "error"]))

let acc_semantic_parser sem = 
  let lexbuf = Lexing.from_string sem in
  try
    let f = SemParser.acc_base SemLexer.token lexbuf in
    fun x -> try f x with Invalid_argument s -> [Syntax_graph.simple_predicate ("error: " ^ s)]
  with Parsing.Parse_error -> (print_endline ("Invalid semantic action: " ^ sem); (fun _ -> [Syntax_graph.simple_predicate "error"]))

let reload_corpus project =
  let selected = StringMap.fold project.subcorpora StringSet.empty (fun set _ subcorpus ->
    if subcorpus.status <> Unloaded then 
      StringSet.union set subcorpus.ids 
    else set) in
  let corpus =
    try
      StringSet.fold selected StringMap.empty (fun map id ->
	StringMap.add map id (StringMap.find project.loaded_corpus id))
    with Not_found -> (
      if Sys.file_exists project.corpus_filename then 
	fold_xml project StringMap.empty (fun corpus id graph ->
	  if StringSet.mem selected id then StringMap.add corpus id graph else corpus)
      else StringMap.empty) in
  project.loaded_corpus <- corpus

let reparse_corpus project = 
  let selected = StringMap.fold project.subcorpora StringSet.empty (fun set _ subcorpus ->
    if subcorpus.status = Parsed then 
      StringSet.union set subcorpus.ids 
    else set) in
  let rules = Parser.prepare_for_parsing 
      (Parser.divide_rules_into_layers project.rules)
      semantic_parser acc_semantic_parser in
  let corpus =
    fold_selection selected StringMap.empty (fun corpus id ->
      try
	StringMap.add corpus id (StringMap.find project.parsed_corpus id)
      with Not_found ->
	StringMap.add corpus id (Parser.parse rules id (StringMap.find project.loaded_corpus id))) in
  project.parsed_corpus <- corpus

let reshow_corpus project = 
  let selected = StringMap.fold project.subcorpora StringSet.empty (fun set _ subcorpus ->
    if subcorpus.status = Parsed || subcorpus.status = Showed then 
      StringSet.union set subcorpus.ids 
    else set) in
  let rules = Parser.prepare_for_parsing 
      (Parser.divide_rules_into_layers project.rules)
      semantic_parser acc_semantic_parser in
  let corpus = fold_selection selected StringMap.empty (fun corpus id ->
    try
      StringMap.add corpus id (StringMap.find project.showed_corpus id)
    with Not_found ->
      try
	StringMap.add corpus id (Verse.parse (StringMap.find project.parsed_corpus id) project.end_line project.white)
      with Not_found ->
	StringMap.add corpus id (Verse.parse (Parser.parse rules id (StringMap.find project.loaded_corpus id))
				   project.end_line project.white)) in
  set_showed_corpus project corpus

let update_corpus project =
  reload_corpus project;
  reparse_corpus project;
  reshow_corpus project

let empty _ = 
  {filename=""; name = ""; corpus_filename = ""; 
   loaded_corpus = StringMap.empty; showed_corpus = StringMap.empty; parsed_corpus = StringMap.empty; 
   rules_filename = ""; rules = RuleSet.empty; 
   subcorpora = StringMap.empty; end_line=""; white=""; 
   showed_corpus_model_changed=[]; rules_model_changed=[]}

let xml_scan filename = 
  File.file_in_gzip filename (fun file  ->
    let lex = Lexing.from_function (fun buf len -> Gzip.input file buf 0 len) in
    try
      XmlParser.project XmlLexer.token lex
    with Parsing.Parse_error -> failwith ("xml_scan " ^ filename ^ ": Parse_error"))

let xml_print project filename = 
  File.file_out_gzip filename (fun file ->
    let buf = Buffer.create 100000 in
    Buffer.add_string buf (Printf.sprintf "<project name=\"%s\" corpus_filename=\"%s\" rules_filename=\"%s\" white=\"%s\" end_line=\"%s\">\n"
			     (refs project.name) (refs project.corpus_filename) (refs project.rules_filename) (refs project.white) (refs project.end_line));
    StringMap.iter project.subcorpora (fun name subcorpus ->
      Buffer.add_string buf (Printf.sprintf "  <subcorpus name=\"%s\" status=\"%s\">\n" 
			       (refs name) (string_of_subcstatus subcorpus.status));
      StringSet.iter subcorpus.ids (fun id ->
	Buffer.add_string buf (Printf.sprintf "    <id id=\"%s\"/>\n" (refs id)));
      Buffer.add_string buf (Printf.sprintf "  </subcorpus>\n"));
    Buffer.add_string buf (Printf.sprintf "</project>\n");
    File.output_string_gzip file (Buffer.contents buf))

let save_project project () = 
  xml_print project project.filename;
  if project.rules_filename <> "" then 
    File.file_out_gzip project.rules_filename (fun file ->
      let buf = Buffer.create 100000 in
      Parser.xml_print buf project.rules;
      File.output_string_gzip file (Buffer.contents buf))

let select project symbol subcorpus status_after =
  match subcorpus.status with
    Unloaded -> 
      let a,_,_ = Gc.counters () in
      let memory = ref (a +. 2000000000.) in
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers project.rules)
	  semantic_parser acc_semantic_parser in
      fold_xml project StringSet.empty (fun ids id graph ->
	if StringSet.mem subcorpus.ids id then (
	  let a,b,c = Gc.counters () in
	  if a > (!memory) then (
	    memory := (!memory) +. 2000000000.;
	    Gc.compact ();
	    Printf.printf "%f %f %f\n" a b c;
	    flush stdout);
	  let parsed_graph = Parser.parse rules id graph in
	  let b = Syntax_graph.fold parsed_graph false (fun b (s,_,_,_,_) ->
	    if s  = symbol then true else b) in
	  if b then (
	    if status_after <> Unloaded then project.loaded_corpus <- StringMap.add project.loaded_corpus id graph;
	    if status_after = Parsed then project.parsed_corpus <- StringMap.add project.parsed_corpus id parsed_graph;
	    StringSet.add ids id
	   ) else ids
	 ) else ids)
  | Loaded ->
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers project.rules)
	  semantic_parser acc_semantic_parser in
      fold_loaded project StringSet.empty (fun ids id graph ->
	if StringSet.mem subcorpus.ids id then 
	  let parsed_graph = Parser.parse rules id graph in
	  let b = Syntax_graph.fold parsed_graph false (fun b (s,_,_,_,_) ->
	    if s  = symbol then true else b) in
	  if b then (
	    if status_after = Parsed then project.parsed_corpus <- StringMap.add project.parsed_corpus id parsed_graph;
	    StringSet.add ids id 
	   ) else ids
	else ids)
  | Showed ->
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers project.rules)
	  semantic_parser acc_semantic_parser in
      fold_loaded project StringSet.empty (fun ids id graph ->
	if StringSet.mem subcorpus.ids id then 
	  let parsed_graph = Parser.parse rules id graph in
	  let b = Syntax_graph.fold parsed_graph false (fun b (s,_,_,_,_) ->
	    if s  = symbol then true else b) in
	  if b then (
	    if status_after = Parsed then project.parsed_corpus <- StringMap.add project.parsed_corpus id parsed_graph;
	    StringSet.add ids id 
	   ) else ids
	else ids)
  | Parsed -> 
      fold_parsed project StringSet.empty (fun ids id graph ->
	if StringSet.mem subcorpus.ids id then 
	  let b = Syntax_graph.fold graph false (fun b (s,_,_,_,_) ->
	    if s  = symbol then true else b) in
	  if b then StringSet.add ids id else ids
	else ids) 

let save_subcorpus (project, name, filename) =
    let subcorpus = StringMap.find project.subcorpora name in
    if subcorpus.status = Unloaded then 
      let buf = Buffer.create 1000000 in
      File.file_out_gzip filename (fun file ->
	File.output_string_gzip file ("<corpus size=\"" ^ (string_of_int (StringSet.size subcorpus.ids)) ^"\">\n");
	Syntax_graph.xml_fold project.corpus_filename () (fun () (id,graph) ->
	  if StringSet.mem subcorpus.ids id then (
	    Syntax_graph.xml_print buf id graph;
	    File.output_string_gzip file (Buffer.contents buf);
	    Buffer.clear buf));
	File.output_string_gzip file "</corpus>\n")
    else
      let buf = Buffer.create 1000000 in
      File.file_out_gzip filename (fun file ->
	File.output_string_gzip file ("<corpus size=\"" ^ (string_of_int (StringSet.size subcorpus.ids)) ^"\">\n");
	StringSet.iter subcorpus.ids (fun id ->
	  let graph = StringMap.find project.loaded_corpus id in
	  Syntax_graph.xml_print buf id graph;
	  File.output_string_gzip file (Buffer.contents buf);
	  Buffer.clear buf);
	File.output_string_gzip file "</corpus>\n")

let add_variables list formula =
  PredicateSet.fold formula list (fun list -> function
      List (_,l) -> (*Xlist.fold l list (fun list -> function
	  Var v -> v :: list
	| _ -> list)*) l @ list
    | Acc(_,(_,map)) -> IntMap.fold map list (fun list _ (v,_) -> v :: list))

let rec select_semantics_rec variable graph map =
  if Syntax_graph.mem map variable then map else
  let symbol,node1,node2,formula,layer = Syntax_graph.find graph variable in
  let map = Syntax_graph.insert_set map (symbol,node1,node2) formula layer in
  PredicateSet.fold formula map (fun map -> function
      List (_,l) -> 
	Xlist.fold l map (fun map v -> select_semantics_rec v graph map)
    | Acc(_,(_,map2)) -> IntMap.fold map2 map (fun map _ (v,_) -> select_semantics_rec v graph map))
(*let rec select_semantics_rec graph map = function
    [] -> map
  | (symbol,node1,node2) :: list ->
      try 
	let (symbol,node1,node2,formula,layer) = Syntax_graph.find graph (symbol,node1,node2) in 
	let map = Syntax_graph.insert_set map (symbol,node1,node2) formula layer in
	let list = (add_variables list formula) @ list in
	select_semantics_rec graph map list
      with Not_found -> (
	Printf.printf "select_semantics_rec (%s,%d,%d)\n" symbol node1 node2; 
	select_semantics_rec graph map list)*)

let select_semantics root_symbol graph =
  Syntax_graph.fold graph Syntax_graph.empty (fun map (symbol,node1,node2,_,_) ->
    if root_symbol = symbol then select_semantics_rec (symbol,node1,node2) graph map else map)
(*  let list = Syntax_graph.fold graph [] (fun list -> fun (symbol,node1,node2,formula,layer) ->
    if root_symbol = symbol then 
      (symbol,node1,node2) :: list else list) in
  select_semantics_rec graph Syntax_graph.empty list*)

let save_semantics (project, name, symbol, filename) =
  let subcorpus = StringMap.find project.subcorpora name in
  match subcorpus.status with
    Unloaded -> 
      let a,_,_ = Gc.counters () in
      let memory = ref (a +. 2000000000.) in
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers project.rules)
	  semantic_parser acc_semantic_parser in
      let buf = Buffer.create 1000000 in
      File.file_out_gzip filename (fun file ->
	File.output_string_gzip file ("<corpus size=\"" ^ (string_of_int (StringSet.size subcorpus.ids)) ^"\">\n");
	fold_xml project () (fun () id graph ->
	  let a,b,c = Gc.counters () in
	  if a > (!memory) then (
	    memory := (!memory) +. 2000000000.;
	    Gc.compact ();
	    Printf.printf "%f %f %f\n" a b c;
	    flush stdout);
	  if StringSet.mem subcorpus.ids id then 
	    let graph = select_semantics symbol (Parser.parse rules id graph) in
	    Syntax_graph.xml_print buf id graph;
	    File.output_string_gzip file (Buffer.contents buf);
	    Buffer.clear buf);
	File.output_string_gzip file "</corpus>\n")
  | Loaded ->
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers project.rules)
	  semantic_parser acc_semantic_parser in
      let buf = Buffer.create 1000000 in
      File.file_out_gzip filename (fun file ->
	File.output_string_gzip file ("<corpus size=\"" ^ (string_of_int (StringSet.size subcorpus.ids)) ^"\">\n");
	fold_loaded project () (fun () id graph ->
	  if StringSet.mem subcorpus.ids id then 
	    let graph = select_semantics symbol (Parser.parse rules id graph) in
	    Syntax_graph.xml_print buf id graph;
	    File.output_string_gzip file (Buffer.contents buf);
	    Buffer.clear buf);
	File.output_string_gzip file "</corpus>\n")
  | Showed ->
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers project.rules)
	  semantic_parser acc_semantic_parser in
      let buf = Buffer.create 1000000 in
      File.file_out_gzip filename (fun file ->
	File.output_string_gzip file ("<corpus size=\"" ^ (string_of_int (StringSet.size subcorpus.ids)) ^"\">\n");
	fold_loaded project () (fun () id graph ->
	  if StringSet.mem subcorpus.ids id then 
	    let graph = select_semantics symbol (Parser.parse rules id graph) in
	    Syntax_graph.xml_print buf id graph;
	    File.output_string_gzip file (Buffer.contents buf);
	    Buffer.clear buf);
	File.output_string_gzip file "</corpus>\n")
  | Parsed -> 
      let buf = Buffer.create 1000000 in
      File.file_out_gzip filename (fun file ->
	File.output_string_gzip file ("<corpus size=\"" ^ (string_of_int (StringSet.size subcorpus.ids)) ^"\">\n");
	fold_parsed project () (fun () id graph ->
	  if StringSet.mem subcorpus.ids id then 
	    let graph = select_semantics symbol graph in
	    Syntax_graph.xml_print buf id graph;
	    File.output_string_gzip file (Buffer.contents buf);
	    Buffer.clear buf);
	File.output_string_gzip file "</corpus>\n")

let move project dest_name ids = 
  let dest_subcorpus = StringMap.find project.subcorpora dest_name in
  let dest_subcorpus = {status=dest_subcorpus.status; ids=StringSet.union dest_subcorpus.ids ids} in
  let subcorpora = StringMap.remove project.subcorpora dest_name in
  let subcorpora = StringMap.map subcorpora (fun subcorpus ->
    {status=subcorpus.status; ids=StringSet.difference subcorpus.ids ids}) in
  project.subcorpora <- StringMap.add subcorpora dest_name dest_subcorpus;
  update_corpus project

let change_subcorpus_status (project, name, status) =
  let subcorpus = StringMap.find project.subcorpora name  in
  project.subcorpora <- StringMap.add project.subcorpora name {status=status; ids=subcorpus.ids};
  update_corpus project

let reparse project = 
  project.parsed_corpus <- StringMap.empty;
  project.showed_corpus <- StringMap.empty;
  update_corpus project

let set_corpus project corpus_filename = 
  project.corpus_filename <- corpus_filename;
  project.loaded_corpus <- StringMap.empty;
  set_showed_corpus project StringMap.empty;
  project.parsed_corpus <- StringMap.empty;
  let ids = 
    if Sys.file_exists corpus_filename then (
      Syntax_graph.xml_fold corpus_filename StringSet.empty (fun set (id,_) -> StringSet.add set id) )
    else StringSet.empty in
  project.subcorpora <- 
    StringMap.add StringMap.empty "default" {status=Unloaded; ids=ids}

let open_rules project rules_filename = 
  project.rules_filename <- rules_filename;
  set_rules project 
    (if Sys.file_exists rules_filename then
      Parser.xml_scan rules_filename 
    else RuleSet.empty)

let new_project update project () =
  project.filename <- "";
  project.name <- "";
  set_corpus project "";
  open_rules project "";
  update ()

let open_project (project, filename) = 
  let name,corpus_filename,rules_filename,white,end_line,subcorpora = xml_scan filename in
  project.filename <- filename;
  project.name <- name;
  project.white <- white;
  project.end_line <- end_line;
  project.corpus_filename <- corpus_filename;
  project.loaded_corpus <- StringMap.empty;
  set_showed_corpus project StringMap.empty;
  project.parsed_corpus <- StringMap.empty;
  project.subcorpora <- subcorpora;
  open_rules project rules_filename;
  update_corpus project

let open_corpus (project, corpus_filename) = 
  set_corpus project corpus_filename

let open_rules2 (project, rules_filename) = 
  open_rules project rules_filename;
  reparse project

