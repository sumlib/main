(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

let time_string2 time =
  if time > 12000. then Printf.sprintf "%.02f hours" (time /. 3600.) else
  if time > 200. then Printf.sprintf "%.02f minutes" (time /. 60.)
  else Printf.sprintf "%.02f seconds" time 

let time_string rest_time full_time =
  " estimated time " ^ (time_string2 rest_time) ^ " (full time " ^ (time_string2 full_time) ^ ")"

let create name size =
  let window = GWindow.window ~title:name ~width:500 ~border_width:0 ~modal:true () in 
  let progress_bar = GRange.progress_bar ~packing:window#add () in
  window#show ();
  let n = ref 0 in
  let start_time = Unix.gettimeofday () in
  let timeout = GMain.Timeout.add ~ms:500 ~callback:(fun () -> 
    progress_bar#set_fraction ((float (!n)) /. (float size));
    let act_time = Unix.gettimeofday () -. start_time in
    let full_time = act_time /. (float (!n)) *. (float size) in
    let rest_time = full_time -. act_time in
    let time_string = time_string rest_time full_time in
    progress_bar#set_text ((string_of_int (!n)) ^ " of " ^ (string_of_int size) ^ time_string);
    true) in 
  window,progress_bar,size,n,timeout

let destroy (window,progress_bar,size,n,timeout) =
  GMain.Timeout.remove timeout;
  window#destroy ()

let next (window,progress_bar,size,n,timeout) =
  incr n;

