(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

let button_pressed item frame fg selected =
  if !selected then (
    item#misc#modify_fg [`NORMAL, `NAME "black"];  
    frame#misc#modify_bg [`NORMAL, fg];
    selected := false
   ) else (
    item#misc#modify_fg [`NORMAL, `NAME "red"];  
    frame#misc#modify_bg [`NORMAL, `NAME "red"];
    selected := true);
  true

let create graph is_selected show_semantics =
(*  let frame_fg_color = (GBin.frame ())#misc#style#fg `NORMAL in*)
  let cols = Xlist.size graph - 1 in
  let rows = max 1 (Xlist.fold graph 0 (fun max_n (n,_,_,_,_) -> max max_n n)) in
  let grid = GPack.table ~columns:(cols+1) ~rows:(rows+1) ~homogeneous:false () in
  let list = Xlist.fold graph [] (fun list (n,i,j,str,term) -> 
    let frame = GBin.frame ~shadow_type:(if is_selected (n,i,j,str,term) then `OUT else `ETCHED_IN) () in
    let fg = if is_selected (n,i,j,str,term) then (frame#misc#modify_bg [`NORMAL, `NAME "blue"]; `NAME "blue") else `NAME "gray" in
    let event_box = GBin.event_box ~packing:frame#add () in
    let item = GMisc.label ~text:str () ~packing:event_box#add in
    let selected = ref false in
    ignore(event_box#event#connect#button_press ~callback:(fun ev -> 
      if GdkEvent.Button.button ev = 1 then 
	button_pressed item frame fg selected
      else (show_semantics term; true)));
    grid#attach ~left:i ~right:j ~top:n (frame#coerce);
    (selected, item, frame, fg, term) :: list) in 
  grid, list

let coerce (grid, list) =
  grid#coerce

let get_selected (grid, list) =
  Xlist.fold list [] (fun list (selected, item, frame, fg, term) ->
    if !selected then term :: list else list)

let clear_selected (grid, list) =
  Xlist.iter list (fun (selected, item, frame, fg, term) ->
    if !selected then 
      let _ = button_pressed item frame fg selected in ())
