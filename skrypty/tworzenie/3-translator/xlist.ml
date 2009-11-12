(********************************************************)
(*                                                      *)
(*  Copyright 2006,2007 Wojciech Jaworski.              *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

let iter list f = List.iter f list
let fold list s f = List.fold_left f s list
let map list f = List.map f list
let rev_map list f = List.rev_map f list

let iter2 list list2 f = List.iter2 f list list2
let fold2 list list2 s f = List.fold_left2 f s list list2
let map2 list list2 f = List.map2 f list list2

let rec iter3 list1 list2 list3 f =
  match list1,list2,list3 with
    [],[],[] -> ()
  | x1 :: l1, x2 :: l2, x3 :: l3 -> (f x1 x2 x3; iter3 l1 l2 l3 f)
  | _ -> invalid_arg "List.iter3"

let size = List.length

let tl = List.tl
let hd = List.hd

let mem l e = List.mem e l

let sort l c = List.sort c l

let filter l f = List.filter f l

let assoc l s = List.assoc s l

(* 'a list list -> 'a list list *) 
(* [[a1;a2;...;an];[b1;b2;...;bk];[c1;c2;...;cn]] -> [[a1;b1;c1];[a1;b1;c2];...;[a1;b1;cn];[a1;b2;c1];...] *)
let rec multiply_list = function
    [] -> [[]]
  | x :: list ->
      let list = multiply_list list in
      fold x [] (fun mul a ->
	fold list mul (fun mul args ->
	  (a :: args) :: mul))

