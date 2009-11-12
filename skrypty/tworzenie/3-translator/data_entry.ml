(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

type t = GBin.frame * GEdit.entry * string GList.clist * string list ref

let select_list list text =
  let n = String.length text in
  Xlist.filter list (fun s ->
    try String.sub s 0 n = text with _ -> false)

let fill_clist clist list text =
  let list2 = select_list list text in
  clist#freeze ();
  clist#clear ();
  Xlist.iter list2 (fun s ->
    ignore (clist#append [s]));
  clist#thaw ()

let create name =
  let vadjustment = GData.adjustment () in
  let hadjustment = GData.adjustment () in
  let frame = GBin.frame ~label:name () in
  let box = GPack.vbox ~packing:frame#add () in
  let entry = GEdit.entry ~packing:box#pack () in
  let clist_hbox = GPack.hbox ~packing:(box#pack ~fill:true ~expand:true) () in
  let clist = GList.clist ~columns:1 ~vadjustment ~hadjustment ~selection_mode:`SINGLE ~packing:(clist_hbox#pack ~fill:true ~expand:true) () in
  let _ = GRange.scrollbar `VERTICAL ~adjustment:vadjustment ~packing:clist_hbox#pack () in
  let _ = GRange.scrollbar `HORIZONTAL ~adjustment:hadjustment ~packing:box#pack () in
  let r = ref [] in
  ignore (entry#connect#changed ~callback:(fun () -> 
    fill_clist clist (!r) entry#text));
  ignore (clist#connect#select_row ~callback:(fun ~row -> fun ~column -> fun ~event ->
    let text = clist#cell_text row 0 in
    entry#set_text text;
    fill_clist clist (!r) text));
  frame, entry, clist, r

let coerce (box,_,_,_) =
  box#coerce

let set_list (_,entry, clist, r) list =
  fill_clist clist list entry#text;
  r := list

let set_text (_,entry, clist, r) text =
  fill_clist clist (!r) text;
  entry#set_text text

let text (_,entry, clist, r) =
  entry#text 

let connect_changed_callback (_,entry, _, _) callback =
  ignore (entry#connect#changed ~callback:(fun () -> callback entry#text))

