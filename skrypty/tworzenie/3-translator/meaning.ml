(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Types

let get_predicate_list list n =
  try
    let _,_,_,set,_ = List.nth list (n-1) in
    PredicateSet.to_list set
  with _ -> invalid_arg "get_predicate_list"

let list_predicate name list =
  Xlist.map (Xlist.multiply_list list) (fun args -> List(name,args))

let simple_predicates list =
  Xlist.map list Syntax_graph.simple_predicate

let predicate name list = 
  [List(name,Xlist.map list (fun (s,i,j,_,_) -> s,i,j))]

let rec concat_rec = function
    [] -> [""]
  | (_,_,_,set,_) :: l ->
      let list = concat_rec l in
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> 
	    Xlist.fold list l (fun l t -> (s ^ t) :: l)
(*	| List ("string_list",slist) -> 
	    let s = String.concat "" (string_of_arg slist) in 
	    Xlist.fold list l (fun l t -> (s ^ t) :: l)*)
	| _ -> invalid_arg "concat_rec")

let concat list =
  Xlist.map (concat_rec list) Syntax_graph.simple_predicate

let rec concat_minus_rec = function
    [] -> [""]
  | [_,_,_,set,_] ->
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> s :: l
(*	| List (_,[String s]) -> s :: l*)
	| _ -> invalid_arg "concat_minus_rec")
  | (_,_,_,set,_) :: l ->
      let list = concat_minus_rec l in
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> 
	    Xlist.fold list l (fun l t -> (s ^ "-" ^ t) :: l)
(*	| List (_,[String s]) -> 
	    Xlist.fold list l (fun l t -> (s ^ "-" ^ t) :: l)*)
	| _ -> invalid_arg "concat_minus_rec")

let concat_minus list =
  Xlist.map (concat_minus_rec list) Syntax_graph.simple_predicate

let rec concat_space_rec = function
    [] -> [""]
  | [_,_,_,set,_] ->
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> s :: l
(*	| List (_,[String s]) -> s :: l*)
	| _ -> invalid_arg "concat_space_rec")
  | (_,_,_,set,_) :: l ->
      let list = concat_space_rec l in
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> 
	    Xlist.fold list l (fun l t -> (s ^ " " ^ t) :: l)
(*	| List (_,[String s]) -> 
	    Xlist.fold list l (fun l t -> (s ^ " " ^ t) :: l)*)
	| _ -> invalid_arg "concat_space_rec")

let concat_space list =
  Xlist.map (concat_space_rec list) Syntax_graph.simple_predicate

let rec add_digits_rec = function
    [] -> [0]
  | (_,_,_,set,_) :: l ->
      let list = add_digits_rec l in
      PredicateSet.fold set [] (fun l -> function
	  List ("la2",[]) -> 
	    Xlist.fold list l (fun l t -> (- t) :: l)
	| List (s,[]) -> 
	    Xlist.fold list l (fun l t -> ((int_of_string s) + t) :: l)
	| _ -> invalid_arg "add_digits_rec")

let add_digits list =
  Xlist.map (add_digits_rec list) (fun n -> Syntax_graph.simple_predicate (string_of_int n))

let rec concat_acc_rec map (AccTree s) =
  Xlist.fold s map (fun map (count,(_,_,_,set,_),AccTree tr) ->  
    if IntMap.mem map count then map else
    let map = concat_acc_rec map (AccTree tr) in
    let suffixes =
      if tr = [] then StringSet.add StringSet.empty ""  (* tu korzystamy z tego, ze wezel jest terminujacy wtw gdy jest lisciem *)
      else
	Xlist.fold tr StringSet.empty (fun suffixes (count,_,_) -> 
	  StringSet.union suffixes (IntMap.find map count)) in
    let strings = 
      PredicateSet.fold set StringSet.empty (fun strings -> function
	  List (s,[]) -> 
	    StringSet.fold suffixes strings (fun strings suffix -> 
	      StringSet.add strings (s ^ suffix))
	| _ -> invalid_arg "concat_acc_rec") in
    IntMap.add map count strings)

let concat_acc (AccTree s) =
  let map = concat_acc_rec IntMap.empty (AccTree s) in
  let strings = Xlist.fold s StringSet.empty (fun set (count,_,_) ->
    StringSet.union set (IntMap.find map count)) in
  StringSet.fold strings [] (fun list s -> (Syntax_graph.simple_predicate s) :: list)


let rec map_of_tree map (AccTree s) =
  Xlist.fold s map (fun map (count,(symbol,i,j,_,_),AccTree tr) ->  
    if IntMap.mem map count then map else
    let map = 
      let set = Xlist.fold tr IntSet.empty (fun set (count,_,_) -> IntSet.add set count) in
      IntMap.add map count ((symbol,i,j),set) in
    map_of_tree map (AccTree tr))

