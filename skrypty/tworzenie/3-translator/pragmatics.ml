(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Types

exception TextNotParsed
exception InvalidGrammar

let rec list_of_acc_rec id nodes map =
  if IntMap.mem map id then map
  else
    let v,succ = IntMap.find nodes id in
    if IntSet.size succ = 0 then 
      IntMap.add map id [[v]]
    else
      let map = IntSet.fold succ map (fun map id2 -> list_of_acc_rec id2 nodes map) in
      let list = IntSet.fold succ [] (fun list id2 ->
	Xlist.fold (IntMap.find map id2) list (fun list l ->
	  (v :: l) :: list)) in
      IntMap.add map id list

let list_of_acc = function
    Acc(n,(roots,nodes)) ->
      let map = IntSet.fold roots IntMap.empty (fun map id -> list_of_acc_rec id nodes map) in
      IntSet.fold roots PredicateSet.empty (fun set id -> 
	Xlist.fold (IntMap.find map id) set (fun set vlist ->
	  PredicateSet.add set (List(n,vlist))))
  | _ -> invalid_arg "list_of_acc"

let create_parse_and_find rules text symbol =
  let graph = Syntax_graph.empty in
  let graph = Syntax_graph.insert graph ("@begin", 0, 1) (Syntax_graph.simple_predicate "@begin") 0 in
  let graph,counter = Int.fold 0 (String.length text - 1) (graph,1) (fun (graph,counter) i ->
    let c = String.sub text i 1 in
    Syntax_graph.insert graph (c, counter, counter+1) (Syntax_graph.simple_predicate c) 0, counter+1) in
  let graph = Syntax_graph.insert graph ("@end", counter, counter+1) (Syntax_graph.simple_predicate "@end") 0 in
(*let buf = Buffer.create 1000000 in
Syntax_graph.xml_print buf "" graph;*)
  let parsed_graph = Parser.parse rules "" graph in
(*Syntax_graph.xml_print buf "" parsed_graph;
print_endline (Buffer.contents buf);*)
  let var_list = Syntax_graph.fold parsed_graph [] (fun list (s,i,j,_,_) ->
    if s = symbol then (s,i,j) :: list else list) in
  match var_list with 
    [] -> raise TextNotParsed
  | [v] -> parsed_graph,v
  | _ -> raise InvalidGrammar

let create_parse_and_find2 rules text symbol =
  let graph = Syntax_graph.empty in
  let graph = Syntax_graph.insert graph ("@begin", 0, 1) (Syntax_graph.simple_predicate "@begin") 0 in
  let graph,counter = Xlist.fold text (graph,1) (fun (graph,counter) c ->
    Syntax_graph.insert graph (c, counter, counter+1) (Syntax_graph.simple_predicate c) 0, counter+1) in
  let graph = Syntax_graph.insert graph ("@end", counter, counter+1) (Syntax_graph.simple_predicate "@end") 0 in
(*let buf = Buffer.create 1000000 in
Syntax_graph.xml_print buf "" graph;*)
  let parsed_graph = Parser.parse rules "" graph in
(*Syntax_graph.xml_print buf "" parsed_graph;
print_endline (Buffer.contents buf);*)
  let var_list = Syntax_graph.fold parsed_graph [] (fun list (s,i,j,_,_) ->
    if s = symbol then (s,i,j) :: list else list) in
  match var_list with 
    [] -> raise TextNotParsed
  | [v] -> parsed_graph,v
  | _ -> raise InvalidGrammar

let string_meaning (graph,v) =
  let _,_,_,sem,_ = try Syntax_graph.find graph v with Not_found -> failwith "string_meaning: variable not found" in
  PredicateSet.fold sem [] (fun list -> function
      List(x,[]) -> x :: list
    | _ -> raise InvalidGrammar)

module OrderedStringList = struct

  type t = string list

  let compare = compare

  let to_string _ = failwith "Not implemented"

  let of_string _ = failwith "Not implemented"

end

module StringListSet = Xset.Make(OrderedStringList)

(* dostaje graf i zmienna, a zwraca liste list stringow *)
let rec string_list_meaning (graph,v) = 
  let _,_,_,sem,_ = try Syntax_graph.find graph v with Not_found -> failwith "string_list_meaning: variable not found" in
  StringListSet.to_list (PredicateSet.fold sem StringListSet.empty (fun set -> function 
      List (s,[]) -> StringListSet.add set [s]
    | List ("string_list",vlist) -> StringListSet.union (string_list_meaning_rec graph vlist) set
    | Acc ("string_list",acc_graph) -> 
	PredicateSet.fold (list_of_acc (Acc ("string_list",acc_graph))) set (fun set -> function
	  | List ("string_list",vlist) -> StringListSet.union (string_list_meaning_rec graph vlist) set
	  | _ -> raise InvalidGrammar)
    | _ -> raise InvalidGrammar)) 

and string_list_meaning_rec graph vlist = 
  let list = Xlist.map vlist (fun v -> string_list_meaning (graph,v)) in
  StringListSet.of_list (Xlist.map (Xlist.multiply_list list) List.flatten)

(*let rec string_list_acc_rec map (AccTree s) =
  Xlist.fold s map (fun map (count,(_,_,_,set,_),AccTree tr) ->  
    if IntMap.mem map count then map else
    let map = string_list_acc_rec map (AccTree tr) in
    let suffixes =
      if tr = [] then StringListSet.add StringListSet.empty []  
      else
	Xlist.fold tr StringListSet.empty (fun suffixes (count,_,_) -> 
	  StringListSet.union suffixes (IntMap.find map count)) in
    let string_lists = 
      PredicateSet.fold set StringListSet.empty (fun string_lists -> function
	  List (s,[]) -> 
	    StringListSet.fold suffixes string_lists (fun string_lists suffix -> 
	      StringListSet.add string_lists (s :: suffix))
	| List ("string_list",slist) -> 
	    let s = string_of_arg slist in
	    StringListSet.fold suffixes string_lists (fun string_lists suffix -> 
	      StringListSet.add string_lists (s @ suffix))
	| _ -> invalid_arg "string_list_acc_rec") in
    IntMap.add map count string_lists)

let string_list_acc (AccTree s) =
  let map = string_list_acc_rec IntMap.empty (AccTree s) in
  let string_lists = Xlist.fold s StringListSet.empty (fun set (count,_,_) ->
    StringListSet.union set (IntMap.find map count)) in
  StringListSet.fold string_lists [] (fun list string_list -> (List("string_list",arg_of_string string_list)) :: list)*)

let rec parse_and_find_rec (s,i,j) = function
    [] -> [s,i,j]
  | (s2,i2,j2) :: l -> 
      if j > i2 then 
	if j - i >= j2 - i2 then parse_and_find_rec (s,i,j) l else parse_and_find_rec (s2,i2,j2) l 
      else (s,i,j) :: (parse_and_find_rec (s2,i2,j2) l)

let parse_and_find rules graph symbol =
  let parsed_graph = Parser.parse rules "" graph in
  let var_list = Syntax_graph.fold parsed_graph [] (fun list (s,i,j,_,_) ->
    if s = symbol then (s,i,j) :: list else list) in
  match List.sort (fun (_,i1,_) (_,i2,_) -> compare i1 i2) var_list with
    [] -> parsed_graph,[]
  | v :: l -> parsed_graph,parse_and_find_rec v l 


