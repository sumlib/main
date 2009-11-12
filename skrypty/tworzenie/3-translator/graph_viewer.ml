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

type tree = Tree of tree StringMap.t

type graph_viewer = {
    main_hpaned: GPack.paned;
    notebook: GPack.notebook;
    entries: tree Cascade_entry.cascade_entry;
    white_entry: GBin.frame * GEdit.entry * string GList.clist * string list ref;
    n_label: GMisc.label;
    project: project;
    mutable graphs: (string * (GPack.table * (bool ref * GMisc.label * GBin.frame * GDraw.color * Types.variable) list) * int * (int * int * grammar_symbol) list * GBin.scrolled_window) IntMap.t;
    mutable next_page: int}

type configuration = {mutable close_after: bool; mutable apply_after: bool; 
		      mutable prod_symbol: string; mutable semantics: string; mutable white_symbol: string}

let configuration = {close_after=false; apply_after=false; prod_symbol=""; semantics="";white_symbol=""}

let find_subtree (Tree map) k =
  StringMap.find map k

let get_keys (Tree map) =
  List.sort compare (StringMap.fold map [] (fun list k _ -> k :: list))

let add_tree tree_map prod sem =
  StringMap.add_inc tree_map prod (Tree (StringMap.add StringMap.empty sem (Tree StringMap.empty)))
    (fun (Tree map2) -> Tree (StringMap.add map2 sem (Tree StringMap.empty))) 

let create_tree rules =
  Tree (RuleSet.fold rules StringMap.empty (fun tree_map -> function
      Normal(_,prod,_,_,sem) -> add_tree tree_map prod sem
    | Specific(_,prod,_,_,sem) -> add_tree tree_map prod sem
    | _ -> tree_map))

let rec check_list = function
    [] -> false
  | [_] -> true
  | (symbol1,i1,j1) :: (symbol2,i2,j2) :: list ->
      if j1 > i2 then false else check_list ((symbol2,i2,j2) :: list)

let set_n_label n_label n =
  match n with
    1 -> n_label#set_text "1 verse selected"
  | n -> n_label#set_text ((string_of_int n) ^ " verses selected")

module type CO_SET =
  sig

    type t

    val full : t
    val remove_min : t -> t * int
    val remove : t -> int -> t

  end

module CoSet =
  struct

    type t = IntSet.t * int

    let full = IntSet.empty, 0

    let remove_min (s,t) =
      if IntSet.is_empty s then (s,t+1),t 
      else 
	let n = IntSet.min_elt s in
	(IntSet.remove s n,t), n

    let remove (s,t) n =
      if t > n then IntSet.remove s n, t 
      else
	Int.fold t (n-1) s IntSet.add, n+1

  end


let make n = Array.make n CoSet.full

let find p i = 
  let cs,n = CoSet.remove_min p.(i) in
  p.(i) <- cs;
  n

let add p i j =
  let n = find p i in
  Int.iter (i+1) (j-1) (fun k -> p.(k) <- CoSet.remove p.(k) n);
  n

let create_index_map g =
  fst (IntSet.fold (Syntax_graph.node_set g) (IntMap.empty,0) (fun (map,i) -> fun index ->
    IntMap.add map index i, i+1))

let copy_graph g = 
  let index_map = create_index_map g in
  let m = max 1 (IntMap.size index_map) in
  let p = make m in
  let list = List.sort compare (Syntax_graph.fold g [] (fun list (symbol,node1,node2,_,layer) -> 
    (IntMap.find index_map node1, IntMap.find index_map node2, layer, symbol,(symbol,node1,node2)) :: list)) in
  Xlist.map list (fun (i,j,r,str,v) -> add p i j, i, j, str,v), index_map

(*  let time1 = Unix.gettimeofday () in
  Printf.printf "MakeGrid1 at %f\n" time1;
  flush stdout;*)

let is_selected selected (_,i,j,str,_) = Xlist.mem selected (i,j,str)

