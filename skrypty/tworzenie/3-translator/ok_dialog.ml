(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

let create title text =
  let dialog = GWindow.dialog ~width:200 ~height:100 ~position:`CENTER_ALWAYS ~title ~modal:true () in
  let _ = GMisc.label ~text ~packing:dialog#vbox#add () in
  let ok_button = GButton.button ~label:"Ok" ~packing:dialog#action_area#add () in
  ignore(ok_button#connect#clicked ~callback:dialog#destroy);
  dialog#show ()

