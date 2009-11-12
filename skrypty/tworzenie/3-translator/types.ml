(********************************************************)
(*                                                      *)
(*  Copyright 2007, 2008 Wojciech Jaworski.             *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd

type graph_node = int
type grammar_symbol = string

type variable = grammar_symbol * graph_node * graph_node

type acc_graph = IntSet.t * (variable * IntSet.t) IntMap.t

type predicate = 
    List of string * variable list
  | Acc of string * acc_graph

module OrderedPredicate = struct

  type t = predicate

  let compare = compare

  let to_string _ = failwith "Not implemented"

  let of_string _ = failwith "Not implemented"

end

module PredicateSet = Xset.Make(OrderedPredicate)

type language_formula = PredicateSet.t

type layer = int

type graph_edge = grammar_symbol * graph_node * graph_node * language_formula * layer

type acc_tree = AccTree of (int * graph_edge * acc_tree) list

module OrderedVariable = struct

  type t = variable

  let compare = compare

  let to_string _ = failwith "Not implemented"

  let of_string _ = failwith "Not implemented"

end

module SyntaxGraph = Xmap.Make(OrderedVariable)

type graph = (language_formula * layer) SyntaxGraph.t

type status = Active | Disabled

type semantic_action = graph_edge list -> predicate list
type acc_semantic_action = acc_tree -> predicate list

type rule =
    Normal of status * grammar_symbol * grammar_symbol list * grammar_symbol * string  
  | Specific of status * grammar_symbol * string * variable list * string  
  | Delete of status * grammar_symbol
  | Accumulate of status * grammar_symbol * grammar_symbol * grammar_symbol * string  
  | AccumulateLeft of status * grammar_symbol * grammar_symbol * grammar_symbol * grammar_symbol * string 
  | AccumulateRight of status * grammar_symbol * grammar_symbol * grammar_symbol * grammar_symbol * string 

module OrderedRule = struct

  type t = rule

  let compare = compare

  let to_string _ = failwith "Not implemented"

  let of_string _ = failwith "Not implemented"

end

module RuleSet = Xset.Make(OrderedRule)


let refs s = 
  let buf = Buffer.create (String.length s * 2) in
  String.iter (function
      '&' -> Buffer.add_string buf "&amp;"
    | '<' -> Buffer.add_string buf "&lt;"
    | '>' -> Buffer.add_string buf "&gt;"
    | '\'' -> Buffer.add_string buf "&apos;"
    | '"' -> Buffer.add_string buf "&quot;"
    | c -> 
	if Char.code c < 32 || Char.code c > 127 
	then Buffer.add_string buf ("&#" ^ (string_of_int (Char.code c)) ^ ";")
	else Buffer.add_char buf c) s;
  Buffer.contents buf

let string_of_status = function
    Active -> "Active"
  | Disabled -> "Disabled"

let status_of_string = function
    "Active" -> Active
  | "Disabled" -> Disabled
  | _ -> failwith "status_of_string"


type subcorpus_status = Unloaded | Loaded | Showed | Parsed

let string_of_subcstatus = function
    Unloaded -> "Unloaded"
  | Loaded -> "Loaded"
  | Showed -> "Showed"
  | Parsed -> "Parsed"

let subcstatus_of_string = function
    "Unloaded" -> Unloaded
  | "Loaded" -> Loaded
  | "Showed" -> Showed
  | "Parsed" -> Parsed
  | _ -> failwith "string_of_subcstatus"

type subcorpus = {
    status: subcorpus_status;
    ids: StringSet.t}

