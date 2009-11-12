(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Project
open Types

type 'a project_viewer = {
    project: project;
    main_vbox: GPack.box;
    name_entry: GEdit.entry;
    filename_label: GMisc.label;
    corpus_filename_label: GMisc.label;
    rules_filename_label: GMisc.label;
    mutable map: 'a StringMap.t;
    subcorpus_vbox: GPack.box;
    move_from_combo_box: GEdit.combo;
    move_to_combo_box: GEdit.combo;
    delete_subcorpus_combo_box: GEdit.combo;
    save_semantics_combo_box: GEdit.combo;
    save_subcorpus_combo_box: GEdit.combo}

let select_file title filename ok_fun =
  let filew = GWindow.file_selection ~modal:true ~title ~filename () in
  let _ = filew#ok_button#connect#clicked ~callback: (fun () -> 
    ok_fun filew#filename;
    filew#destroy ()) in 
  let _ = filew#cancel_button#connect#clicked ~callback:filew#destroy in
  filew#show ()

let overwrite_dialog label old_filename new_filename load_fun =
  if Sys.file_exists new_filename then (
    let dialog = GWindow.dialog ~title:"File exists!" ~modal:true ~position:`CENTER_ALWAYS () in
    let _ = GMisc.label ~text:"Do you wish to overwrite it, open it or cancel operation?" ~packing:dialog#vbox#add () in
    let overwrite_button = GButton.button ~label:"Overwrite" ~packing:dialog#action_area#add () in
    let open_button = GButton.button ~label:"Open" ~packing:dialog#action_area#add () in
    let cancel_button = GButton.button ~label:"Cancel" ~packing:dialog#action_area#add () in
    ignore(overwrite_button#connect#clicked ~callback:(fun () -> 
      label#set_text new_filename; 
      dialog#destroy ()));
    ignore(open_button#connect#clicked ~callback:(fun () -> 
      label#set_text new_filename; 
      load_fun new_filename;
      dialog#destroy ()));
    ignore(cancel_button#connect#clicked ~callback:dialog#destroy);
    dialog#show ())
  else label#set_text new_filename

let set_combo map combo =
  let list = StringMap.fold map [] (fun list name _ -> name :: list) in
  combo#set_popdown_strings list;
  if list = [] then combo#entry#set_text ""

let set_combo_zero map combo =
  let list = StringMap.fold map [] (fun list name subcorpus -> 
    if StringSet.size subcorpus.ids = 0 then name :: list else list) in
  combo#set_popdown_strings list;
  if list = [] then combo#entry#set_text ""

let change_subcorpus_status project name status =
  ignore(Thread.create change_subcorpus_status (project, name, status))

let update project_viewer () = 
  project_viewer.name_entry#set_text project_viewer.project.name;
  project_viewer.filename_label#set_text project_viewer.project.filename;
  project_viewer.corpus_filename_label#set_text project_viewer.project.corpus_filename;
  project_viewer.rules_filename_label#set_text project_viewer.project.rules_filename;
  let old_map = StringMap.fold project_viewer.map StringMap.empty (fun old_map name scv ->
    if StringMap.mem project_viewer.project.subcorpora name then StringMap.add old_map name scv else (
    Subcorpus_viewer.destroy scv;
    old_map)) in
  project_viewer.map <- StringMap.fold project_viewer.project.subcorpora StringMap.empty (fun map name subcorpus ->
    try 
      let scv = StringMap.find old_map name in
      Subcorpus_viewer.set_model scv subcorpus;
      StringMap.add map name scv
    with Not_found ->
      let scv = Subcorpus_viewer.create name subcorpus (change_subcorpus_status project_viewer.project name) in
      Subcorpus_viewer.set_model scv subcorpus;
      project_viewer.subcorpus_vbox#pack (Subcorpus_viewer.coerce scv);
      StringMap.add map name scv);
  set_combo project_viewer.map project_viewer.move_from_combo_box;
  set_combo project_viewer.map project_viewer.move_to_combo_box;
  set_combo project_viewer.map project_viewer.save_subcorpus_combo_box;
  set_combo project_viewer.map project_viewer.save_semantics_combo_box;
  set_combo_zero project_viewer.project.subcorpora project_viewer.delete_subcorpus_combo_box

let move (n, project_viewer) =
  let from_name = project_viewer.move_from_combo_box#entry#text in
  let to_name = project_viewer.move_to_combo_box#entry#text in
  let from_subcorpus = StringMap.find project_viewer.project.subcorpora from_name in
  let to_subcorpus = StringMap.find project_viewer.project.subcorpora to_name in
  let from_set,to_set,_ = StringSet.fold from_subcorpus.ids (StringSet.empty,to_subcorpus.ids,n) (fun (from_set,to_set,n) id ->
    if n > 0 then from_set,StringSet.add to_set id,n-1
    else StringSet.add from_set id, to_set, n-1) in
  project_viewer.project.subcorpora <-
    StringMap.add (StringMap.add project_viewer.project.subcorpora from_name {status=from_subcorpus.status; ids=from_set}) 
      to_name {status=to_subcorpus.status; ids=to_set};
  update_corpus project_viewer.project

(* dorzucic compaction i w timeoucie tez *)
let move_selected (symbol, project_viewer) =
  let from_name = project_viewer.move_from_combo_box#entry#text in
  let to_name = project_viewer.move_to_combo_box#entry#text in
  let from_subcorpus = StringMap.find project_viewer.project.subcorpora from_name in
  let to_subcorpus = StringMap.find project_viewer.project.subcorpora to_name in
  let ids = select project_viewer.project symbol from_subcorpus to_subcorpus.status in
  let from_set,to_set = StringSet.fold from_subcorpus.ids (StringSet.empty,to_subcorpus.ids) (fun (from_set,to_set) id ->
    if StringSet.mem ids id then from_set,StringSet.add to_set id
    else StringSet.add from_set id, to_set) in
  project_viewer.project.subcorpora <-
    StringMap.add (StringMap.add project_viewer.project.subcorpora from_name {status=from_subcorpus.status; ids=from_set}) 
      to_name {status=to_subcorpus.status; ids=to_set};
  update_corpus project_viewer.project

let create project =
  let main_vbox = GPack.vbox () in
  let name_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let _ = GMisc.label ~text:"Name" ~packing:name_hbox#pack () in
  let name_entry = GEdit.entry ~packing:name_hbox#pack ~text:project.name () in
  let filename_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let _ = GMisc.label ~text:"Filename" ~packing:filename_hbox#pack () in
  let filename_button = GButton.button ~label:"Select" ~packing:filename_hbox#pack () in 
  let filename_label = GMisc.label ~packing:filename_hbox#pack () in
  let corpus_filename_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let _ = GMisc.label ~text:"Select Corpus Filename" ~packing:corpus_filename_hbox#pack () in
  let corpus_filename_button = GButton.button ~label:"Select" ~packing:corpus_filename_hbox#pack () in 
  let corpus_filename_label = GMisc.label ~packing:corpus_filename_hbox#pack () in
  let rules_filename_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let _ = GMisc.label ~text:"Select Rules Filename" ~packing:rules_filename_hbox#pack () in
  let rules_filename_button = GButton.button ~label:"Select" ~packing:rules_filename_hbox#pack () in 
  let rules_filename_label = GMisc.label ~packing:rules_filename_hbox#pack () in
  let end_line_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let _ = GMisc.label ~text:"End Line" ~packing:end_line_hbox#pack () in
  let end_line_entry = GEdit.entry ~packing:end_line_hbox#pack ~text:project.end_line () in
  let _ = GMisc.label ~text:"White" ~packing:end_line_hbox#pack () in
  let white_entry = GEdit.entry ~packing:end_line_hbox#pack ~text:project.white () in
  let move_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let move_from_combo_box = GEdit.combo ~packing:move_hbox#pack () in
  let _ = GMisc.label ~text:"move to" ~packing:move_hbox#pack () in
  let move_to_combo_box = GEdit.combo ~packing:move_hbox#pack () in
  let _ = GMisc.label ~text:"quantity" ~packing:move_hbox#pack () in
  let move_1_button = GButton.button ~label:"1" ~packing:move_hbox#pack () in 
  let move_10_button = GButton.button ~label:"10" ~packing:move_hbox#pack () in 
  let move_100_button = GButton.button ~label:"100" ~packing:move_hbox#pack () in 
  let move_1000_button = GButton.button ~label:"1000" ~packing:move_hbox#pack () in 
  let move_10000_button = GButton.button ~label:"10000" ~packing:move_hbox#pack () in 
  let move_all_button = GButton.button ~label:"All" ~packing:move_hbox#pack () in 
  let move_selected_button = GButton.button ~label:"Selected" ~packing:move_hbox#pack () in 
  let move_selected_entry = GEdit.entry ~packing:move_hbox#pack ~text:"" () in
  let delete_subcorpus_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let delete_subcorpus_combo_box = GEdit.combo ~packing:delete_subcorpus_hbox#pack () in
  let delete_subcorpus_button = GButton.button ~label:"Delete" ~packing:delete_subcorpus_hbox#pack () in 
  let save_subcorpus_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let save_subcorpus_combo_box = GEdit.combo ~packing:save_subcorpus_hbox#pack () in
  let save_subcorpus_button = GButton.button ~label:"Save Subcorpus" ~packing:save_subcorpus_hbox#pack () in 
  let save_subcorpus_filename_button = GButton.button ~label:"Select Filename" ~packing:save_subcorpus_hbox#pack () in 
  let save_subcorpus_filename_label = GMisc.label ~packing:save_subcorpus_hbox#pack () in
  let save_semantics_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let save_semantics_combo_box = GEdit.combo ~packing:save_semantics_hbox#pack () in
  let save_semantics_entry = GEdit.entry ~packing:save_semantics_hbox#pack ~text:"" () in
  let save_semantics_button = GButton.button ~label:"Save Semantics" ~packing:save_semantics_hbox#pack () in 
  let save_semantics_filename_button = GButton.button ~label:"Select Filename" ~packing:save_semantics_hbox#pack () in 
  let save_semantics_filename_label = GMisc.label ~packing:save_semantics_hbox#pack () in
  let add_subcorpus_hbox = GPack.hbox ~packing:main_vbox#pack () in
  let add_subcorpus_entry = GEdit.entry ~packing:add_subcorpus_hbox#pack () in
  let add_subcorpus_button = GButton.button ~label:"Add" ~packing:add_subcorpus_hbox#pack () in 
  let subcorpus_scrolled_window = GBin.scrolled_window ~vpolicy:`AUTOMATIC ~hpolicy:`NEVER 
      ~packing:(main_vbox#pack ~expand:true) () in
  let subcorpus_vbox = GPack.vbox ~packing:subcorpus_scrolled_window#add_with_viewport () in
  let project_viewer = {main_vbox=main_vbox; name_entry=name_entry; filename_label=filename_label;
			corpus_filename_label=corpus_filename_label; rules_filename_label=rules_filename_label;
			map=StringMap.empty; subcorpus_vbox=subcorpus_vbox; move_from_combo_box=move_from_combo_box;
			move_to_combo_box=move_to_combo_box; delete_subcorpus_combo_box=delete_subcorpus_combo_box;
			save_semantics_combo_box=save_semantics_combo_box; 
			save_subcorpus_combo_box=save_subcorpus_combo_box; project=project} in
  ignore(name_entry#connect#changed ~callback:(fun () -> 
    project.name <- name_entry#text));
  ignore(filename_button#connect#clicked ~callback:(fun () ->
    select_file "Select Project" project.filename (fun filename ->
      project.filename <- filename;
      overwrite_dialog filename_label project.filename filename (fun filename ->
	ignore(Thread.create Project.open_project (project, filename)))))); 
  ignore(corpus_filename_button#connect#clicked ~callback:(fun () ->
    select_file "Select Corpus" project.corpus_filename (fun filename ->
      project.corpus_filename <- filename;
      overwrite_dialog corpus_filename_label project.corpus_filename filename (fun corpus_filename ->
	ignore(Thread.create Project.open_corpus (project, corpus_filename))))));
  ignore(rules_filename_button#connect#clicked ~callback:(fun () ->
    select_file "Select Rules" project.rules_filename (fun filename ->
      project.rules_filename <- filename;
      overwrite_dialog rules_filename_label project.rules_filename filename (fun rules_filename ->
	ignore(Thread.create Project.open_rules2 (project, rules_filename))))));
  ignore (end_line_entry#connect#changed ~callback:(fun () -> 
    project.end_line <- end_line_entry#text));
  ignore (white_entry#connect#changed ~callback:(fun () -> 
    project.white <- white_entry#text));
  ignore(move_1_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move (1, project_viewer))));
  ignore(move_10_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move (10, project_viewer))));
  ignore(move_100_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move (100, project_viewer))));
  ignore(move_1000_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move (1000, project_viewer))));
  ignore(move_10000_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move (10000, project_viewer))));
  ignore(move_all_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move (max_int, project_viewer))));
  ignore(move_selected_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create move_selected (move_selected_entry#text, project_viewer))));
  ignore(delete_subcorpus_button#connect#clicked ~callback:(fun () ->
    let name = delete_subcorpus_combo_box#entry#text in
    try 
      let subcorpus = StringMap.find project.subcorpora name in
      if StringSet.size subcorpus.ids = 0 then (
	project.subcorpora <- StringMap.remove project.subcorpora name;
	update project_viewer ())
    with Not_found -> ()));
  ignore(save_subcorpus_filename_button#connect#clicked ~callback:(fun () ->
    select_file "Select Corpus" save_subcorpus_filename_label#text (fun filename ->
      save_subcorpus_filename_label#set_text filename)));
  ignore(save_subcorpus_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create save_subcorpus (project_viewer.project, 
					 save_subcorpus_combo_box#entry#text, save_subcorpus_filename_label#text))));
  ignore(save_semantics_filename_button#connect#clicked ~callback:(fun () ->
    select_file "Select Corpus" save_semantics_filename_label#text (fun filename ->
      save_semantics_filename_label#set_text filename)));
  ignore(save_semantics_button#connect#clicked ~callback:(fun () ->
    ignore(Thread.create save_semantics (project_viewer.project, save_semantics_combo_box#entry#text, 
					 save_semantics_entry#text, save_semantics_filename_label#text))));
  ignore(add_subcorpus_button#connect#clicked ~callback:(fun () ->
    let name = add_subcorpus_entry#text in
    add_subcorpus_entry#set_text "";
    if name <> "" && not (StringMap.mem project.subcorpora name) then 
      let subcorpus = {status=Unloaded; ids=StringSet.empty} in
      project.subcorpora <- StringMap.add project.subcorpora name subcorpus;
      update project_viewer ()));
  project_viewer

let coerce project_viewer =
  project_viewer.main_vbox#coerce

let visible project_viewer =
  ()

let model_changed project_viewer () =
  update project_viewer ()
