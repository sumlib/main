(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

module OrderedFloat = struct

type t = float

let compare = compare

let to_string = string_of_float
let of_string = float_of_string

end

module OrderedString = struct

type t = string

let compare = compare

let to_string x = x
let of_string x = x

end

module StringMap = Xmap.Make(OrderedString)
module IntMap = Xmap.Make(Int)
module FloatMap = Xmap.Make(OrderedFloat)
module IntSet = Xset.Make(Int)
module StringSet = Xset.Make(OrderedString)

module StringQMap = Xmap.MakeQ(OrderedString)
module IntQMap = Xmap.MakeQ(Int)

