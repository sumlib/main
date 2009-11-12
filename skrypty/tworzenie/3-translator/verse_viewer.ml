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

type verse_viewer = {
    line_interface: GPack.box;
    project: project;
    mutable verses: ((string * variable list) list * (string * variable list) list * 
		       (string * variable list) list * (string * graph_node * graph_node) list) Xstd.StringMap.t list;
    mutable column_state: int;
    line_clist: string GList.clist;
    adjustment: GData.adjustment;
    size_label: GMisc.label;
    exclude_combo_box: GEdit.combo}

let set_selected clist selection = 
  Int.iter 0 (clist#rows - 1) (fun i ->
    if StringSet.mem selection (clist#cell_text i 0) then 
      clist#select i i)

let get_selected clist =
  Int.fold 0 (clist#rows - 1) StringSet.empty (fun set -> fun i ->
    if clist#get_row_state i = `SELECTED then 
      StringSet.add set (clist#cell_text i 0) else set)

let reset_column_names (clist : string GList.clist) i =
  clist#set_column ~title:"No" 1;
  clist#set_column ~title:"Pre" 2;
  clist#set_column ~title:"Vis" 3;
  clist#set_column ~title:"Post" 4;
  match i with
    1 -> clist#set_column ~title:"No v" 1 
  | 2 -> clist#set_column ~title:"Pre v" 2 
  | 3 -> clist#set_column ~title:"Vis v" 3  
  | 4 -> clist#set_column ~title:"Post v" 4 
  | -1 -> clist#set_column ~title:"No ^" 1 
  | 5 -> clist#set_column ~title:"Pre ^" 2 
  | 6 -> clist#set_column ~title:"Vis ^" 3 
  | 7 -> clist#set_column ~title:"Post ^" 4 
  | _ -> failwith "reset_column_names"

let sort_clist verse_viewer col =
  if col = 1 then
    if verse_viewer.column_state = 1 then (
      verse_viewer.column_state <- -1;
      verse_viewer.line_clist#set_sort ~column:col ~dir:`DESCENDING ()) 
    else (
      verse_viewer.column_state <- 1;
      verse_viewer.line_clist#set_sort ~column:col ~dir:`ASCENDING ()) 
  else (
    if verse_viewer.column_state = col then verse_viewer.column_state <- col + 3
    else verse_viewer.column_state <- col;
    verse_viewer.line_clist#set_sort ~column:verse_viewer.column_state ~dir:`ASCENDING ());
  reset_column_names verse_viewer.line_clist verse_viewer.column_state;
  verse_viewer.line_clist#sort ()

let make_line_clist verse_viewer =
  let v = verse_viewer.adjustment#value in
  verse_viewer.line_clist#freeze ();
  verse_viewer.line_clist#clear ();
  StringMap.iter (List.hd verse_viewer.verses) (fun k -> fun (pre_vis,vis,post_vis,lines) ->
    let _ = verse_viewer.line_clist#append 
	[k;(Printf.sprintf "%5d" (Xlist.size lines));
	 (Verse.string_of_verse pre_vis);(Verse.string_of_verse vis);Verse.string_of_verse post_vis;
	 Verse.string_of_verse (List.rev pre_vis);Verse.string_of_verse (List.rev vis);
	 Verse.string_of_verse (List.rev post_vis)] in ());
  verse_viewer.size_label#set_text (string_of_int (StringMap.size (List.hd verse_viewer.verses)));
  let x = if verse_viewer.column_state = 0 then 3 else verse_viewer.column_state in
  verse_viewer.column_state <- 0;
  sort_clist verse_viewer x;
  verse_viewer.line_clist#columns_autosize ();
  verse_viewer.line_clist#thaw ();
  verse_viewer.adjustment#set_value v

let update verse_viewer () =
  verse_viewer.verses <- [Verse.join verse_viewer.project.showed_corpus];
  verse_viewer.column_state <- 0;
  make_line_clist verse_viewer;
  let list = StringMap.fold verse_viewer.project.subcorpora [] (fun list name subcorpus ->
    if subcorpus.status = Unloaded || subcorpus.status = Loaded then name :: list else list) in
  verse_viewer.exclude_combo_box#set_popdown_strings list;
  if list = [] then verse_viewer.exclude_combo_box#entry#set_text ""

let move_lines verse_viewer f =
  let selection = get_selected verse_viewer.line_clist in
  verse_viewer.verses <- (f (List.hd verse_viewer.verses)) :: verse_viewer.verses;
  make_line_clist verse_viewer;
  set_selected verse_viewer.line_clist selection

let move_lines_selection verse_viewer f =
  let selection = get_selected verse_viewer.line_clist in
  verse_viewer.verses <- (f selection (List.hd verse_viewer.verses)) :: verse_viewer.verses;
  make_line_clist verse_viewer;
  set_selected verse_viewer.line_clist selection

let create project graph_viewer = 
  let line_interface = GPack.vbox () in
  let hbox = GPack.hbox ~packing:(line_interface#pack ~expand:false) () in
  let hbox2 = GPack.hbox ~packing:(line_interface#pack ~expand:false) () in
  let undo_button = GButton.button ~label:"Undo" ~packing:(hbox#pack ~expand:false) () in
  let exclude_combo_box = GEdit.combo ~packing:hbox#pack () in
  let exclude_button = GButton.button ~label:"Exclude" ~packing:(hbox#pack ~expand:false) () in
  let move_left_button = GButton.button ~label:"Move left" ~packing:(hbox#pack ~expand:false) () in
  let entry = GEdit.entry ~text:"" ~packing:hbox#pack () in
  let move_right_button = GButton.button ~label:"Move right" ~packing:(hbox#pack ~expand:false) () in
  let move_to_pre_vis_all_button = GButton.button ~label:"Pre <<- Vis" ~packing:(hbox2#pack ~expand:false) () in
  let move_to_pre_vis_button = GButton.button ~label:"Pre <- Vis" ~packing:(hbox2#pack ~expand:false) () in
  let move_to_post_vis_button = GButton.button ~label:"Vis -> Post" ~packing:(hbox2#pack ~expand:false) () in
  let move_to_post_vis_all_button = GButton.button ~label:"Vis ->> Post" ~packing:(hbox2#pack ~expand:false) () in
  let move_from_pre_vis_all_button = GButton.button ~label:"Pre ->> Vis" ~packing:(hbox2#pack ~expand:false) () in
  let move_from_pre_vis_button = GButton.button ~label:"Pre -> Vis" ~packing:(hbox2#pack ~expand:false) () in
  let move_from_post_vis_button = GButton.button ~label:"Vis <- Post" ~packing:(hbox2#pack ~expand:false) () in
  let move_from_post_vis_all_button = GButton.button ~label:"Vis <<- Post" ~packing:(hbox2#pack ~expand:false) () in
  let delete_selected_button = GButton.button ~label:"Delete selected" ~packing:(hbox2#pack ~expand:false) () in
  let reparse_graphs_button = GButton.button ~label:"Reparse graphs" ~packing:(hbox#pack ~expand:false) () in
  let create_rules_button = GButton.button ~label:"Create rules" ~packing:(hbox#pack ~expand:false) () in
  let view_one_graph_button = GButton.button ~label:"View one graph" ~packing:(hbox#pack ~expand:false) () in
  let view_all_graphs_button = GButton.button ~label:"View all graphs" ~packing:(hbox#pack ~expand:false) () in
  let size_label = GMisc.label ~packing:(hbox2#pack ~from:`END) () in
  let vadjustment = GData.adjustment () in
  let hadjustment = GData.adjustment () in
  let clist_hbox = GPack.hbox ~packing:(line_interface#pack ~expand:true) () in
  let line_clist = GList.clist ~titles:["Key";"No";"Pre";"Vis";"Post";"Rev Pre";"Rev Vis";"Rev Post"] 
      ~height:500 ~width:1000 ~vadjustment ~hadjustment ~selection_mode:`MULTIPLE ~packing:(clist_hbox#pack ~expand:true) () in
  let _ = GRange.scrollbar `VERTICAL ~adjustment:vadjustment ~packing:clist_hbox#pack () in
  let _ = GRange.scrollbar `HORIZONTAL ~adjustment:hadjustment ~packing:line_interface#pack () in
  line_clist#set_column ~visibility:false 0; 
  line_clist#set_column ~justification:`RIGHT ~resizeable:true 1; 
  line_clist#set_column ~justification:`RIGHT ~resizeable:true 2; 
  line_clist#set_column ~resizeable:true 3; 
  line_clist#set_column ~resizeable:true 4; 
  line_clist#set_column ~visibility:false 5; 
  line_clist#set_column ~visibility:false 6; 
  line_clist#set_column ~visibility:false 7; 
  let verse_viewer = {
    line_interface=line_interface; project=project;
    verses=[StringMap.empty]; column_state=0;
    line_clist=line_clist; adjustment=vadjustment; size_label=size_label; exclude_combo_box=exclude_combo_box} in
  ignore (line_clist#connect#click_column ~callback: (sort_clist verse_viewer));
  ignore (undo_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected line_clist in
    verse_viewer.verses <- (match verse_viewer.verses with [] -> [] | [x] -> [x] | _ :: x :: l -> x :: l);
    make_line_clist verse_viewer;
    set_selected line_clist selection));
  ignore (exclude_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected line_clist in
    let id_map = Verse.get_verses (Verse.select selection (List.hd verse_viewer.verses)) in
    verse_viewer.verses <- (Verse.remove selection (List.hd verse_viewer.verses)) :: verse_viewer.verses;
    make_line_clist verse_viewer;
    Project.move project exclude_combo_box#entry#text (StringMap.fold id_map StringSet.empty (fun l id _ -> StringSet.add l id))));
  ignore (reparse_graphs_button#connect#clicked ~callback: (fun () ->
    ignore(Thread.create Project.reparse project)));
  ignore (move_left_button#connect#clicked ~callback: (fun () ->
    move_lines verse_viewer (Verse.move_term_to_pre_vis entry#text)));
  ignore (move_right_button#connect#clicked ~callback: (fun () -> 
    move_lines verse_viewer (Verse.move_term_to_post_vis entry#text)));
  ignore (delete_selected_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected line_clist in
    verse_viewer.verses <- (Verse.remove selection (List.hd verse_viewer.verses)) :: verse_viewer.verses;
    make_line_clist verse_viewer));
  ignore (move_to_pre_vis_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_to_pre_visx));
  ignore (move_to_pre_vis_all_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_to_pre_vis_allx));
  ignore (move_from_pre_vis_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_from_pre_visx));
  ignore (move_from_pre_vis_all_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_from_pre_vis_allx));
  ignore (move_to_post_vis_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_to_post_visx));
  ignore (move_to_post_vis_all_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_to_post_vis_allx));
  ignore (move_from_post_vis_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_from_post_visx));
  ignore (move_from_post_vis_all_button#connect#clicked ~callback: (fun () ->
    move_lines_selection verse_viewer Verse.move_term_from_post_vis_allx));
  ignore (create_rules_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected line_clist in
    let edges = Verse.get_symbols (Verse.select selection (List.hd verse_viewer.verses)) in
    let new_rules = Xlist.fold edges verse_viewer.project.rules (fun rules edges -> 
      let prod = Graph_viewer.configuration.Graph_viewer.prod_symbol in
      let sem = Graph_viewer.configuration.Graph_viewer.semantics in
      if prod = "" then invalid_arg "Empty production symbol";
      check_semantics sem;
      let rule = Normal(Active,prod,edges,Graph_viewer.configuration.Graph_viewer.white_symbol,sem) in
      print_endline (String.concat " " edges);
      RuleSet.add rules rule) in
    let _ = Parser.find_layers new_rules in
    set_rules verse_viewer.project new_rules));
  ignore (view_one_graph_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected line_clist in
    let v = Verse.select_one_graph (Verse.select selection (List.hd verse_viewer.verses)) in
    Graph_viewer.add_graphs graph_viewer v));
  ignore (view_all_graphs_button#connect#clicked ~callback: (fun () ->
    let selection = get_selected line_clist in
    let v = Verse.select selection (List.hd verse_viewer.verses) in
    Graph_viewer.add_graphs graph_viewer v));
  verse_viewer

let coerce verse_viewer =
  verse_viewer.line_interface#coerce

let visible verse_viewer =
  ()

let model_changed verse_viewer () =
  update verse_viewer ()
