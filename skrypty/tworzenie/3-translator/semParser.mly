%{
(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Meaning
open Types
%}

  %token CONCAT CONCAT_MINUS CONCAT_SPACE ADD_DIGITS
  %token CONCAT_ACC CONCAT_AS_LIST
  %token PREDICATE PREDICATE_ACC STRING_LIST STRING_LIST_ACC
  %token SEMIC COMMA LPAREN RPAREN LBRACE RBRACE X V EOF 
  %token <string> TEXT 
  %token UNIT STRING INT INTSTRING 
  %token MAKE_CITY MAKE_GOD MAKE_STRING
  %token INTER SHIFT ADD_TREE MAKE_TREE SYNTAX
  %token <int> INTTEXT 

  %start base
  %type <Types.semantic_action> base
  %type <Types.semantic_action> predicate_list
  %type <Types.graph_edge list -> Types.variable list list> vlist
  %type <string list> slist
  %type <Types.graph_edge list -> string list list> ilist
/*  %type <Meaning.tm list> string
  %type <Meaning.tm list> intstring
  %type <Meaning.tm list> int
  %type <(Meaning.v * Meaning.t) list -> Meaning.t list> tlist
  %type <(Meaning.v * Meaning.t) list -> Meaning.s> yvar*/

  %start acc_base
  %type <Types.acc_semantic_action> acc_base
  %type <Types.acc_semantic_action> acc_predicate_list

  %%

base:
  predicate_list EOF { $1 }

predicate_list:
  V INTTEXT { fun x -> get_predicate_list x $2 }
| TEXT LBRACE vlist { fun x -> list_predicate $1 ($3 x) }
| LBRACE slist { fun x -> simple_predicates $2 }
| PREDICATE TEXT { predicate $2 }
/*| CONCAT_AS_LIST LBRACE vlist { fun x -> concat_as_list ($3 x) }*/
| CONCAT { concat }
| CONCAT_MINUS { concat_minus }
| CONCAT_SPACE { concat_space }
| ADD_DIGITS { add_digits }
| INTER LBRACE ilist { fun x -> inter ($3 x) }
| SHIFT V INTTEXT { fun x -> shift (get_predicate_list x $3) }
| SHIFT LPAREN predicate_list RPAREN { fun x -> shift ($3 x) }
/*| STRING_LIST { string_list }
| MAKE_GOD { make_god }
| MAKE_STRING TEXT { make_string $2 }
| MAKE_CITY { make_city }*/
/*| SYNTAX TEXT { syntax $2 }
| TEXT COMMA UNIT { fun _ -> [List ($1, [])] }
| TEXT COMMA STRING LBRACE string { fun _ -> Xlist.map $5 (fun x -> $1,x) }
| TEXT COMMA INT LBRACE int { fun _ -> Xlist.map $5 (fun x -> $1,x) }
| TEXT COMMA INTSTRING LBRACE intstring { fun _ -> Xlist.map $5 (fun x -> $1,x) }
| LPAREN meaning RPAREN { $2 }
| INTER LBRACE tlist { fun x -> Meaning.inter ($3 x) }
| SHIFT meaning { fun x -> Meaning.shift ($2 x) }*/

vlist:
  RBRACE { fun x -> [] }
/*| V INTTEXT RBRACE { fun x -> [get_simple_predicate_name_list x $2] }*/
| X INTTEXT RBRACE { fun x -> [[get_predicate_variable x $2]] }
/*| SYNTAX RBRACE { fun x -> [[syntax x]] }*/
/*| TEXT RBRACE { fun x -> [[String $1]] }*/
/*| V INTTEXT SEMIC vlist { fun x -> (get_simple_predicate_name_list x $2) :: ($4 x) }*/
| X INTTEXT SEMIC vlist { fun x -> [get_predicate_variable x $2] :: ($4 x) }
/*| SYNTAX SEMIC vlist { fun x -> [syntax x] :: ($3 x) }*/
/*| TEXT SEMIC vlist { fun x -> [String $1] :: ($3 x) }*/

slist:
  RBRACE { [] }
| TEXT RBRACE { [$1] }
| TEXT SEMIC slist { $1 :: $3 }

ilist:
  RBRACE { fun x -> [] }
| V INTTEXT RBRACE { fun x -> [get_simple_predicate_name_list_string x $2] }
| LBRACE slist RBRACE { fun x -> [$2] }
| V INTTEXT SEMIC ilist { fun x -> (get_simple_predicate_name_list_string x $2) :: ($4 x) }
| LBRACE slist SEMIC ilist { fun x -> ($2) :: ($4 x) }

/*string:
  RBRACE { [] }
| TEXT RBRACE { [String $1] }
| TEXT SEMIC string { (String $1) :: $3 }
    
int:
  RBRACE { [] }
| INTTEXT RBRACE { [Int $1] }
| INTTEXT SEMIC int { (Int $1) :: $3 }
    
intstring:
  RBRACE { [] }
| INTTEXT COMMA TEXT RBRACE { [IntString ($1,$3)] }
| INTTEXT COMMA TEXT SEMIC intstring { (IntString ($1,$3)) :: $5 }

tlist:
  RBRACE { fun x -> [] }
| meaning RBRACE { fun x -> [$1 x] }
| meaning SEMIC tlist { fun x -> ($1 x) :: ($3 x) }

yvar:
  Y INTTEXT { fun x -> S (fst (List.nth x ($2-1))) }
| meaning { fun x -> T ($1 x) }*/
    
acc_base:
  acc_predicate_list EOF { $1 }

acc_predicate_list:
  CONCAT_ACC { concat_acc }
| PREDICATE_ACC TEXT { predicate_acc $2 }
/*| STRING_LIST_ACC { string_list_acc }*/
    %%

