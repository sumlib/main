type token =
  | CONCAT
  | CONCAT_MINUS
  | CONCAT_SPACE
  | ADD_DIGITS
  | CONCAT_ACC
  | CONCAT_AS_LIST
  | PREDICATE
  | PREDICATE_ACC
  | STRING_LIST
  | STRING_LIST_ACC
  | SEMIC
  | COMMA
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | X
  | V
  | EOF
  | TEXT of (string)
  | UNIT
  | STRING
  | INT
  | INTSTRING
  | MAKE_CITY
  | MAKE_GOD
  | MAKE_STRING
  | INTER
  | SHIFT
  | ADD_TREE
  | MAKE_TREE
  | SYNTAX
  | INTTEXT of (int)

open Parsing;;
# 2 "semParser.mly"
(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Meaning
open Types
# 49 "semParser.ml"
let yytransl_const = [|
  257 (* CONCAT *);
  258 (* CONCAT_MINUS *);
  259 (* CONCAT_SPACE *);
  260 (* ADD_DIGITS *);
  261 (* CONCAT_ACC *);
  262 (* CONCAT_AS_LIST *);
  263 (* PREDICATE *);
  264 (* PREDICATE_ACC *);
  265 (* STRING_LIST *);
  266 (* STRING_LIST_ACC *);
  267 (* SEMIC *);
  268 (* COMMA *);
  269 (* LPAREN *);
  270 (* RPAREN *);
  271 (* LBRACE *);
  272 (* RBRACE *);
  273 (* X *);
  274 (* V *);
    0 (* EOF *);
  276 (* UNIT *);
  277 (* STRING *);
  278 (* INT *);
  279 (* INTSTRING *);
  280 (* MAKE_CITY *);
  281 (* MAKE_GOD *);
  282 (* MAKE_STRING *);
  283 (* INTER *);
  284 (* SHIFT *);
  285 (* ADD_TREE *);
  286 (* MAKE_TREE *);
  287 (* SYNTAX *);
    0|]

let yytransl_block = [|
  275 (* TEXT *);
  288 (* INTTEXT *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\003\000\003\000\003\000\004\000\
\004\000\004\000\005\000\005\000\005\000\005\000\005\000\006\000\
\007\000\007\000\000\000\000\000"

let yylen = "\002\000\
\002\000\002\000\003\000\002\000\002\000\001\000\001\000\001\000\
\001\000\003\000\003\000\004\000\001\000\003\000\004\000\001\000\
\002\000\003\000\001\000\003\000\003\000\004\000\004\000\002\000\
\001\000\002\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\006\000\007\000\008\000\009\000\000\000\
\000\000\000\000\000\000\000\000\000\000\027\000\000\000\025\000\
\000\000\028\000\000\000\005\000\016\000\000\000\004\000\002\000\
\000\000\000\000\000\000\000\000\001\000\026\000\024\000\000\000\
\017\000\013\000\000\000\003\000\000\000\019\000\000\000\010\000\
\000\000\011\000\018\000\000\000\000\000\000\000\012\000\000\000\
\014\000\000\000\021\000\000\000\020\000\015\000\023\000\022\000"

let yydgoto = "\003\000\
\014\000\015\000\036\000\023\000\040\000\018\000\019\000"

let yysindex = "\033\000\
\255\254\020\255\000\000\000\000\000\000\000\000\000\000\004\255\
\013\255\243\254\015\255\024\255\247\254\000\000\036\000\000\000\
\022\255\000\000\040\000\000\000\000\000\250\254\000\000\000\000\
\021\255\006\255\255\254\010\255\000\000\000\000\000\000\013\255\
\000\000\000\000\011\255\000\000\013\255\000\000\012\255\000\000\
\031\255\000\000\000\000\252\254\253\254\000\255\000\000\021\255\
\000\000\006\255\000\000\006\255\000\000\000\000\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\019\000\255\255\239\255\237\255\000\000\000\000"

let yytablesize = 47
let yytable = "\004\000\
\005\000\006\000\007\000\027\000\032\000\008\000\048\000\050\000\
\028\000\033\000\052\000\049\000\051\000\009\000\043\000\053\000\
\010\000\011\000\024\000\045\000\037\000\038\000\020\000\039\000\
\016\000\012\000\013\000\017\000\021\000\025\000\055\000\022\000\
\056\000\001\000\002\000\029\000\034\000\035\000\026\000\031\000\
\030\000\042\000\044\000\046\000\047\000\041\000\054\000"

let yycheck = "\001\001\
\002\001\003\001\004\001\013\001\011\001\007\001\011\001\011\001\
\018\001\016\001\011\001\016\001\016\001\015\001\032\000\016\001\
\018\001\019\001\032\001\037\000\015\001\016\001\019\001\018\001\
\005\001\027\001\028\001\008\001\016\001\015\001\050\000\019\001\
\052\000\001\000\002\000\000\000\016\001\017\001\015\001\000\000\
\019\001\032\001\032\001\032\001\014\001\027\000\048\000"

let yynames_const = "\
  CONCAT\000\
  CONCAT_MINUS\000\
  CONCAT_SPACE\000\
  ADD_DIGITS\000\
  CONCAT_ACC\000\
  CONCAT_AS_LIST\000\
  PREDICATE\000\
  PREDICATE_ACC\000\
  STRING_LIST\000\
  STRING_LIST_ACC\000\
  SEMIC\000\
  COMMA\000\
  LPAREN\000\
  RPAREN\000\
  LBRACE\000\
  RBRACE\000\
  X\000\
  V\000\
  EOF\000\
  UNIT\000\
  STRING\000\
  INT\000\
  INTSTRING\000\
  MAKE_CITY\000\
  MAKE_GOD\000\
  MAKE_STRING\000\
  INTER\000\
  SHIFT\000\
  ADD_TREE\000\
  MAKE_TREE\000\
  SYNTAX\000\
  "

let yynames_block = "\
  TEXT\000\
  INTTEXT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Types.semantic_action) in
    Obj.repr(
# 43 "semParser.mly"
                     ( _1 )
# 197 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 46 "semParser.mly"
            ( fun x -> get_predicate_list x _2 )
# 204 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Types.graph_edge list -> Types.variable list list) in
    Obj.repr(
# 47 "semParser.mly"
                    ( fun x -> list_predicate _1 (_3 x) )
# 212 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string list) in
    Obj.repr(
# 48 "semParser.mly"
               ( fun x -> simple_predicates _2 )
# 219 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 49 "semParser.mly"
                 ( predicate _2 )
# 226 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    Obj.repr(
# 51 "semParser.mly"
         ( concat )
# 232 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    Obj.repr(
# 52 "semParser.mly"
               ( concat_minus )
# 238 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    Obj.repr(
# 53 "semParser.mly"
               ( concat_space )
# 244 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    Obj.repr(
# 54 "semParser.mly"
             ( add_digits )
# 250 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Types.graph_edge list -> string list list) in
    Obj.repr(
# 55 "semParser.mly"
                     ( fun x -> inter (_3 x) )
# 257 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 56 "semParser.mly"
                  ( fun x -> shift (get_predicate_list x _3) )
# 264 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : Types.semantic_action) in
    Obj.repr(
# 57 "semParser.mly"
                                     ( fun x -> shift (_3 x) )
# 271 "semParser.ml"
               : Types.semantic_action))
; (fun __caml_parser_env ->
    Obj.repr(
# 72 "semParser.mly"
         ( fun x -> [] )
# 277 "semParser.ml"
               : Types.graph_edge list -> Types.variable list list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 74 "semParser.mly"
                   ( fun x -> [[get_predicate_variable x _2]] )
# 284 "semParser.ml"
               : Types.graph_edge list -> Types.variable list list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Types.graph_edge list -> Types.variable list list) in
    Obj.repr(
# 78 "semParser.mly"
                        ( fun x -> [get_predicate_variable x _2] :: (_4 x) )
# 292 "semParser.ml"
               : Types.graph_edge list -> Types.variable list list))
; (fun __caml_parser_env ->
    Obj.repr(
# 83 "semParser.mly"
         ( [] )
# 298 "semParser.ml"
               : string list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 84 "semParser.mly"
              ( [_1] )
# 305 "semParser.ml"
               : string list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string list) in
    Obj.repr(
# 85 "semParser.mly"
                   ( _1 :: _3 )
# 313 "semParser.ml"
               : string list))
; (fun __caml_parser_env ->
    Obj.repr(
# 88 "semParser.mly"
         ( fun x -> [] )
# 319 "semParser.ml"
               : Types.graph_edge list -> string list list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 89 "semParser.mly"
                   ( fun x -> [get_simple_predicate_name_list_string x _2] )
# 326 "semParser.ml"
               : Types.graph_edge list -> string list list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string list) in
    Obj.repr(
# 90 "semParser.mly"
                      ( fun x -> [_2] )
# 333 "semParser.ml"
               : Types.graph_edge list -> string list list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Types.graph_edge list -> string list list) in
    Obj.repr(
# 91 "semParser.mly"
                        ( fun x -> (get_simple_predicate_name_list_string x _2) :: (_4 x) )
# 341 "semParser.ml"
               : Types.graph_edge list -> string list list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string list) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Types.graph_edge list -> string list list) in
    Obj.repr(
# 92 "semParser.mly"
                           ( fun x -> (_2) :: (_4 x) )
# 349 "semParser.ml"
               : Types.graph_edge list -> string list list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Types.acc_semantic_action) in
    Obj.repr(
# 119 "semParser.mly"
                         ( _1 )
# 356 "semParser.ml"
               : Types.acc_semantic_action))
; (fun __caml_parser_env ->
    Obj.repr(
# 122 "semParser.mly"
             ( concat_acc )
# 362 "semParser.ml"
               : Types.acc_semantic_action))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 123 "semParser.mly"
                     ( predicate_acc _2 )
# 369 "semParser.ml"
               : Types.acc_semantic_action))
(* Entry base *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry acc_base *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let base (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Types.semantic_action)
let acc_base (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 2 lexfun lexbuf : Types.acc_semantic_action)
;;
# 126 "semParser.mly"

# 400 "semParser.ml"
