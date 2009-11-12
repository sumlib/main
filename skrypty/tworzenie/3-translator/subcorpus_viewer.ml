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

let set_model (frame,loaded_button,showed_button,parsed_button,(label : GMisc.label)) model =
  (match model.status with
    Unloaded -> loaded_button#set_active false
  | Loaded -> (showed_button#set_active false; loaded_button#set_active true)
  | Showed -> (parsed_button#set_active false; showed_button#set_active true)
  | Parsed -> parsed_button#set_active true);
  label#set_text (string_of_int (StringSet.size model.ids))

let create name model change =
  let frame = GBin.frame ~label:name () in
  let hbox = GPack.hbox ~packing:frame#add () in
  let loaded_button = GButton.check_button ~packing:hbox#pack ~label:"Loaded" () in  
  let showed_button = GButton.check_button ~packing:hbox#pack ~label:"Showed" () in 
  let parsed_button = GButton.check_button ~packing:hbox#pack ~label:"Parsed" () in
  ignore(loaded_button#connect#toggled ~callback:(fun () -> 
    if not loaded_button#active then ( 
      showed_button#set_active false;
      change Unloaded
     ) else change Loaded));
  ignore(showed_button#connect#toggled ~callback:(fun () ->
    if showed_button#active then (
      loaded_button#set_active true;
      change Showed
     ) else (
      parsed_button#set_active false;
      change Loaded)));
  ignore(parsed_button#connect#toggled ~callback:(fun () ->
    if parsed_button#active then (
      showed_button#set_active true;
      change Parsed
     ) else change Showed));
  let label = GMisc.label ~packing:hbox#pack () in
  let viewer = frame,loaded_button,showed_button,parsed_button,label in
  set_model viewer model;
  viewer

let coerce (frame,loaded_button,showed_button,parsed_button,label) = 
  frame#coerce

let destroy (frame,loaded_button,showed_button,parsed_button,label) =
  frame#destroy ()

let set_quantity (frame,loaded_button,showed_button,parsed_button,label) n =
  label#set_text (string_of_int n)

let get_model (frame,loaded_button,showed_button,parsed_button,label) =
  match loaded_button#active,showed_button#active,parsed_button#active with
    false,false,false -> Unloaded
  | true,false,false -> Loaded
  | true,true,false -> Showed
  | true,true,true -> Parsed
  | _ -> failwith "get_model"