let roots_of_tree (AccTree acc_tree) = 
  Xlist.fold acc_tree IntSet.empty (fun set (count,_,_) -> IntSet.add set count) 

let predicate_acc name acc_tree = 
  let roots = roots_of_tree acc_tree in
  let map = map_of_tree IntMap.empty acc_tree in
  [Acc(name,(roots,map))]

let inter list =
  let years,any = Xlist.fold list ([],false) (fun (years,any) list ->
    let years2,any2 = Xlist.fold list ([],any) (fun (years,any) -> function 
	"Any" -> years, true
      | x -> x :: years, any) in
    (StringSet.of_list years2) :: years, any2) in
  match years,any with
    [],true -> [Syntax_graph.simple_predicate "Any"]
  | [],false -> invalid_arg "inter"
  | years,_ -> 
      StringSet.fold (Xlist.fold (List.tl years) (List.hd years) StringSet.intersection) [] (fun list s ->
	(Syntax_graph.simple_predicate s) :: list)

let shift_string = function
    "SZ01" -> "SZ02"
  | "SZ02" -> "SZ03"
  | "SZ03" -> "SZ04"
  | "SZ04" -> "SZ05"
  | "SZ05" -> "SZ06"
  | "SZ06" -> "SZ07"
  | "SZ07" -> "SZ08"
  | "SZ08" -> "SZ09"
  | "SZ09" -> "SZ10"
  | "SZ10" -> "SZ11"
  | "SZ11" -> "SZ12"
  | "SZ12" -> "SZ13"
  | "SZ13" -> "SZ14"
  | "SZ14" -> "SZ15"
  | "SZ15" -> "SZ16"
  | "SZ16" -> "SZ17"
  | "SZ17" -> "SZ18"
  | "SZ18" -> "SZ19"
  | "SZ19" -> "SZ20"
  | "SZ20" -> "SZ21"
  | "SZ21" -> "SZ22"
  | "SZ22" -> "SZ23"
  | "SZ23" -> "SZ24"
  | "SZ24" -> "SZ25"
  | "SZ25" -> "SZ26"
  | "SZ26" -> "SZ27"
  | "SZ27" -> "SZ28"
  | "SZ28" -> "SZ29"
  | "SZ29" -> "SZ30"
  | "SZ30" -> "SZ31"
  | "SZ31" -> "SZ32"
  | "SZ32" -> "SZ33"
  | "SZ33" -> "SZ34"
  | "SZ34" -> "SZ35"
  | "SZ35" -> "SZ36"
  | "SZ36" -> "SZ37"
  | "SZ37" -> "SZ38"
  | "SZ38" -> "SZ39"
  | "SZ39" -> "SZ40"
  | "SZ40" -> "SZ41"
  | "SZ41" -> "SZ42"
  | "SZ42" -> "SZ43"
  | "SZ43" -> "SZ44"
  | "SZ44" -> "SZ45"
  | "SZ45" -> "SZ46"
  | "SZ46" -> "SZ47"
  | "SZ47" -> "SZ48"
  | "SZ48" -> "AS01"
  | "AS01" -> "AS02"
  | "AS02" -> "AS03"
  | "AS03" -> "AS04"
  | "AS04" -> "AS05"
  | "AS05" -> "AS06"
  | "AS06" -> "AS07"
  | "AS07" -> "AS08"
  | "AS08" -> "AS09"
  | "AS09" -> "SS01"
  | "SS01" -> "SS02"
  | "SS02" -> "SS03"
  | "SS03" -> "SS04"
  | "SS04" -> "SS05"
  | "SS05" -> "SS06"
  | "SS06" -> "SS07"
  | "SS07" -> "SS08"
  | "SS08" -> "SS09"
  | "SS09" -> "IS01"
  | "IS01" -> "IS02"
  | "IS02" -> "IS03"
  | "IS03" -> "IS04"
  | "IS04" -> "IS05"
  | "IS05" -> "IS06"
  | "IS06" -> "IS07"
  | "IS07" -> "IS08"
  | "IS08" -> "IS09"
  | "IS09" -> "IS10"
  | "IS10" -> "IS11"
  | "IS11" -> "IS12"
  | "IS12" -> "IS13"
  | "IS13" -> "IS14"
  | "IS14" -> "IS15"
  | "IS15" -> "IS16"
  | "IS16" -> "IS17"
  | "IS17" -> "IS18"
  | "IS18" -> "IS19"
  | "IS19" -> "IS20"
  | "IS20" -> "IS21"
  | "IS21" -> "IS22"
  | "IS22" -> "IS23"
  | "IS23" -> "IS24"
  | "IS24" -> "IS24+1"
  | "IE01" -> "IE02"
  | "IE02" -> "IE03"
  | "IE03" -> "IE04"
  | "IE04" -> "IE05"
  | "IE05" -> "IE06"
  | "IE06" -> "IE07"
  | "IE07" -> "IE08"
  | "IE08" -> "IE09"
  | "IE09" -> "IE10"
  | "IE10" -> "IE11"
  | "IE11" -> "IE12"
  | "IE12" -> "IE13"
  | "IE13" -> "IE14"
  | "IE14" -> "IE15"
  | "IE15" -> "IE16"
  | "IE16" -> "IE17"
  | "IE17" -> "IE18"
  | "IE18" -> "IE19"
  | "IE19" -> "IE20"
  | "IE20" -> "IE21"
  | "IE21" -> "IE22"
  | "IE22" -> "IE23"
  | "IE23" -> "IE24"
  | "IE24" -> "IE25"
  | "IE25" -> "IE26"
  | "IE26" -> "IE27"
  | "IE27" -> "IE28"
  | "IE28" -> "IE29"
  | "IE29" -> "IE30"
  | "IE30" -> "IE31"
  | "IE31" -> "IE32"
  | "IE32" -> "IE33"
  | "IE33" -> "SI01"
  | "SI01" -> "SI02"
  | "SI02" -> "SI03"
  | "SI03" -> "SI04"
  | "SI04" -> "SI05"
  | "SI05" -> "SI06"
  | "SI06" -> "SI07"
  | "SI07" -> "SI08"
  | "SI08" -> "SI09"
  | "SI09" -> "SI10"
  | "SI10" -> "ID01"
  | "ID01" -> "ID02"
  | "ID02" -> "ID03"
  | "ID03" -> "ID04"
  | "ID04" -> "ID05"
  | "ID05" -> "ID06"
  | "ID06" -> "ID07"
  | "ID07" -> "ID08"
  | "ID08" -> "ID09"
  | "ID09" -> "ID10"
  | "EB01" -> "EB02"
  | "UNo" -> "UNo+1"
  | x -> (*failwith ("Bad Year: " ^ x)*) x ^ "+1"

