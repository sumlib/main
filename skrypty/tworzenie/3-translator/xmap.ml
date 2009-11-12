(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)
module type MapOrderedType =
  sig

    type t
    val compare : t -> t -> int

  end 

module type MAP =
    functor (Ord : MapOrderedType) ->
  sig
    
    type key = Ord.t
    type 'a t
	  
    val empty : 'a t
    val is_empty : 'a t -> bool
    val add : 'a t -> key -> 'a -> 'a t
    val add_inc : 'a t -> key -> 'a -> ('a -> 'a) -> 'a t
    val remove : 'a t -> key -> 'a t
    val find : 'a t -> key -> 'a
    val mem : 'a t -> key -> bool
    val size : 'a t -> int
	
    val iter : 'a t -> (key -> 'a -> unit) -> unit
    val map : 'a t -> ('a -> 'b) -> 'b t
    val mapi : 'a t -> (key -> 'a -> 'b) -> 'b t
    val fold : 'a t -> 'b -> ('b -> key -> 'a -> 'b) -> 'b	

  end

module Make : MAP = 
  functor(Ord : MapOrderedType) ->
  struct 
    
    module T = Map.Make(Ord)
    type key = Ord.t
    type 'a t ='a T.t

    exception NF
	
    let empty = T.empty
    let is_empty = T.is_empty
    let add map key v = T.add key v map
    let add_inc map key v f = 
      try
        T.add key (f (try T.find key map with Not_found -> raise NF)) map 
      with NF -> T.add key v map
    let remove map key = T.remove key map
    let find map key = T.find key map
    let mem map key = T.mem key map
    let size map = T.fold (fun _ -> fun _ -> fun i -> i + 1) map 0
	
	
    let iter map f = T.iter f map
    let map m f = T.map f m
    let mapi map f = T.mapi f map
    let fold map s f = T.fold (fun a -> fun b -> fun c -> f c a b) map s 
	
  end

module type QUANTITY_MAP =
    functor (Ord : MapOrderedType) ->
  sig
    
    type key = Ord.t
    type t
	  
    val empty : t
    val add : t -> key -> t
    val add_val : t -> key -> int -> t
    val find : t -> key -> int 
(*    val mem : 'a t -> key -> bool*)
    val size : t -> int
	
    val iter : t -> (key -> int -> unit) -> unit
    val map : t -> (int -> int) -> t
    val mapi : t -> (key -> int -> int) -> t
    val fold : t -> 'b -> ('b -> key -> int -> 'b) -> 'b	

  end

module MakeQ : QUANTITY_MAP = 
  functor(Ord : MapOrderedType) ->
  struct 
    
    module T = Make(Ord)
    type key = Ord.t
    type t = int T.t

    exception NF
	
    let empty = T.empty
    let add map key = T.add_inc map key 1 (fun v -> v + 1)
    let add_val map key v = T.add_inc map key v (fun n -> v + n)
    let find = T.find 
(*    let mem map key = T.mem key map*)
    let size map = T.size map
	
    let iter = T.iter 
    let map = T.map 
    let mapi = T.mapi 
    let fold = T.fold 
	
  end
