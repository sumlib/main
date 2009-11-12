(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Project
open Xstd
open Types

type rules_viewer = {
    main_vbox: GPack.box;
    project: project;
    rules_clist: string GList.clist;
    mutable rules_map: (int * rule) StringMap.t;
    clicked_columns: int Queue.t}

let update rules_viewer =
  let layers = Parser.divide_rules_into_layers rules_viewer.project.rules in
  rules_viewer.rules_map <- fst (IntMap.fold layers (StringMap.empty,0) (fun (map,n) layer rules ->
    Xlist.fold rules (map,n) (fun (map,n) rule ->
      StringMap.add map (string_of_int n) (layer,rule),n+1)));
  rules_viewer.rules_clist#freeze ();
  rules_viewer.rules_clist#clear ();
  StringMap.iter rules_viewer.rules_map (fun n (layer,rule) ->
    let layer = Printf.sprintf "%4d" layer in
    match rule with
      Normal(status,prod,match_list,white,sem) -> 
	ignore(rules_viewer.rules_clist#append [n; string_of_status status; layer; "Normal"; 
						prod; String.concat " " match_list; white; sem])
    | Specific(status,prod,id,match_list,sem) -> 
	ignore(rules_viewer.rules_clist#append [n; string_of_status status; layer; "Specific"; 
						prod; id ^ " " ^ (String.concat " " (Xlist.map match_list (fun (s,i,j) -> 
						  s ^ "_{" ^ (string_of_int i) ^ "," ^ (string_of_int j) ^ "}"))); ""; sem])
    | Delete (status,matched) -> 
	ignore(rules_viewer.rules_clist#append [n; string_of_status status; layer; "Delete"; 
						""; matched; ""; ""])
    | Accumulate(status,prod,matched,white,sem) -> 
	ignore(rules_viewer.rules_clist#append [n; string_of_status status; layer; "Accumulate"; 
						prod; matched ^ "+"; white; sem])
    | AccumulateLeft(status,prod,matched,left_match,white,sem) -> 
	ignore(rules_viewer.rules_clist#append [n; string_of_status status; layer; "AccumulateLeft"; 
						prod; left_match ^ " " ^ matched ^ "+"; white; sem])
    | AccumulateRight(status,prod,matched,right_match,white,sem) -> 
	ignore(rules_viewer.rules_clist#append [n; string_of_status status; layer; "AccumulateRight"; 
						prod; matched ^ "+ " ^ right_match ; white; sem]));
  rules_viewer.rules_clist#columns_autosize ();
  Queue.iter (fun col ->
    rules_viewer.rules_clist#set_sort ~column:col ~dir:`ASCENDING ();
    rules_viewer.rules_clist#sort ()) rules_viewer.clicked_columns;
  rules_viewer.rules_clist#thaw ()

let set_active = function
    Normal(_,prod,match_list,white,sem) -> Normal(Active,prod,match_list,white,sem)
  | Specific(_,prod,id,match_list,sem) -> Specific(Active,prod,id,match_list,sem)
  | Delete (_,matched) -> Delete (Active,matched)
  | Accumulate(_,prod,matched,white,sem) -> Accumulate(Active,prod,matched,white,sem)
  | AccumulateLeft(_,prod,matched,left_match,white,sem) -> AccumulateLeft(Active,prod,matched,left_match,white,sem)
  | AccumulateRight(_,prod,matched,right_match,white,sem) -> AccumulateRight(Active,prod,matched,right_match,white,sem)

let set_disabled = function
    Normal(_,prod,match_list,white,sem) -> Normal(Disabled,prod,match_list,white,sem)
  | Specific(_,prod,id,match_list,sem) -> Specific(Disabled,prod,id,match_list,sem)
  | Delete (_,matched) -> Delete (Disabled,matched)
  | Accumulate(_,prod,matched,white,sem) -> Accumulate(Disabled,prod,matched,white,sem)
  | AccumulateLeft(_,prod,matched,left_match,white,sem) -> AccumulateLeft(Disabled,prod,matched,left_match,white,sem)
  | AccumulateRight(_,prod,matched,right_match,white,sem) -> AccumulateRight(Disabled,prod,matched,right_match,white,sem)

let get_selected clist =
  Int.fold 0 (clist#rows - 1) StringSet.empty (fun set -> fun i ->
    if clist#get_row_state i = `SELECTED then 
      StringSet.add set (clist#cell_text i 0) else set)

let parse_normal_matched s =
  Str.split (Str.regexp " ") s

let parse_specific_matched s = 
  failwith "ni"

let parse_plus s =
  let n = String.length s in
  if String.get s (n-1) = '+' then 
    String.sub s 0 (n-1)
  else failwith "parse_plus"

let parse_acc_matched s =
  parse_plus s

let parse_left_acc_matched s =
  match Str.split (Str.regexp " ") s with
    [left_match;matched] -> parse_plus matched, left_match
  | _ -> failwith "parse_left_acc_matched"

let parse_right_acc_matched s =
  match Str.split (Str.regexp " ") s with
    [matched;right_match] -> parse_plus matched, right_match
  | _ -> failwith "parse_right_acc_matched"

let rule_editor rules_viewer rule  =
  let dialog = GWindow.dialog ~title:"Rule Editor" ~modal:true ~position:`CENTER_ALWAYS () in
  let hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let status_frame = GBin.frame ~label:"Status" ~packing:hbox#pack () in
  let status_vbox = GPack.vbox ~packing:status_frame#add () in
  let active_button = GButton.radio_button ~label:"Active" ~packing:status_vbox#pack () in
  let disabled_button = GButton.radio_button ~label:"Disabled" ~packing:status_vbox#pack ~group:active_button#group () in
  let type_frame = GBin.frame ~label:"Status" ~packing:hbox#pack () in
  let type_vbox = GPack.vbox ~packing:type_frame#add () in
  let normal_button = GButton.radio_button ~label:"Normal" ~packing:type_vbox#pack () in
  let specific_button = GButton.radio_button ~label:"Specific" ~packing:type_vbox#pack ~group:normal_button#group () in
  let delete_button = GButton.radio_button ~label:"Delete" ~packing:type_vbox#pack ~group:normal_button#group () in
  let accumulate_button = GButton.radio_button ~label:"Accumulate" ~packing:type_vbox#pack ~group:normal_button#group () in
  let accumulate_left_button = GButton.radio_button ~label:"Left Accumulate" ~packing:type_vbox#pack ~group:normal_button#group () in
  let accumulate_right_button = GButton.radio_button ~label:"Right Accumulate" ~packing:type_vbox#pack ~group:normal_button#group () in
  let vbox = GPack.vbox ~packing:(hbox#pack ~expand:true) () in
  let prod_frame = GBin.frame ~label:"Production" ~packing:vbox#pack () in
  let prod_entry = GEdit.entry ~packing:prod_frame#add () in
  let matched_frame = GBin.frame ~label:"Matched Symbols" ~packing:vbox#pack () in
  let matched_entry = GEdit.entry ~packing:matched_frame#add () in
  let white_frame = GBin.frame ~label:"White Symbol" ~packing:vbox#pack () in
  let white_entry = GEdit.entry ~packing:white_frame#add () in
  let sem_frame = GBin.frame ~label:"Semantics" ~packing:vbox#pack () in
  let sem_entry = GEdit.entry ~packing:sem_frame#add () in
  let ok_button = GButton.button ~label:"Ok" ~packing:dialog#action_area#add () in
  let cancel_button = GButton.button ~label:"Cancel" ~packing:dialog#action_area#add () in
  let set_status = function
      Active -> active_button#set_active true
    |	Disabled -> disabled_button#set_active true in
  let get_status () =
    if active_button#active then Active else Disabled in
  (match rule with
    Normal(status,prod,match_list,white,sem) -> 
      set_status status;
      normal_button#set_active true;
      prod_entry#set_text prod;
      matched_entry#set_text (String.concat " " match_list);
      white_entry#set_text white;
      sem_entry#set_text sem
  | Specific(status,prod,id,match_list,sem) -> 
      set_status status;
      specific_button#set_active true;
      prod_entry#set_text prod;
      matched_entry#set_text (id ^ " " ^ (String.concat " " (Xlist.map match_list (fun (s,i,j) -> 
	s ^ "_{" ^ (string_of_int i) ^ "," ^ (string_of_int j) ^ "}"))));
      white_entry#set_text "";
      sem_entry#set_text sem
  | Delete (status,matched) -> 
      set_status status;
      delete_button#set_active true;
      prod_entry#set_text "";
      matched_entry#set_text matched;
      white_entry#set_text "";
      sem_entry#set_text ""
  | Accumulate(status,prod,matched,white,sem) -> 
      set_status status;
      accumulate_button#set_active true;
      prod_entry#set_text prod;
      matched_entry#set_text (matched ^ "+");
      white_entry#set_text white;
      sem_entry#set_text sem
  | AccumulateLeft(status,prod,matched,left_match,white,sem) -> 
      set_status status;
      accumulate_left_button#set_active true;
      prod_entry#set_text prod;
      matched_entry#set_text (left_match ^ " " ^ matched ^ "+");
      white_entry#set_text white;
      sem_entry#set_text sem
  | AccumulateRight(status,prod,matched,right_match,white,sem) -> 
      set_status status;
      accumulate_right_button#set_active true;
      prod_entry#set_text prod;
      matched_entry#set_text (matched ^ "+ " ^ right_match);
      white_entry#set_text white;
      sem_entry#set_text sem);
  ignore(ok_button#connect#clicked ~callback:(fun () -> 
    try
      let new_rule =
	match normal_button#active, specific_button#active, delete_button#active, 
	  accumulate_button#active, accumulate_left_button#active, accumulate_right_button#active with
	  true,false,false,false,false,false ->
	    check_semantics sem_entry#text;
	    Normal(get_status (),prod_entry#text,parse_normal_matched matched_entry#text,white_entry#text,sem_entry#text)
	| false,true,false,false,false,false ->
	    check_semantics sem_entry#text;
	    let id,match_list = parse_specific_matched matched_entry#text in
	    Specific(get_status (),prod_entry#text,id,match_list,sem_entry#text)
	| false,false,true,false,false,false ->
	    Delete (get_status (),matched_entry#text)
	| false,false,false,true,false,false ->
	    check_acc_semantics sem_entry#text;
	    Accumulate(get_status (),prod_entry#text,parse_acc_matched matched_entry#text,white_entry#text,sem_entry#text)
	| false,false,false,false,true,false ->
	    check_acc_semantics sem_entry#text;
	    let matched,left_match = parse_left_acc_matched matched_entry#text in
	    AccumulateLeft(get_status (),prod_entry#text,matched,left_match,white_entry#text,sem_entry#text)
	| false,false,false,false,false,true ->
	    check_acc_semantics sem_entry#text;
	    let matched,right_match = parse_right_acc_matched matched_entry#text in
	    AccumulateRight(get_status (),prod_entry#text,matched,right_match,white_entry#text,sem_entry#text)
	| _ -> failwith "rule_editor" in
      let new_rules = RuleSet.add (RuleSet.remove rules_viewer.project.rules rule) new_rule in
      let _ = Parser.find_layers new_rules in
      set_rules rules_viewer.project new_rules;
      dialog#destroy ()
    with Invalid_argument s -> Ok_dialog.create "Error" s));
  ignore(cancel_button#connect#clicked ~callback:dialog#destroy);
  dialog#show ()


let edit_rules rules_viewer () =
  let selected = get_selected rules_viewer.rules_clist in
  StringSet.iter selected (fun i ->
    let _,rule = StringMap.find rules_viewer.rules_map i in
    rule_editor rules_viewer rule)

let add_rules rules_viewer () =
  rule_editor rules_viewer (Normal(Active,"",[],"",""))

let sort_clist rules_viewer col =
  rules_viewer.rules_clist#set_sort ~column:col ~dir:`ASCENDING ();
  rules_viewer.rules_clist#sort ();
  Queue.add col rules_viewer.clicked_columns;
  if Queue.length rules_viewer.clicked_columns > 5 then ignore(Queue.take rules_viewer.clicked_columns)

let create project = 
  let main_vbox = GPack.vbox () in
  let vadjustment = GData.adjustment () in
  let hadjustment = GData.adjustment () in
  let clist_hbox = GPack.hbox ~packing:(main_vbox#pack ~expand:true) () in
  let rules_clist = GList.clist ~titles:["Key";"Status";"Layer";"Type";"Prod";"Matched";"White";"Semantics"] 
      ~height:500 ~width:1000 ~vadjustment ~hadjustment ~selection_mode:`MULTIPLE ~packing:(clist_hbox#pack ~expand:true) () in
  let _ = GRange.scrollbar `VERTICAL ~adjustment:vadjustment ~packing:clist_hbox#pack () in
  let _ = GRange.scrollbar `HORIZONTAL ~adjustment:hadjustment ~packing:main_vbox#pack () in
  rules_clist#set_column ~justification:`RIGHT ~resizeable:true 2; 
  let hbox = GPack.hbox ~packing:(main_vbox#pack ~expand:false) () in
  let disable_button = GButton.button ~label:"Disable" ~packing:hbox#pack () in
  let enable_button = GButton.button ~label:"Enable" ~packing:hbox#pack () in
  let edit_button = GButton.button ~label:"Edit" ~packing:hbox#pack () in
  let delete_button = GButton.button ~label:"Delete" ~packing:hbox#pack () in
  let add_button = GButton.button ~label:"Add" ~packing:hbox#pack () in
  let update_button = GButton.button ~label:"Update" ~packing:hbox#pack () in
  let rules_viewer = {main_vbox=main_vbox;project=project;rules_clist=rules_clist;
		      rules_map=StringMap.empty;clicked_columns=Queue.create ()} in
  rules_clist#set_column ~visibility:false 0; 
  ignore (rules_clist#connect#click_column ~callback: (sort_clist rules_viewer));
  ignore (edit_button#connect#clicked ~callback:(edit_rules rules_viewer));
  ignore (add_button#connect#clicked ~callback:(add_rules rules_viewer));
  ignore (disable_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected rules_clist in
    let new_rules = StringSet.fold selection project.rules (fun rules n ->
      let _,rule = StringMap.find rules_viewer.rules_map n in
      RuleSet.add (RuleSet.remove rules rule) (set_disabled rule)) in
    set_rules project new_rules));
  ignore (enable_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected rules_clist in
    let new_rules = StringSet.fold selection project.rules (fun rules n ->
      let _,rule = StringMap.find rules_viewer.rules_map n in
      RuleSet.add (RuleSet.remove rules rule) (set_active rule)) in
    set_rules project new_rules));
  ignore (delete_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected rules_clist in
    let new_rules = StringSet.fold selection project.rules (fun rules n ->
      let _,rule = StringMap.find rules_viewer.rules_map n in
      RuleSet.remove rules rule) in
    set_rules project new_rules));
  ignore (update_button#connect#clicked ~callback: (fun () ->
    update rules_viewer));
  rules_viewer

let coerce rules_viewer =
  rules_viewer.main_vbox#coerce

let visible rules_viewer =
  ()

let model_changed rules_viewer () =
  (*update rules_viewer*) ()