let show_semantics graph variable = 
  let _,_,_,formula,_ = Syntax_graph.find graph variable in
  let buf = Buffer.create 1000 in
  Syntax_graph.xml_print_formula buf formula;
  let window = GWindow.window ~type_hint:`SPLASHSCREEN ~position:`MOUSE ~border_width:0 () in 
  let frame = GBin.frame ~packing:window#add () in
  let event_box = GBin.event_box ~packing:frame#add () in
  let _ = GMisc.label ~text:(Buffer.contents buf) ~packing:event_box#add () in
  ignore(event_box#event#connect#button_press ~callback:(fun _ -> window#destroy (); true));
  window#show ()


let make_grid graph selected2 =
  let p,index_map = copy_graph graph in
  let selected = Xlist.map selected2 (fun (i,j,str) -> 
    IntMap.find index_map i,
    IntMap.find index_map j, str) in
  let graph_view = Graph_view.create p (is_selected selected) (show_semantics graph) in
  graph_view

let get_white rules = 
  let set = RuleSet.fold rules StringSet.empty (fun set -> function
      Normal(_,_,_,white,_) -> StringSet.add set white
    | Specific(_,_,_,_,_) -> set
    | Delete (_,_) -> set
    | Accumulate(_,_,_,white,_) -> StringSet.add set white
    | AccumulateLeft(_,_,_,_,white,_) -> StringSet.add set white
    | AccumulateRight(_,_,_,_,white,_) -> StringSet.add set white) in
  StringSet.to_list set

let reparse_page graph_viewer = 
  let page = graph_viewer.notebook#current_page in
  if page >= 0 then 
    try
      let id,grid,n,edges,scrolled_window = IntMap.find graph_viewer.graphs page in
      let rules = Parser.prepare_for_parsing 
	  (Parser.divide_rules_into_layers graph_viewer.project.rules)
	  semantic_parser acc_semantic_parser in
      let graph = Parser.parse rules id (StringMap.find graph_viewer.project.loaded_corpus id) in
      (Graph_view.coerce grid)#destroy ();
      let grid = make_grid graph edges in
      scrolled_window#add_with_viewport (Graph_view.coerce grid);
      graph_viewer.graphs <- IntMap.add graph_viewer.graphs graph_viewer.notebook#current_page (id,grid,n,edges,scrolled_window)
    with Not_found -> failwith "reparse"

let close_page graph_viewer =
    graph_viewer.graphs <- IntMap.remove graph_viewer.graphs graph_viewer.notebook#current_page;
    graph_viewer.notebook#remove_page graph_viewer.notebook#current_page

let set_rulesg graph_viewer =
  Cascade_entry.set_semantics graph_viewer.entries 1 (create_tree graph_viewer.project.rules);
  Cascade_entry.set_text graph_viewer.entries [configuration.prod_symbol;configuration.semantics];
  Data_entry.set_list graph_viewer.white_entry (get_white graph_viewer.project.rules);
  Data_entry.set_text graph_viewer.white_entry configuration.white_symbol

let specific_rule prod id edges white sem =
  if prod = "" then invalid_arg "Empty production symbol";
  check_semantics sem;
  Specific(Active,prod,id,edges,sem)

let normal_rule prod id edges white sem =
  if prod = "" then invalid_arg "Empty production symbol";
  check_semantics sem;
  let edges = Xlist.map edges (fun (s,_,_) -> s) in
  Normal(Active,prod,edges,white,sem)

let delete_rule prod id edges white sem =
  match edges with
    [matched,_,_] -> Delete(Active,matched)
  | _ -> invalid_arg "Invalid selection"

let acc_rule prod id edges white sem =
  if prod = "" then invalid_arg "Empty production symbol";
  check_acc_semantics sem;
  match edges with
    [matched,_,_] -> Accumulate(Active,prod,matched,white,sem)
  | _ -> invalid_arg "Invalid selection"

let left_acc_rule prod id edges white sem =
  if prod = "" then invalid_arg "Empty production symbol";
  check_acc_semantics sem;
  match edges with
    [left_match,_,_; matched,_,_] -> AccumulateLeft(Active,prod,matched,left_match,white,sem)
  | _ -> invalid_arg "Invalid selection"

let right_acc_rule prod id edges white sem =
  if prod = "" then invalid_arg "Empty production symbol";
  check_acc_semantics sem;
  match edges with
    [matched,_,_; right_match,_,_] -> AccumulateRight(Active,prod,matched,right_match,white,sem)
  | _ -> invalid_arg "Invalid selection"

let create_rule graph_viewer rule_fun =
  print_endline "create_rule 1";
  try
    let id, grid, _,_,_ = IntMap.find graph_viewer.graphs graph_viewer.notebook#current_page in
    let edges = Graph_view.get_selected grid in
    let white = Data_entry.text graph_viewer.white_entry in
    let prod,sem = 
      match Cascade_entry.get_query graph_viewer.entries with 
	[prod;sem] -> prod,sem
      | _ -> failwith "create_rule" in
    let edges = List.sort (fun (symbol1,i1,j1) (symbol2,i2,j2) -> compare i1 i2) edges in
    if check_list edges then (
      print_endline "create_rule 2";
      let new_rules = RuleSet.add graph_viewer.project.rules (rule_fun prod id edges white sem) in
      let _ = Parser.find_layers new_rules in
      set_rules graph_viewer.project new_rules;
      print_endline "create_rule 3";
      Graph_view.clear_selected grid;
      if configuration.close_after then close_page graph_viewer;
      if configuration.apply_after then reparse_page graph_viewer)
    else Ok_dialog.create "Error" "Invalid selection"
  with 
    Not_found -> print_endline "create_rule Not_found";()
  | Invalid_argument s -> Ok_dialog.create "Error" s


let create project =
  let main_hpaned = GPack.paned `HORIZONTAL () in
  let notebook = GPack.notebook ~tab_pos:`LEFT ~packing:main_hpaned#add1 ~scrollable:true () in
  let main_vbox = GPack.vbox ~packing:main_hpaned#add2 () in
  let n_label = GMisc.label ~width:20 ~packing:main_vbox#pack () in
  let entries = Cascade_entry.create ["Symbol";"Semantics"] (Tree StringMap.empty) find_subtree get_keys in
  main_vbox#pack (Cascade_entry.coerce entries);
  let white_entry = Data_entry.create "White" in
  main_vbox#pack (Data_entry.coerce white_entry);
  let normal_rule_button = GButton.button ~label:"Create Normal Rule" ~packing:main_vbox#pack () in
  let specific_rule_button = GButton.button ~label:"Create Specific Rule" ~packing:main_vbox#pack () in
  let delete_rule_button = GButton.button ~label:"Create Delete Rule" ~packing:main_vbox#pack () in
  let acc_rule_button = GButton.button ~label:"Create Accumulation Rule" ~packing:main_vbox#pack () in
  let left_acc_rule_button = GButton.button ~label:"Create Left Accumulation Rule" ~packing:main_vbox#pack () in
  let right_acc_rule_button = GButton.button ~label:"Create Right Accumulation Rule" ~packing:main_vbox#pack () in
  let reparse_button = GButton.button ~label:"Reparse Graph" ~packing:main_vbox#pack () in
  let close_button = GButton.button ~label:"Close" ~packing:main_vbox#pack () in
  let graph_viewer = {main_hpaned=main_hpaned; notebook=notebook; entries=entries; white_entry=white_entry; n_label=n_label; 
		      project=project; graphs=IntMap.empty; next_page=0} in
  set_rulesg graph_viewer;
  ignore (reparse_button#connect#clicked ~callback:(fun () -> 
    set_rulesg graph_viewer;
    reparse_page graph_viewer));
  ignore (close_button#connect#clicked ~callback:(fun () -> close_page graph_viewer));
  ignore(notebook#connect#switch_page ~callback:(function page ->
    try
      let _,_,n,_,_ = IntMap.find graph_viewer.graphs page in set_n_label n_label n
    with Not_found -> ()));
  ignore (normal_rule_button#connect#clicked ~callback:(fun () -> create_rule graph_viewer normal_rule));
  ignore (specific_rule_button#connect#clicked ~callback:(fun () -> create_rule graph_viewer specific_rule));
  ignore (delete_rule_button#connect#clicked ~callback:(fun () -> create_rule graph_viewer delete_rule));
  ignore (acc_rule_button#connect#clicked ~callback:(fun () -> create_rule graph_viewer acc_rule));
  ignore (left_acc_rule_button#connect#clicked ~callback:(fun () -> create_rule graph_viewer left_acc_rule));
  ignore (right_acc_rule_button#connect#clicked ~callback:(fun () -> create_rule graph_viewer right_acc_rule));
  graph_viewer

let coerce graph_viewer =
  graph_viewer.main_hpaned#coerce

let add_graphs graph_viewer verses =
  let id_map = Verse.get_verses verses in
  let edge_map = Verse.get_edges verses in
  StringMap.iter id_map (fun id l ->
    let n = Xlist.size l in
    let graph = 
      try StringMap.find graph_viewer.project.parsed_corpus id
      with Not_found ->
	let rules = Parser.prepare_for_parsing 
	    (Parser.divide_rules_into_layers graph_viewer.project.rules)
	    semantic_parser acc_semantic_parser in
	Parser.parse rules id (StringMap.find graph_viewer.project.loaded_corpus id) in
    let edges = try StringMap.find edge_map id with Not_found -> [] in
    let grid = make_grid graph edges in
    let scrolled_window = GBin.scrolled_window ~hpolicy:`AUTOMATIC ~vpolicy:`AUTOMATIC () in
    scrolled_window#add_with_viewport (Graph_view.coerce grid);
    graph_viewer.notebook#insert_page ~pos:graph_viewer.next_page ~tab_label:(GMisc.label ~text:id ())#coerce scrolled_window#coerce;
    set_n_label graph_viewer.n_label n;
    graph_viewer.graphs <- IntMap.add graph_viewer.graphs graph_viewer.next_page (id,grid,n,edges,scrolled_window);
    graph_viewer.next_page <- graph_viewer.next_page + 1;
    Printf.printf "add_graphs id=%s page=%d\n" id graph_viewer.notebook#current_page;
    flush stdout)


let graph_interface_configuration graph_view () =
  let window = GWindow.dialog ~title:"Configuration: Tablet Viewer" ~border_width:0 () in
  let main_vbox = window#vbox in
  let close_after_button = GButton.check_button ~label:"Close window after rule created" 
      ~active:configuration.close_after ~packing:main_vbox#pack () in
  let apply_after_button = GButton.check_button ~label:"Apply rule after creation" 
      ~active:configuration.apply_after ~packing:main_vbox#pack () in
  let prod_symbol_frame = GBin.frame ~label:"Initial Production Symbol" ~packing:main_vbox#pack () in
  let prod_symbol_entry = GEdit.entry ~text:configuration.prod_symbol ~packing:prod_symbol_frame#add () in
  let semantics_frame = GBin.frame ~label:"Initial Semantics" ~packing:main_vbox#pack () in
  let semantics_entry = GEdit.entry ~text:configuration.semantics ~packing:semantics_frame#add () in
  let white_symbol_frame = GBin.frame ~label:"Initial White Symbol" ~packing:main_vbox#pack () in
  let white_symbol_entry = GEdit.entry ~text:configuration.white_symbol ~packing:white_symbol_frame#add () in
  let close_button = GButton.button ~label:"Close" ~packing:window#action_area#add () in
  ignore(close_button#connect#clicked ~callback:window#destroy);
  ignore(close_after_button#connect#clicked ~callback:(fun () ->
    configuration.close_after <- not configuration.close_after));
  ignore(apply_after_button#connect#clicked ~callback:(fun () ->
    configuration.apply_after <- not configuration.apply_after));
  ignore(white_symbol_entry#connect#changed ~callback:(fun () -> 
    configuration.white_symbol <- white_symbol_entry#text;
    set_rulesg graph_view));
  ignore(prod_symbol_entry#connect#changed ~callback:(fun () -> 
    configuration.prod_symbol <- prod_symbol_entry#text;
    set_rulesg graph_view));
  ignore(semantics_entry#connect#changed ~callback:(fun () -> 
    configuration.semantics <- semantics_entry#text;
    set_rulesg graph_view));
  window#show ()

let visible graph_view =
  ()

let model_changed graph_view () =
  set_rulesg graph_view
