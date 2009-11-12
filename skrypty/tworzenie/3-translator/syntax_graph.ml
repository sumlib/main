(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Types

let empty = SyntaxGraph.empty

let regexp = Str.regexp ","

let insert graph variable formula layer =
  SyntaxGraph.add_inc graph variable (PredicateSet.add PredicateSet.empty formula,layer)
    (fun (f,l) -> PredicateSet.add f formula, max l layer)

let insert_set graph variable formula_set layer =
  SyntaxGraph.add_inc graph variable (formula_set,layer)
    (fun (f,l) -> PredicateSet.union f formula_set, max l layer)

let max_layer list =
  Xlist.fold list (-1) (fun l (_,_,_,_,k) -> max l k)

let add graph variable list action =
  let formulas = action list in
  let layer = max_layer list + 1 in
  Xlist.fold formulas graph (fun graph -> function
      List("",[]) -> insert graph variable (List("",[])) layer
    | List(",",[]) -> insert graph variable (List(",",[])) layer
    | List(n,[]) -> 
	let list = Str.split regexp n in
	let _,i,j = variable in
	let graph = Xlist.fold (List.tl list) graph (fun graph s ->
	  insert graph (s,i,j) (List(s,[])) layer) in
	insert graph variable (List(List.hd list,Xlist.map (List.tl list) (fun s -> s,i,j))) (layer+1)
    | formula -> insert graph variable formula layer)

let rec acc_tree_layer (set,layer) (AccTree s) =
  Xlist.fold s (set,layer) (fun (set,layer) (count,(_,_,_,_,l),tree) ->  
    if IntSet.mem set count then (set,layer) else
    acc_tree_layer (IntSet.add set count,max l layer) tree)

let add_acc graph variable acc_tree action =
  let formulas = action acc_tree in
  let _,layer = acc_tree_layer (IntSet.empty,-1) acc_tree in
  Xlist.fold formulas graph (fun graph formula ->
    insert graph variable formula (layer+1))

let edge_compare (s1,n1,m1,f1,l1) (s2,n2,m2,f2,l2) =
  if n1 <> n2 then compare n1 n2 else
  if m1 <> m2 then compare m1 m2 else
  compare s1 s2

let edge_compare_right (s1,n1,m1,f1,l1) (s2,n2,m2,f2,l2) =
  if m1 <> m2 then compare m2 m1 else
  if n1 <> n2 then compare n2 n1 else
  compare s1 s2

let fold graph s f =
  let list = SyntaxGraph.fold graph [] (fun l (symbol,node1,node2) (formula,layer) ->
    (symbol,node1,node2,formula,layer) :: l) in
  Xlist.fold (List.sort edge_compare list) s f

let fold_right graph s f =
  let list = SyntaxGraph.fold graph [] (fun l (symbol,node1,node2) (formula,layer) ->
    (symbol,node1,node2,formula,layer) :: l) in
  Xlist.fold (List.sort edge_compare_right list) s f

let find graph (symbol,node1,node2) =
  let formula,layer = SyntaxGraph.find graph (symbol,node1,node2) in
  symbol,node1,node2,formula,layer

let mem graph (symbol,node1,node2) =
  SyntaxGraph.mem graph (symbol,node1,node2)

let node_set graph =
  SyntaxGraph.fold graph IntSet.empty (fun set (_,node1,node2) _ ->
    IntSet.add (IntSet.add set node1) node2)

let simple_predicate s = List (s,[])

let xml_print_predicate_args buf args =
  Xlist.iter args (fun (symbol,node1,node2) -> 
    Buffer.add_string buf (Printf.sprintf "      <var symbol=\"%s\" node1=\"%d\" node2=\"%d\"/>\n" (refs symbol) node1 node2))

let xml_print_acc_graph buf (roots,nodes) =
  Buffer.add_string buf (Printf.sprintf "      <roots>");
  IntSet.iter roots (fun x -> Buffer.add_string buf (Printf.sprintf "<int>%d</int>" x));
  Buffer.add_string buf (Printf.sprintf "</roots>\n");
  IntMap.iter nodes (fun id ((symbol,node1,node2),nexts) ->
    Buffer.add_string buf (Printf.sprintf "      <node id=\"%d\" symbol=\"%s\" node1=\"%d\" node2=\"%d\">" id (refs symbol) node1 node2);
    IntSet.iter nexts (fun x -> Buffer.add_string buf (Printf.sprintf "<int>%d</int>" x));
    Buffer.add_string buf (Printf.sprintf "</node>\n"))

let xml_print_formula buf formula =
  PredicateSet.iter formula (function  
      List (name,args) ->
	Buffer.add_string buf (Printf.sprintf "    <list_predicate name=\"%s\">\n" (refs name));
	xml_print_predicate_args buf args;
	Buffer.add_string buf (Printf.sprintf "    </list_predicate>\n")
    | Acc (name,acc_graph) ->
	Buffer.add_string buf (Printf.sprintf "    <acc_predicate name=\"%s\">\n" (refs name));
	xml_print_acc_graph buf acc_graph;
	Buffer.add_string buf (Printf.sprintf "    </acc_predicate>\n"))

let xml_print buf id graph =
  Buffer.add_string buf (Printf.sprintf "<graph id=\"%s\">\n" (refs id));
  fold graph () (fun () (symbol,node1,node2,formula,layer) ->
    Buffer.add_string buf 
(Printf.sprintf "  <graph_edge symbol=\"%s\" node1=\"%d\" node2=\"%d\" layer=\"%d\">\n" (refs symbol) node1 node2 layer);
    xml_print_formula buf formula;
    Buffer.add_string buf (Printf.sprintf "  </graph_edge>\n"));
  Buffer.add_string buf (Printf.sprintf "</graph>\n")

let xml_scan filename =
  File.file_in_gzip filename (fun file  ->
    let lex = Lexing.from_function (fun buf len -> Gzip.input file buf 0 len) in
    try    
      snd (XmlParser.corpus XmlLexer.token lex)
    with Parsing.Parse_error -> failwith ("xml_scan " ^ filename ^ ": Parse_error"))

let xml_fold filename s f =
  let a,_,_ = Gc.counters () in
  let memory = ref (a +. 2000000000.) in
  File.file_in_gzip filename (fun file  ->
    let lex = Lexing.from_function (fun buf len -> Gzip.input file buf 0 len) in
    let size = XmlParser.corpus_start XmlLexer.token lex in
    let progress = Progress.create "Fold XML" size in
    let r = ref s in
    try
      while true do
	try    
	  let a,b,c = Gc.counters () in
	  if a > (!memory) then (
	    memory := (!memory) +. 2000000000.;
	    Gc.compact ();
	    Printf.printf "%f %f %f\n" a b c;
	    flush stdout);
	  let graph = XmlParser.graph XmlLexer.token lex in
	  r := f (!r) graph;
	  Progress.next progress
	with Parsing.Parse_error -> failwith ("xml_fold " ^ filename ^ ": Parse_error")
      done;
      !r
    with End_of_file -> 
      Progress.destroy progress;
      Gc.compact ();
      !r)

let xml_map filename_in filename_out f =
  let a,_,_ = Gc.counters () in
  let memory = ref (a +. 2000000000.) in
  let buf = Buffer.create 1000000 in
  File.file_in_gzip filename_in (fun file_in  ->
    File.file_out_gzip filename_out (fun file_out  ->
      let lex = Lexing.from_function (fun buf len -> Gzip.input file_in buf 0 len) in
      let size = XmlParser.corpus_start XmlLexer.token lex in
      let progress = Progress.create "Map XML" size in
      File.output_string_gzip file_out ("<corpus size=\"" ^ (string_of_int size) ^"\">\n");
      try
	while true do
	  try    
	    let a,b,c = Gc.counters () in
	    if a > (!memory) then (
	      memory := (!memory) +. 2000000000.;
	      Gc.compact ();
	      Printf.printf "%f %f %f\n" a b c;
	      flush stdout);
	    let id,graph = f (XmlParser.graph XmlLexer.token lex) in
	    xml_print buf id graph;
	    File.output_string_gzip file_out (Buffer.contents buf);
	    Buffer.clear buf;
	    Progress.next progress
	  with Parsing.Parse_error -> failwith ("xml_map " ^ filename_in ^ ": Parse_error")
	done
      with End_of_file -> 
	File.output_string_gzip file_out "</corpus>\n";
	Progress.destroy progress;
	Gc.compact ()))

let xml_print_attributes buf id map =
  Buffer.add_string buf (Printf.sprintf "<graph id=\"%s\">\n" (refs id));
  StringMap.iter map (fun k v ->
    Buffer.add_string buf 
      (Printf.sprintf "  <attribute name=\"%s\" value=\"%s\"/>\n" (refs k) (refs v)));
  Buffer.add_string buf (Printf.sprintf "</graph>\n")

let xml_scan_attributes filename =
  File.file_in_gzip filename (fun file  ->
    let lex = Lexing.from_function (fun buf len -> Gzip.input file buf 0 len) in
    try    
      snd (XmlParser.corpus2 XmlLexer.token lex)
    with Parsing.Parse_error -> failwith ("xml_scan " ^ filename ^ ": Parse_error"))

