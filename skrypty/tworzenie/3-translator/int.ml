(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

type t = int

let compare = compare

let fold min_n max_n s f =
  let r = ref s in
  for n = min_n to max_n do 
    r := f (!r) n 
  done;
  (!r)

let fold_down max_n min_n s f =
  let r = ref s in
  for n = max_n downto min_n do 
    r := f (!r) n 
  done;
  (!r)

let iter min_n max_n f =
  for n = min_n to max_n do 
    f n 
  done

let iter_down min_n max_n f =
  for n = min_n to max_n do 
    f n 
  done
