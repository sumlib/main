(********************************************************)
(*                                                      *)
(*  Copyright 2007, 2008 Wojciech Jaworski.             *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Xstd
open Project

let translator_name = "Translator v0.3a"

let about_command () =
  let window = GWindow.dialog ~title:"About Translator" () in 
  ignore(GMisc.label ~text:translator_name ~packing:window#vbox#pack ());
  ignore(GMisc.label ~text:"Copyright (c) 2007, 2008 by Wojciech Jaworski" ~packing:window#vbox#pack ());
  let ok_button = GButton.button ~label:"Close" ~packing:window#action_area#add () in 
  ignore(ok_button#connect#clicked ~callback:window#destroy);
  window#show ()

let quit_command () =
  GMain.Main.quit () (* ??? dodac zapisywanie regul i projektu *)

let import_file () = 
  let dialog = GWindow.dialog ~title:"Import File" ~modal:true ~position:`CENTER_ALWAYS () in
  let source_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Source Filename" ~packing:source_filename_hbox#pack () in
  let source_filename_button = GButton.button ~label:"Select" ~packing:source_filename_hbox#pack () in 
  let source_filename_label = GMisc.label ~packing:source_filename_hbox#pack () in
  let corpus_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Corpus Filename" ~packing:corpus_filename_hbox#pack () in
  let corpus_filename_button = GButton.button ~label:"Select" ~packing:corpus_filename_hbox#pack () in 
  let corpus_filename_label = GMisc.label ~packing:corpus_filename_hbox#pack () in
  let format_frame = GBin.frame ~label:"File Format" ~packing:dialog#vbox#pack () in
  let format_hbox = GPack.hbox ~packing:format_frame#add () in
  let atf_button = GButton.radio_button ~label:"ATF" ~packing:format_hbox#pack () in
  let lines_button = GButton.radio_button ~label:"Lines" ~packing:format_hbox#pack ~group:atf_button#group () in
  let folder_button = GButton.radio_button ~label:"Folder" ~packing:format_hbox#pack ~group:atf_button#group () in
  let lexer_frame = GBin.frame ~label:"Lexer" ~packing:dialog#vbox#pack () in
  let lexer_hbox = GPack.hbox ~packing:lexer_frame#add () in
  let char_button = GButton.radio_button ~label:"Char" ~packing:lexer_hbox#pack () in
  let word_button = GButton.radio_button ~label:"Word" ~packing:lexer_hbox#pack ~group:char_button#group () in
  let ok_button = GButton.button ~label:"Ok" ~packing:dialog#action_area#add () in
  let cancel_button = GButton.button ~label:"Cancel" ~packing:dialog#action_area#add () in
  let step_frame = GBin.frame ~label:"Step" ~packing:dialog#vbox#pack () in
  let step_entry = GEdit.entry ~text:"1" ~packing:step_frame#add () in
  ignore(source_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "" (fun filename ->
      source_filename_label#set_text filename)));
  ignore(corpus_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Corpus File" "" (fun filename ->
      corpus_filename_label#set_text filename)));
  ignore(ok_button#connect#clicked ~callback:(fun () -> 
    let step = int_of_string step_entry#text in
    let split_fun = 
      match char_button#active, word_button#active with
	true,false -> Import.split_into_chars
      | false,true -> Import.split_into_words
      | _ -> failwith "import_file" in
    let import_fun =
      match atf_button#active, lines_button#active, folder_button#active with
	true,false,false -> Import.atf_import 
      | false,true,false -> Import.lines_import 
      | false,false,true ->Import.folder_import 
      | _ -> failwith "import_file" in
    ignore(Thread.create import_fun (source_filename_label#text, corpus_filename_label#text, step, split_fun));
    dialog#destroy ()));
  ignore(cancel_button#connect#clicked ~callback:dialog#destroy);
  dialog#show ()

let atf_lexer () = 
  let dialog = GWindow.dialog ~title:"ATF Lexer" ~modal:true ~position:`CENTER_ALWAYS () in
  let atf_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"ATF Filename" ~packing:atf_filename_hbox#pack () in
  let atf_filename_button = GButton.button ~label:"Select" ~packing:atf_filename_hbox#pack () in 
  let atf_filename_label = GMisc.label ~packing:atf_filename_hbox#pack () in
  let show_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Show Corpus Filename" ~packing:show_filename_hbox#pack () in
  let show_filename_button = GButton.button ~label:"Select" ~packing:show_filename_hbox#pack () in 
  let show_filename_label = GMisc.label ~packing:show_filename_hbox#pack () in
  let lem_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Lem Corpus Filename" ~packing:lem_filename_hbox#pack () in
  let lem_filename_button = GButton.button ~label:"Select" ~packing:lem_filename_hbox#pack () in 
  let lem_filename_label = GMisc.label ~packing:lem_filename_hbox#pack () in
  let sign_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Sign Corpus Filename" ~packing:sign_filename_hbox#pack () in
  let sign_filename_button = GButton.button ~label:"Select" ~packing:sign_filename_hbox#pack () in 
  let sign_filename_label = GMisc.label ~packing:sign_filename_hbox#pack () in
  let sign_name_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Sign Name Corpus Filename" ~packing:sign_name_filename_hbox#pack () in
  let sign_name_filename_button = GButton.button ~label:"Select" ~packing:sign_name_filename_hbox#pack () in 
  let sign_name_filename_label = GMisc.label ~packing:sign_name_filename_hbox#pack () in
  let attribute_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Attribute Corpus Filename" ~packing:attribute_filename_hbox#pack () in
  let attribute_filename_button = GButton.button ~label:"Select" ~packing:attribute_filename_hbox#pack () in 
  let attribute_filename_label = GMisc.label ~packing:attribute_filename_hbox#pack () in
  let format_rules_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Format Rules Filename" ~packing:format_rules_filename_hbox#pack () in
  let format_rules_filename_button = GButton.button ~label:"Select" ~packing:format_rules_filename_hbox#pack () in 
  let format_rules_filename_label = GMisc.label ~packing:format_rules_filename_hbox#pack () in
  let sign_rules_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Sign Rules Filename" ~packing:sign_rules_filename_hbox#pack () in
  let sign_rules_filename_button = GButton.button ~label:"Select" ~packing:sign_rules_filename_hbox#pack () in 
  let sign_rules_filename_label = GMisc.label ~packing:sign_rules_filename_hbox#pack () in
  let sign_name_rules_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Sign Name Rules Filename" ~packing:sign_name_rules_filename_hbox#pack () in
  let sign_name_rules_filename_button = GButton.button ~label:"Select" ~packing:sign_name_rules_filename_hbox#pack () in 
  let sign_name_rules_filename_label = GMisc.label ~packing:sign_name_rules_filename_hbox#pack () in
  let unknown_line_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Unknown Line Filename" ~packing:unknown_line_filename_hbox#pack () in
  let unknown_line_filename_button = GButton.button ~label:"Select" ~packing:unknown_line_filename_hbox#pack () in 
  let unknown_line_filename_label = GMisc.label ~packing:unknown_line_filename_hbox#pack () in
  let unknown_word_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Unknown Word Filename" ~packing:unknown_word_filename_hbox#pack () in
  let unknown_word_filename_button = GButton.button ~label:"Select" ~packing:unknown_word_filename_hbox#pack () in 
  let unknown_word_filename_label = GMisc.label ~packing:unknown_word_filename_hbox#pack () in
  let unknown_sign_filename_hbox = GPack.hbox ~packing:dialog#vbox#pack () in
  let _ = GMisc.label ~text:"Unknown Sign Filename" ~packing:unknown_sign_filename_hbox#pack () in
  let unknown_sign_filename_button = GButton.button ~label:"Select" ~packing:unknown_sign_filename_hbox#pack () in 
  let unknown_sign_filename_label = GMisc.label ~packing:unknown_sign_filename_hbox#pack () in
  let ok_button = GButton.button ~label:"Ok" ~packing:dialog#action_area#add () in
  let cancel_button = GButton.button ~label:"Cancel" ~packing:dialog#action_area#add () in
  let step_frame = GBin.frame ~label:"Step" ~packing:dialog#vbox#pack () in
  let step_entry = GEdit.entry ~text:"1" ~packing:step_frame#add () in
  ignore(atf_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/sumlib.atf" (fun filename ->
      atf_filename_label#set_text filename)));
  ignore(show_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Corpus File" "sumlib/show.xml.gz" (fun filename ->
      show_filename_label#set_text filename)));
  ignore(lem_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Corpus File" "sumlib/lem.xml.gz" (fun filename ->
      lem_filename_label#set_text filename)));
  ignore(sign_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Corpus File" "sumlib/sign.xml.gz" (fun filename ->
      sign_filename_label#set_text filename)));
  ignore(sign_name_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Corpus File" "sumlib/sign_name.xml.gz" (fun filename ->
      sign_name_filename_label#set_text filename)));
  ignore(attribute_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Corpus File" "sumlib/attribute.xml.gz" (fun filename ->
      attribute_filename_label#set_text filename)));
  ignore(format_rules_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/format_rules.xml.gz" (fun filename ->
      format_rules_filename_label#set_text filename)));
  ignore(sign_rules_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/sign_rules.xml.gz" (fun filename ->
      sign_rules_filename_label#set_text filename)));
  ignore(sign_name_rules_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/sign_rules.txt" (fun filename ->
      sign_name_rules_filename_label#set_text filename)));
  ignore(unknown_line_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/unknown_line.txt" (fun filename ->
      unknown_line_filename_label#set_text filename)));
  ignore(unknown_word_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/unknown_word.txt" (fun filename ->
      unknown_word_filename_label#set_text filename)));
  ignore(unknown_sign_filename_button#connect#clicked ~callback:(fun () ->
    Project_viewer.select_file "Select Source File" "sumlib/unknown_sign.txt" (fun filename ->
      unknown_sign_filename_label#set_text filename)));
  ignore(ok_button#connect#clicked ~callback:(fun () -> 
    let step = int_of_string step_entry#text in
    ignore(Thread.create Atf_lexer.atf_lexer 
	     (atf_filename_label#text, 
	      show_filename_label#text, lem_filename_label#text, sign_filename_label#text, sign_name_filename_label#text, attribute_filename_label#text,  
	      format_rules_filename_label#text, sign_rules_filename_label#text, sign_name_rules_filename_label#text,  
	      unknown_line_filename_label#text, unknown_word_filename_label#text, unknown_sign_filename_label#text, step));
    dialog#destroy ()));
  ignore(cancel_button#connect#clicked ~callback:dialog#destroy);
  dialog#show ()

let open_project project () =
  Project_viewer.select_file "Open project" "" (fun filename -> 
    ignore(Thread.create Project.open_project (project, filename)))

let help_entries = [
  `I ("About", about_command); 
]


let tools_entries = [
  `I("Import", import_file);
  `I("ATF Lexer", atf_lexer);
]

let delete_event ev =
  quit_command (); 
  false

let create_menu label menubar entries = 
  let item = GMenu.menu_item ~label ~packing:menubar#append () in
  let menu = GMenu.menu ~packing:item#set_submenu () in
  GToolbox.build_menu menu ~entries:entries

let main () =
  Sys.chdir ((try String.sub Sys.argv.(0) 0 (String.rindex Sys.argv.(0) '/' + 1) with Not_found -> "") ^ "data/");
  let window = GWindow.window ~title:translator_name ~border_width:0 () in (* ??? wielkosc i powiekszalnosc poprawic *)
  let _ = window#event#connect#delete ~callback:delete_event in 
  let main_vbox = GPack.vbox ~packing:window#add () in
  let menubar = GMenu.menu_bar ~packing:(main_vbox#pack ~expand:false) () in
  let project = Project.empty () in
  let graph_view = Graph_viewer.create project in
  let verse_view = Verse_viewer.create project graph_view in
  let project_view = Project_viewer.create project in
  let rules_view = Rules_viewer.create project in
  let notebook = GPack.notebook ~tab_pos:`TOP ~packing:(main_vbox#pack ~expand:true) () in
  notebook#insert_page ~pos:0 ~tab_label:(GMisc.label ~text:"Project" ())#coerce (Project_viewer.coerce project_view);
  notebook#insert_page ~pos:1 ~tab_label:(GMisc.label ~text:"Verse" ())#coerce (Verse_viewer.coerce verse_view);
  notebook#insert_page ~pos:2 ~tab_label:(GMisc.label ~text:"Graph" ())#coerce (Graph_viewer.coerce graph_view);
  notebook#insert_page ~pos:3 ~tab_label:(GMisc.label ~text:"Rules" ())#coerce (Rules_viewer.coerce rules_view);
  ignore(notebook#connect#switch_page ~callback:(function 
      0 -> Project_viewer.visible project_view
    | 1 -> Verse_viewer.visible verse_view
    | 2 -> Graph_viewer.visible graph_view
    | 3 -> Rules_viewer.visible rules_view
    | _ -> ()));    (* Odswierzanie combo w Verse_viewer nie dziala gdy zmieniam status subcorpusu ??? *)
  project.showed_corpus_model_changed <- [Project_viewer.model_changed project_view; Verse_viewer.model_changed verse_view];
  project.rules_model_changed <- [Rules_viewer.model_changed rules_view; Graph_viewer.model_changed graph_view];
  let project_entries = [
    `I ("New", Project.new_project (Project_viewer.model_changed project_view) project);
    `I ("Open", open_project project);
    `I ("Save", Project.save_project project);
    `S;
    `I ("Quit", quit_command) 
  ] in
  let options_entries = [
    `I ("Graph Viewer Configuration", Graph_viewer.graph_interface_configuration graph_view);
  ] in
  create_menu "Project" menubar project_entries;
  create_menu "Tools" menubar tools_entries;
  create_menu "Options" menubar options_entries;
  create_menu "Help" menubar help_entries;
  Project.new_project (Project_viewer.model_changed project_view) project ();
  window#show ();
  ignore(Glib.Timeout.add ~ms:(1000 * 60 * 15) ~callback:(fun () -> Gc.compact () ; true));
  GtkThread.thread_main ()

let _ = main ()



