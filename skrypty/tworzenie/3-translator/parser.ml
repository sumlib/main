(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Types

let xml_print buf rules = 
  Buffer.add_string buf (Printf.sprintf "<rules>\n");
  RuleSet.iter rules (function
      Normal(status,prod,match_list,white,sem) -> 
	Buffer.add_string buf (Printf.sprintf "  <normal status=\"%s\" symbol=\"%s\" white=\"%s\" sem=\"%s\">\n" 
				 (string_of_status status) (refs prod) (refs white) (refs sem));
	Xlist.iter match_list (fun matched -> Buffer.add_string buf (Printf.sprintf "    <matched symbol=\"%s\"/>\n" (refs matched)));
	Buffer.add_string buf (Printf.sprintf "  </normal>\n")
    | Specific(status,prod,id,match_list,sem) ->
	Buffer.add_string buf 
	  (Printf.sprintf "  <specific status=\"%s\" symbol=\"%s\" id=\"%s\" sem=\"%s\">\n" 
	     (string_of_status status) (refs prod) (refs id) (refs sem));
	Xlist.iter match_list (fun (symbol,node1,node2) -> 
	  Buffer.add_string buf (Printf.sprintf "    <matched symbol=\"%s\" node1=\"%d\" node2=\"%d\"/>\n" (refs symbol) node1 node2));
	Buffer.add_string buf (Printf.sprintf "  </specific>\n")
    | Delete (status,matched) ->
	Buffer.add_string buf (Printf.sprintf "  <delete status=\"%s\" symbol=\"%s\"/>\n" (string_of_status status) (refs matched))
    | Accumulate(status,prod,matched,white,sem) ->
	Buffer.add_string buf 
	  (Printf.sprintf "  <accumulate status=\"%s\" symbol=\"%s\" matched_symbol=\"%s\" white=\"%s\" sem=\"%s\"/>\n" 
	     (string_of_status status) (refs prod) (refs matched) (refs white) (refs sem))
    | AccumulateLeft(status,prod,matched,left_match,white,sem) ->
	Buffer.add_string buf 
	  (Printf.sprintf "  <accumulate_left status=\"%s\" symbol=\"%s\" matched_symbol=\"%s\" matched_left=\"%s\" white=\"%s\" sem=\"%s\"/>\n" 
	     (string_of_status status) (refs prod) (refs matched) (refs left_match) (refs white) (refs sem))
    | AccumulateRight(status,prod,matched,right_match,white,sem) ->
	Buffer.add_string buf 
	  (Printf.sprintf "  <accumulate_right status=\"%s\" symbol=\"%s\" matched_symbol=\"%s\" matched_right=\"%s\" white=\"%s\" sem=\"%s\"/>\n" 
	     (string_of_status status) (refs prod) (refs matched) (refs right_match) (refs white) (refs sem)));
  Buffer.add_string buf (Printf.sprintf "</rules>\n")

let xml_scan filename = 
  File.file_in_gzip filename (fun file  ->
    let lex = Lexing.from_function (fun buf len -> Gzip.input file buf 0 len) in
    try 
      XmlParser.rules XmlLexer.token lex
    with Parsing.Parse_error -> failwith ("xml_scan " ^ filename ^ ": Parse_error"))

let add_prec_empty prec list =
  Xlist.fold list prec (fun prec s ->
    StringMap.add_inc prec s StringSet.empty (fun l -> l))

let add_prec_prod prec prod list =
  let prec = StringMap.add_inc prec prod (StringSet.of_list list) (fun l -> StringSet.union l (StringSet.of_list  list)) in
  add_prec_empty prec list

let print_prec prec = 
  StringMap.iter prec (fun prod matched ->
    Printf.printf "%s <- " prod;
    StringSet.iter matched (fun s ->
      Printf.printf "%s " s);
    Printf.printf "\n");
  flush stdout

let rec find_layers_rec prec =
  if StringMap.is_empty prec then [] else 
  let layer, prec = StringMap.fold prec ([],StringMap.empty) (fun (found,prec) prod matched ->
    if StringSet.is_empty matched then prod :: found, prec
    else found, StringMap.add prec prod matched) in
  if layer = [] then (print_prec prec; invalid_arg "Recurent symbols");
  let prec = StringMap.map prec (fun matched ->
    Xlist.fold layer matched (fun matched symbol ->
      StringSet.remove matched symbol)) in
  layer :: (find_layers_rec prec)

let find_layers rules = 
(*print_endline "find_layers 1";*)
  let prec = RuleSet.fold rules StringMap.empty (fun prec -> function
      Normal(_,prod,match_list,white,_) -> add_prec_prod prec prod (white :: match_list)
    | Specific(_,prod,_,match_list,_) -> add_prec_prod prec prod (Xlist.map match_list (fun (s,_,_) -> s))
    | Delete (_,matched) -> add_prec_empty prec [matched]
    | Accumulate(_,prod,matched,white,_) -> add_prec_prod prec prod [matched;white]
    | AccumulateLeft(_,prod,matched,left_match,white,_) -> add_prec_prod prec prod [matched;white;left_match]
    | AccumulateRight(_,prod,matched,right_match,white,_) -> add_prec_prod prec prod [matched;white;right_match]) in
(*print_endline "find_layers 2";*)
  find_layers_rec prec

let add_rule_to_layers_map layers map prod rule =
  IntMap.add_inc map (StringMap.find layers prod) [rule] (fun l -> rule :: l)

let divide_rules_into_layers rules =
(*print_endline "divide_rules_into_layers 1";*)
  if RuleSet.is_empty rules then IntMap.empty else
  let layers,n = Xlist.fold (List.tl (find_layers rules)) (StringMap.empty,1) (fun (map,n) layer -> 
    Xlist.fold layer map (fun map s -> StringMap.add map s n), n+1)  in
(*print_endline "divide_rules_into_layers 2";*)
  RuleSet.fold rules IntMap.empty (fun map -> function
      Normal(status,prod,match_list,white,sem) -> 
	add_rule_to_layers_map layers map prod (Normal(status,prod,match_list,white,sem))
    | Specific(status,prod,id,match_list,sem) -> 
	add_rule_to_layers_map layers map prod (Specific(status,prod,id,match_list,sem))
    | Delete (status,matched) -> 
	IntMap.add_inc map n [Delete (status,matched)] (fun l -> (Delete (status,matched)) :: l)
    | Accumulate(status,prod,matched,white,sem) -> 
	add_rule_to_layers_map layers map prod (Accumulate(status,prod,matched,white,sem))
    | AccumulateLeft(status,prod,matched,left_match,white,sem) -> 
	add_rule_to_layers_map layers map prod (AccumulateLeft(status,prod,matched,left_match,white,sem))
    | AccumulateRight(status,prod,matched,right_match,white,sem) -> 
	add_rule_to_layers_map layers map prod (AccumulateRight(status,prod,matched,right_match,white,sem)))

type tree = N of tree StringMap.t * (string * semantic_action) list

type prepared_rule =
    PreparedNormal of tree * grammar_symbol
  | PreparedSpecific of ((string * semantic_action) * variable list) list StringMap.t
  | PreparedDelete of StringSet.t
  | PreparedAccumulate of (string * acc_semantic_action) * grammar_symbol * grammar_symbol
  | PreparedAccumulateLeft of (string * acc_semantic_action) * grammar_symbol * grammar_symbol * grammar_symbol
  | PreparedAccumulateRight of (string * acc_semantic_action) * grammar_symbol * grammar_symbol * grammar_symbol

let tree_empty = N (StringMap.empty,[])

let rec tree_add (N(map,list)) match_list action =
  match match_list with
    [] -> N(map, action :: list)
  | s :: l -> 
      let tree = try 
	StringMap.find map s 
      with Not_found -> tree_empty in
      let tree = tree_add tree l action in
      N (StringMap.add map s tree, list)

let tree_of_list list = 
  Xlist.fold list tree_empty (fun tree -> fun (action,match_list) ->
    tree_add tree match_list action)

let prepare_normal list =
  let map = Xlist.fold list StringMap.empty (fun map (prod,match_list,white,sem) ->
    StringMap.add_inc map white [(prod,sem),match_list] (fun l -> ((prod,sem),match_list) :: l)) in
  StringMap.fold map [] (fun list white rules ->
    PreparedNormal(tree_of_list rules, white) :: list)

let prepare_specific list =
  if list = [] then [] else
  [PreparedSpecific(Xlist.fold list StringMap.empty (fun map (prod,id,match_list,sem) ->
    StringMap.add_inc map id [(prod,sem),match_list] (fun l -> ((prod,sem),match_list) :: l)))]

let prepare_delete list =
  if list = [] then [] else 
  [PreparedDelete(StringSet.of_list list)]

let prepare_acc list = 
  Xlist.map list (fun (prod,matched,white,sem) ->
    PreparedAccumulate((prod,sem),matched,white))

let prepare_acc_left list = 
  Xlist.map list (fun (prod,matched,left_match,white,sem) ->
    PreparedAccumulateLeft((prod,sem),matched,left_match,white))

let prepare_acc_right list = 
  Xlist.map list (fun (prod,matched,right_match,white,sem) ->
    PreparedAccumulateRight((prod,sem),matched,right_match,white))

let prepare_for_parsing rule_layers semantic_parser acc_semantic_parser = 
(*print_endline "prepare_for_parsing";*)
  List.rev (Int.fold 1 (IntMap.size rule_layers) [] (fun list i ->
    let rules = IntMap.find rule_layers i in
    let normal,specific,delete,acc,acc_left,acc_right = 
      Xlist.fold rules ([],[],[],[],[],[]) (fun (normal,specific,delete,acc,acc_left,acc_right) -> function
	  Normal(status,prod,match_list,white,sem) -> 
	    if status = Disabled then (normal,specific,delete,acc,acc_left,acc_right) else
	    ((prod,match_list,white,semantic_parser sem) :: normal,specific,delete,acc,acc_left,acc_right)
	| Specific(status,prod,id,match_list,sem) -> 
	    if status = Disabled then (normal,specific,delete,acc,acc_left,acc_right) else
	    (normal,(prod,id,match_list,semantic_parser sem) :: specific,delete,acc,acc_left,acc_right)
	| Delete (status,matched) -> 
	    if status = Disabled then (normal,specific,delete,acc,acc_left,acc_right) else
	    (normal,specific,(matched) :: delete,acc,acc_left,acc_right)
	| Accumulate(status,prod,matched,white,sem) -> 
	    if status = Disabled then (normal,specific,delete,acc,acc_left,acc_right) else
	    (normal,specific,delete,(prod,matched,white,acc_semantic_parser sem) :: acc,acc_left,acc_right)
	| AccumulateLeft(status,prod,matched,left_match,white,sem) -> 
	    if status = Disabled then (normal,specific,delete,acc,acc_left,acc_right) else
	    (normal,specific,delete,acc,(prod,matched,left_match,white,acc_semantic_parser sem) :: acc_left,acc_right)
	| AccumulateRight(status,prod,matched,right_match,white,sem) -> 
	    if status = Disabled then (normal,specific,delete,acc,acc_left,acc_right) else
	    (normal,specific,delete,acc,acc_left,(prod,matched,right_match,white,acc_semantic_parser sem) :: acc_right)) in 
    (prepare_acc_right acc_right) @ (prepare_acc_left acc_left) @ (prepare_acc acc) @ 
    (prepare_delete delete) @ (prepare_specific specific) @ (prepare_normal normal) @ list))

(*    let only_dots list =
      Xlist.fold list true (fun b term ->
	if TermGraph.name term = "x" || TermGraph.name term = "xx" then b else false)*)

(*    let rec merge_maps map1 map2 =
      StringMap.fold map2 map1 (fun map1 key (N(map2,actions2)) ->
	StringMap.add_inc map1 key (N(map2,actions2)) (fun (N(map1,actions1)) ->
	  N(merge_maps map1 map2,actions2 @ actions1)))

    let merge_next_level map =
      if StringMap.size map = 0 then raise Not_found else
      StringMap.fold map (N(StringMap.empty, [])) (fun (N(map1,actions1)) key (N(map2,actions2)) ->
	if key = "tablet" || key = "end_tablet" || key = "%" || key = "line_number" || key = "left" || key = "seal" || 
	key = "Left" || key = "End1" || key = "Seal" || key = "Tablet" 
	then N(map1,actions1) else
	  N(merge_maps map1 map2,actions2 @ actions1))*)

(*    let reduce trees i =
      let tree = IndexMap.find trees i in
      let s = Xlist.size tree in
      if s > 10000 then 
(*let tree = Xlist.fold tree [] (fun list (i,cur,t) -> if only_dots cur && Xlist.size cur > 6 then list else (i,cur,t) :: list) in *)
	let tree = CosSet.to_list (CosSet.of_list tree) in ( 
(*	Printf.printf "left=%d before_size=%d after_size=%d\n" i s (Xlist.size tree); *)
	flush stdout;
	IndexMap.add trees i tree
       ) else trees*)

let find_normal tree white graph =
  let trees = IntSet.fold (Syntax_graph.node_set graph) IntMap.empty (fun map -> fun i ->
    IntMap.add map i [i,[],tree]) in
  fst (Syntax_graph.fold graph ([],trees) (fun (found,trees) -> fun (symbol,i,j,formula,layer) -> 
(*    let trees = reduce trees i in *) (* brzydki trik !!! *)
    Xlist.fold (IntMap.find trees i) (found,trees) (fun (found,trees) -> fun (i0, cur, (N(map,actions))) ->
      if symbol = white then 
	found,
	if cur = [] then trees else
	let v = i0, cur, (N(map,actions)) in
	IntMap.add_inc trees j [v] (fun l -> v :: l) 
      else
(*	if symbol = "xx" || symbol term = "x" then
	  try 
	    let N(map2,actions2) = merge_next_level map in
	    (if only_dots cur then found else
	    if actions2 = [] then found else (i0, j, List.rev ((symbol,i,j,formula,layer) :: cur), actions2) :: found),
	    let v = i0, (symbol,i,j,formula,layer) :: cur, (N(map2,actions2)) in
	    IndexMap.add_inc trees j [v] (fun l -> v :: l)
	  with Not_found -> found,trees
	else*)
	  try
	    let N(map2,actions2) = StringMap.find map symbol in
	    (if actions2 = [] then found else (i0, j, List.rev ((symbol,i,j,formula,layer) :: cur), actions2) :: found),
	    (let v = i0, (symbol,i,j,formula,layer) :: cur, (N(map2,actions2)) in
	    IntMap.add_inc trees j [v] (fun l -> v :: l))
	  with Not_found -> found,trees)))

let apply_normal tree white graph =
  Xlist.fold (find_normal tree white graph) graph (fun graph -> fun (i, j, list, actions) ->
    Xlist.fold actions graph (fun graph -> fun (prod, action) ->
      Syntax_graph.add graph (prod,i,j) list action))
    
let apply_delete set graph =
  Syntax_graph.fold graph Syntax_graph.empty (fun graph -> fun (symbol,i,j,formula,layer) ->
    if StringSet.mem set symbol then graph else
    Syntax_graph.insert_set graph (symbol,i,j) formula layer)

let find_accumulate action matched white graph =
  let term_ends = IntSet.fold (Syntax_graph.node_set graph) IntMap.empty (fun map -> fun i ->
    IntMap.add map i (IntMap.add IntMap.empty i (AccTree []))) in
  let found,_,_ = Syntax_graph.fold_right graph ([],term_ends,0) (fun (found,term_ends,count) (symbol,j,i,formula,layer) -> 
    IntMap.fold (IntMap.find term_ends i) (found,term_ends,count) (fun (found,term_ends,count) i0 (AccTree v) ->
      if symbol = white then 
	found,
	(if v = [] then term_ends else
	let term_begins = try IntMap.find term_ends j with Not_found -> IntMap.empty in
	let term_begins = IntMap.add_inc term_begins i0 (AccTree v) 
	    (fun (AccTree l) -> AccTree (v @ l)) in
	IntMap.add term_ends j term_begins),
	count + 1
      else
	if symbol = matched (*|| TermGraph.name term = "xx" || TermGraph.name term = "x"*) then
	  let v = count, (symbol,j,i,formula,layer), (AccTree v) in
	  (j, i0, AccTree [v], action) :: found,
	  (let term_begins = try IntMap.find term_ends j with Not_found -> IntMap.empty in
	  let term_begins = IntMap.add_inc term_begins i0 (AccTree [v]) 
	      (fun (AccTree l) -> AccTree (v :: l)) in
	  IntMap.add term_ends j term_begins),
	  count + 1 
	else found,term_ends,count)) in
  found

let find_accumulate_right action matched right_match white graph =
  let term_ends = Syntax_graph.fold graph IntMap.empty (fun map -> fun (symbol,i,j,formula,layer) ->
    if right_match = symbol then IntMap.add map i (IntMap.add IntMap.empty i (AccTree [])) else map) in
  let found,_,_ = Syntax_graph.fold_right graph ([],term_ends,0) (fun (found,term_ends,count) (symbol,j,i,formula,layer) -> 
    try
      IntMap.fold (IntMap.find term_ends i) (found,term_ends,count) (fun (found,term_ends,count) i0 (AccTree v) ->
	if symbol = white then 
	  found,
	  (let term_begins = try IntMap.find term_ends j with Not_found -> IntMap.empty in
	  let term_begins = 
	    if v = [] then IntMap.add_inc term_begins j (AccTree v) (fun x -> x) 
	    else IntMap.add_inc term_begins i0 (AccTree v) 
		(fun (AccTree l) -> AccTree (v @ l)) in
	  IntMap.add term_ends j term_begins),
	  count + 1
	else
	  if symbol = matched (*|| TermGraph.name term = "xx" || TermGraph.name term = "x"*) then
	    let v = count, (symbol,j,i,formula,layer), (AccTree v) in
	    (j, i0, AccTree [v], action) :: found,
	    (let term_begins = try IntMap.find term_ends j with Not_found -> IntMap.empty in
	    let term_begins = IntMap.add_inc term_begins i0 (AccTree [v]) 
		(fun (AccTree l) -> AccTree (v :: l)) in
	    IntMap.add term_ends j term_begins),
	    count + 1 
	  else found,term_ends,count)
    with Not_found -> found, term_ends, count+1) in
  found

let apply_accumulate_left action matched left_match white graph = failwith "ni"

let apply_accumulate action matched white graph =
  Xlist.fold (find_accumulate action matched white graph) graph (fun graph -> fun (i,j, acc_tree, (prod, action)) ->
    Syntax_graph.add_acc graph (prod,i,j) acc_tree action)

let apply_accumulate_right action matched right_match white graph =
  Xlist.fold (find_accumulate_right action matched right_match white graph) graph (fun graph -> fun (i,j, acc_tree, (prod, action)) ->
    Syntax_graph.add_acc graph (prod,i,j) acc_tree action)

let find_specific rules id graph =
  Xlist.fold (try StringMap.find rules id with Not_found -> []) [] (fun found (action,list) ->
    try 
      let _,i,_ = List.hd list in
      let _,_,j = List.hd (List.rev list) in
      let list = Xlist.map list (Syntax_graph.find graph) in
      (i,j,list,action) :: found
    with Not_found -> (
      print_endline ("find_specific: Not_found: " ^ id); found))

let apply_specific rules id graph =
  Xlist.fold (find_specific rules id graph) graph (fun graph -> fun (i,j, list, (prod, action)) ->
    Syntax_graph.add graph (prod,i,j) list action)
   
let parse prepared_rules id graph = 
(*print_endline "parse";*)
  Xlist.fold prepared_rules graph (fun graph -> function 
      PreparedNormal(tree, white) -> apply_normal tree white graph
    | PreparedSpecific map -> apply_specific map id graph
    | PreparedDelete set -> apply_delete set graph
    | PreparedAccumulate(action,matched,white) -> apply_accumulate action matched white graph
    | PreparedAccumulateLeft(action,matched,left_match,white) -> apply_accumulate_left action matched left_match white graph
    | PreparedAccumulateRight(action,matched,right_match,white) -> apply_accumulate_right action matched right_match white graph)

