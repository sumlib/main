(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd

let rec greedy_sequencer_rec map i =
  try
    let symbol,j,layer = IntMap.find map i in
    (symbol,i,j) :: (greedy_sequencer_rec map j)
  with Not_found -> []

let greedy_sequencer graph =
  let map = Syntax_graph.fold graph IntMap.empty (fun map -> fun (symbol,i,j,_,layer) ->
    IntMap.add_inc map i (symbol,j,layer) (fun (symbol2,j2,layer2) -> 
      if j = j2 then  
	if layer > layer2 then symbol,j,layer else symbol2,j2,layer2 
      else if j > j2 then symbol,j,layer else symbol2,j2,layer2)) in
  greedy_sequencer_rec map 0

let rec split separator_set i0 cur = function
    [] -> if cur = [] then [] else [i0, (let _,_,j = List.hd cur in j), List.rev cur]
  | (symbol,i,j) :: l -> 
      if StringSet.mem separator_set symbol then
	(i0, j, List.rev ((symbol,i,j) :: cur)) :: (split separator_set j [] l)
      else split separator_set i0 ((symbol,i,j):: cur) l

let rec remove_white white = function
    [] -> []
  | (s,i,j) :: list -> 
      if s = white then remove_white white list else (s,i,j) :: (remove_white white list)

let parse graph separator white = 
  split (StringSet.add StringSet.empty separator) 0 [] (remove_white white (greedy_sequencer graph))

(*********************************************************************************)

let string_of_verse verse =
  String.concat " " (Xlist.map verse (fun (x,_) -> x)) 

let join map =
  StringMap.fold map StringMap.empty (fun joined -> fun id -> fun tablet ->
    Xlist.fold tablet joined (fun joined -> fun (i,j,verse) ->
      let v = Xlist.map verse (fun (x,i,j) -> x,(id,i,j)) in
      let key = string_of_verse v in
      let l = id,i,j in
      StringMap.add_inc joined key ([],Xlist.map v (fun (a,b) -> a,[b]),[],[l]) (fun (a,b,c,d) -> 
	a, Xlist.map2 v b (fun (a,b) -> fun (c,d) -> 
	  if a = c then a, b :: d else failwith "join"), c, l :: d)))

let select selection joined_lines =
  StringSet.fold selection StringMap.empty (fun map -> fun k ->
    try
      StringMap.add map k (StringMap.find joined_lines k)
    with Not_found -> map)

let select_one_graph verses =
  StringMap.map verses (fun (a,b,c,d) ->
    Xlist.map a (fun (a,b) -> a,[List.hd b]),
    Xlist.map b (fun (a,b) -> a,[List.hd b]),
    Xlist.map c (fun (a,b) -> a,[List.hd b]),
    [List.hd d])

let get_verses joined_verses =
  StringMap.fold joined_verses StringMap.empty (fun map -> fun _ -> fun (_,_,_,verses) ->
    Xlist.fold verses map (fun map -> fun (id,i,j) ->
      StringMap.add_inc map id [i,j] (fun l -> (i,j) :: l)))

let get_edges joined_verses =
  StringMap.fold joined_verses StringMap.empty (fun map -> fun _ -> fun (_,verses,_,_) ->
    Xlist.fold verses map (fun map -> fun (name,list) ->
      Xlist.fold list map (fun map -> fun (id,i,j) ->
	StringMap.add_inc map id [i,j,name] (fun l -> (i,j,name) :: l)))) 

let get_symbols joined_verses =
  StringMap.fold joined_verses [] (fun list _ (_,verses,_,_) ->
    (Xlist.map verses fst) :: list)

(*********************************************************************************)

let rec match_vis_beginning_rec = function
    [],l2 -> [],l2
  | t :: l1,(x,s) :: l2 -> if t = x then let f1,f2 = match_vis_beginning_rec (l1,l2) in (x,s) :: f1, f2 else raise Not_found
  | _ -> raise Not_found

let match_vis_beginning list vis =
  try
    match_vis_beginning_rec (list,vis) 
  with Not_found -> [],vis

let move_term_to_pre_vis terms joined_lines =
  let term_list = Str.split (Str.regexp " ") terms in
  StringMap.fold joined_lines StringMap.empty (fun map -> fun k -> fun (pre_vis,vis,post_vis,lines) ->
    let va,vb = match_vis_beginning term_list vis in
    let v = pre_vis @ va, vb,post_vis,lines in
    StringMap.add map k v)

let rec match_vis_rec list vis =
  try 
    let va, vb = match_vis_beginning_rec (list,vis) in
    [],va @ vb
  with Not_found -> 
    if vis = [] then raise Not_found else 
    let va, vb = match_vis_rec list (List.tl vis) in
    (List.hd vis) :: va, vb

let match_vis list vis =
  try
    match_vis_rec list vis
  with Not_found -> vis,[]

let move_term_to_post_vis terms joined_lines =
  let term_list = Str.split (Str.regexp " ") terms in
  StringMap.fold joined_lines StringMap.empty (fun map -> fun k -> fun (pre_vis,vis,post_vis,lines) ->
    let va,vb = match_vis term_list vis in
    let v = pre_vis, va, vb @ post_vis,lines in
    StringMap.add map k v)

let move_term_from_post_visx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    match post_vis with
      [] -> map
    | x :: l -> StringMap.add map key (pre_vis, vis @ [x], l, lines))

let move_term_from_post_vis_allx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    StringMap.add map key (pre_vis, vis @ post_vis, [], lines))

let move_term_to_post_visx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    match List.rev vis with
      [] -> map
    | x :: l -> StringMap.add map key (pre_vis, List.rev l, x :: post_vis, lines))

let move_term_to_post_vis_allx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    StringMap.add map key (pre_vis, [], vis @ post_vis, lines))

let move_term_from_pre_visx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    match List.rev pre_vis with
      [] -> map
    | x :: l -> StringMap.add map key (List.rev l, x :: vis, post_vis, lines))

let move_term_from_pre_vis_allx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    StringMap.add map key ([], pre_vis @ vis, post_vis, lines))

let move_term_to_pre_visx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    match vis with
      [] -> map
    | x :: l -> StringMap.add map key (pre_vis @ [x], l, post_vis, lines))

let move_term_to_pre_vis_allx list map =
  StringSet.fold list map (fun map -> fun key ->
    let pre_vis,vis,post_vis,lines = StringMap.find map key in
    StringMap.add map key (pre_vis @ vis, [], post_vis, lines))

let remove selection joined_lines =
  StringSet.fold selection joined_lines (fun map -> fun key ->
    StringMap.remove map key)

(*
let remove_empty_post joined_lines =
  StringMap.fold joined_lines StringMap.empty (fun map -> fun k -> function
      _,_,[],_ -> map
    | a,b,c,d -> StringMap.add map k (a,b,c,d))
*)
