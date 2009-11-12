(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd

type 'a cascade_entry = {box: GPack.box; mutable trees:(Data_entry.t * 'a) IntMap.t; entries: int; 
			 empty_tree:'a; find_subtree: 'a -> string -> 'a; get_labels: 'a -> string list}

let set_semantics cascade_entry i sem = 
  try
    let data_entry,_ = IntMap.find cascade_entry.trees i in
    let map = IntMap.add cascade_entry.trees i (data_entry,sem) in
    Data_entry.set_list data_entry (cascade_entry.get_labels sem);
    Data_entry.set_text data_entry "";
    cascade_entry.trees <- IntMap.mapi map (fun k (data_entry,s) ->
      if k > i then (
	Data_entry.set_list data_entry [];
	Data_entry.set_text data_entry "";
	data_entry,cascade_entry.empty_tree) 
      else data_entry,s)
  with Not_found -> ()

let text_changed cascade_entry text i =	
  let _,sem = IntMap.find cascade_entry.trees i in
  try
    set_semantics cascade_entry (i+1) (cascade_entry.find_subtree sem text)
  with Not_found -> set_semantics cascade_entry (i+1) cascade_entry.empty_tree

let create entry_labels empty_tree find_subtree get_labels =
  let entries = Xlist.size entry_labels in
  let cascade_entry = {box=GPack.vbox (); trees=IntMap.empty; entries=entries; 
		       empty_tree=empty_tree; find_subtree=find_subtree; get_labels=get_labels} in
  cascade_entry.trees <- Int.fold 1 entries IntMap.empty (fun map i ->
    let data_entry = Data_entry.create (List.nth entry_labels (i-1)) in
    cascade_entry.box#pack ~expand:true (Data_entry.coerce data_entry);
    Data_entry.connect_changed_callback data_entry (fun text -> text_changed cascade_entry text i);
    IntMap.add map i (data_entry,empty_tree));
  cascade_entry

let coerce cascade_entry =
  cascade_entry.box#coerce

let clear_text cascade_entry =
  Data_entry.set_text (fst (IntMap.find cascade_entry.trees 1)) ""

let get_query cascade_entry = 
  List.rev (Int.fold 1 cascade_entry.entries [] (fun list i ->
    (Data_entry.text (fst (IntMap.find cascade_entry.trees i))) :: list))

let set_text cascade_entry list =
  let _ = Xlist.fold list 1 (fun i text -> 
    Data_entry.set_text (fst (IntMap.find cascade_entry.trees i)) text; i+1) in ()