let shift list =
  Xlist.map list (function
    List(n,a) -> List(shift_string n,a)
  | Acc(n,a) -> Acc(shift_string n,a))


(*let arg_of_string list =
  Xlist.map list (fun s -> String s)*)

(*let string_of_arg list =
  Xlist.map list (function
      String s -> s
    | _ -> invalid_arg "string_of_arg")*)

let get_predicate_variable list n =
  try
    let s,n1,n2,_,_ = List.nth list (n-1) in
    (s,n1,n2)
  with _ -> invalid_arg "get_predicate_variable"

(*let get_simple_predicate_name_list list n =
  try
    let _,_,_,set,_ = List.nth list (n-1) in
    let list2 = StringSet.to_list (PredicateSet.fold set StringSet.empty (fun set -> function 
	List (s,[]) -> StringSet.add set s
      | _ -> invalid_arg "get_simple_predicate_name_list")) in
    arg_of_string list2
  with _ -> invalid_arg "get_predicate_list"*)

let get_simple_predicate_name_list_string list n =
  try
    let _,_,_,set,_ = List.nth list (n-1) in
    let list2 = StringSet.to_list (PredicateSet.fold set StringSet.empty (fun set -> function 
	List (s,[]) -> StringSet.add set s
      | _ -> invalid_arg "get_simple_predicate_name_list")) in
    list2
  with _ -> invalid_arg "get_predicate_list"

let rec concat_minus_rec = function
    [] -> [""]
  | [_,_,_,set,_] ->
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> s :: l
(*	| List (_,[String s]) -> s :: l*)
	| _ -> invalid_arg "concat_minus_rec")
  | (_,_,_,set,_) :: l ->
      let list = concat_minus_rec l in
      PredicateSet.fold set [] (fun l -> function
	  List (s,[]) -> 
	    Xlist.fold list l (fun l t -> (s ^ " " ^ t) :: l)
(*	| List (_,[String s]) -> 
	    Xlist.fold list l (fun l t -> (s ^ " " ^ t) :: l)*)
	| _ -> invalid_arg "concat_minus_rec")

(*let concat_as_list list =
  Xlist.map (Xlist.multiply_list list) (fun args -> 
    let args = string_of_arg args in
    Syntax_graph.simple_predicate (String.concat "%" args))*)


(*let rec make_god_rec = function
    ("d",_,_,_,_) :: l -> "{d}" ^ (make_god_rec l)
  | [s,_,_,_,_] -> s
  | [] -> ""
  | (s,_,_,_,_) :: l -> s ^ "-" ^ (make_god_rec l)

let make_god list = 
  [List("God",[String (make_god_rec list (*merge_xx list*))])]

let make_city list = 
  let list2,ki = 
    match List.rev list with
    | ("ki",_,_,_, _) :: l -> List.rev l, "{ki}"
    | x -> list, "" in
  Xlist.map (concat_minus_rec list2) (fun s -> (List("City",[String(s ^ ki)])))

let make_string s list =
  Xlist.map (concat_minus_rec list) (fun x -> (List(s,[String x])))*)

(*let syntax list =
  String (String.concat "-" (Xlist.map list (fun (x,_,_,_,_) -> x)))*)


(****
   type v = int * int * string
   type t = (string * tm) list 
(*and tree = 
   Tree of (int * v * tree) list*)
   and tm = 
   Unit
   | String of string 
   | Int of int 
   | IntString of int * string 
   | Tlist of s list 
   | Acc of IntSet.t * (v * IntSet.t) IntMap.t 
   and s = S of v | T of t

   let compare = compare
   let empty = ["",Unit]

   exception Meaning_list of (string * t) list

   module OrderedTM = struct

   type t = string * tm
   let compare = compare
   let to_string _ = failwith "Not implemented"

   let of_string _ = failwith "Not implemented"

   end

   module TMSet = Xset.Make(OrderedTM)

   let union_string list =
   let list2 = Xlist.fold list [] (fun l s -> (StringSet.of_list s) :: l) in
   StringSet.to_list (Xlist.fold (List.tl list2) (List.hd list2) StringSet.union)

   let string_of_tm_list s = function
   Unit -> s
   | String t -> t
   | Int t -> string_of_int t
   | IntString (t1,t2) -> string_of_int t1 ^ "(" ^ t2 ^ ")"
   | Acc _ -> s
   | Tlist l -> String.concat "-" (Xlist.map l (function 
   S (_,_,s) -> s
   | T ((s,_) :: _) -> s))

   let rec concat_string_minus_rec = function
   [] -> failwith "concat_string_minus_rec"
   | [list] -> list
   | list1 :: list2 :: l -> concat_string_minus_rec ((List.flatten (Xlist.map list1 (fun s ->
   Xlist.map list2 (fun t -> s ^ "-" ^ t)))) :: l)
(****
   let rec string_of_add_digit list =
   List.flatten (Xlist.map list (function
   Tlist ["Digit",_,_,x1;"Digit",_,_,x2] -> 
   concat_string_minus_rec [string_of_tm_list "Digit" x1; string_of_tm_list "Digit" x2] 
   | Tlist ["AddDigit",_,_,x1;"Digit",_,_,x2] -> 
   concat_string_minus_rec [string_of_add_digit x1; string_of_tm_list "Digit" x2]
   | Tlist ["SubDigit",_,_,x1;"Digit",_,_,x2] -> 
   concat_string_minus_rec [string_of_sub_digit x1; string_of_tm_list "Digit" x2] 
   | Unit -> ["..."]
   | _ -> (*failwith "string_of_add_digit"*) ["???"]))

   and string_of_sub_digit list =
   List.flatten (Xlist.map list (function
   Tlist ["Digit",_,_,x1;"Digit",_,_,x2] -> 
   concat_string_minus_rec [string_of_tm_list "Digit" x1; ["la2"]; string_of_tm_list "Digit" x2] 
   | Tlist ["AddDigit",_,_,x1;"Digit",_,_,x2] -> 
   concat_string_minus_rec [string_of_add_digit x1; ["la2"]; string_of_tm_list "Digit" x2]
   | Tlist ["SubDigit",_,_,x1;"Digit",_,_,x2] -> 
   concat_string_minus_rec [string_of_sub_digit x1; ["la2"]; string_of_tm_list "Digit" x2] 
   | Unit -> ["..."]
   | _ -> (*failwith "string_of_sub_digit"*) ["???"]))
 ****)
(* let rec merge_xx_rec ((i,j,n),m) = function
   [] -> [n,m]
   | (T ((i2,j2,"xx"),m2)) :: l -> if n = "..." then merge_xx_rec ((i,j2,n),m) l else ((i,j,n),m) :: (merge_xx_rec ((i2,j2,"..."),m2) l)
   | x :: l -> ((i,j,n),m) :: (merge_xx_rec x l)

   let merge_xx = function
   [] -> []
   | ((i,j,"xx"),m) :: l -> merge_xx_rec ((i,j,"..."),m) l
   | x :: l -> merge_xx_rec x l*)


   exception Unit_list
   exception Destr_list



 ****)
