type token =
  | LT
  | GT
  | SL
  | EQ
  | EOF
  | CORPUS
  | GRAPH
  | GRAPH_EDGE
  | LIST_PREDICATE
  | ACC_PREDICATE
  | ATTRIBUTE
  | VAR
  | STRING
  | INT
  | INT_STRING
  | ROOTS
  | NODE
  | SIZE
  | END_LINE
  | SYMBOL
  | NODE1
  | NODE2
  | S
  | X
  | ID
  | NAME
  | LAYER
  | VALUE
  | RULES
  | NORMAL
  | SPECIFIC
  | DELETE
  | ACCUMULATE
  | ACCUMULATE_LEFT
  | ACCUMULATE_RIGHT
  | SEM
  | MATCHED_SYMBOL
  | MATCHED_LEFT
  | MATCHED_RIGHT
  | STATUS
  | MATCHED
  | WHITE
  | PROJECT
  | SUBCORPUS
  | CORPUS_FILENAME
  | RULES_FILENAME
  | VAL of (string)
  | NUM of (string)

open Parsing;;
# 2 "xmlParser.mly"
(********************************************************)
(*                                                      *)
(*  Copyright 2007, 2008 Wojciech Jaworski.             *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Types;;
open Xstd;;
# 64 "xmlParser.ml"
let yytransl_const = [|
  257 (* LT *);
  258 (* GT *);
  259 (* SL *);
  260 (* EQ *);
    0 (* EOF *);
  261 (* CORPUS *);
  262 (* GRAPH *);
  263 (* GRAPH_EDGE *);
  264 (* LIST_PREDICATE *);
  265 (* ACC_PREDICATE *);
  266 (* ATTRIBUTE *);
  267 (* VAR *);
  268 (* STRING *);
  269 (* INT *);
  270 (* INT_STRING *);
  271 (* ROOTS *);
  272 (* NODE *);
  273 (* SIZE *);
  274 (* END_LINE *);
  275 (* SYMBOL *);
  276 (* NODE1 *);
  277 (* NODE2 *);
  278 (* S *);
  279 (* X *);
  280 (* ID *);
  281 (* NAME *);
  282 (* LAYER *);
  283 (* VALUE *);
  284 (* RULES *);
  285 (* NORMAL *);
  286 (* SPECIFIC *);
  287 (* DELETE *);
  288 (* ACCUMULATE *);
  289 (* ACCUMULATE_LEFT *);
  290 (* ACCUMULATE_RIGHT *);
  291 (* SEM *);
  292 (* MATCHED_SYMBOL *);
  293 (* MATCHED_LEFT *);
  294 (* MATCHED_RIGHT *);
  295 (* STATUS *);
  296 (* MATCHED *);
  297 (* WHITE *);
  298 (* PROJECT *);
  299 (* SUBCORPUS *);
  300 (* CORPUS_FILENAME *);
  301 (* RULES_FILENAME *);
    0|]

let yytransl_block = [|
  302 (* VAL *);
  303 (* NUM *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\006\000\006\000\007\000\007\000\003\000\004\000\
\004\000\005\000\005\000\008\000\008\000\009\000\009\000\010\000\
\010\000\010\000\011\000\011\000\012\000\013\000\014\000\014\000\
\015\000\015\000\016\000\017\000\017\000\017\000\017\000\017\000\
\017\000\017\000\018\000\018\000\019\000\019\000\020\000\021\000\
\021\000\022\000\022\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000"

let yylen = "\002\000\
\012\000\012\000\000\000\012\000\000\000\012\000\006\000\005\000\
\011\000\005\000\011\000\000\000\021\000\000\000\011\000\000\000\
\012\000\020\000\000\000\002\000\013\000\009\000\000\000\021\000\
\000\000\009\000\009\000\000\000\021\000\021\000\011\000\020\000\
\023\000\023\000\000\000\008\000\000\000\014\000\024\000\000\000\
\015\000\000\000\008\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\044\000\000\000\045\000\000\000\046\000\000\000\047\000\
\000\000\048\000\000\000\049\000\000\000\050\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\028\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\008\000\000\000\010\000\000\000\
\000\000\000\000\003\000\005\000\007\000\012\000\014\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\027\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\009\000\000\000\011\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\001\000\000\000\002\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\012\000\014\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\031\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\015\000\
\000\000\000\000\000\000\000\000\000\000\000\000\004\000\006\000\
\000\000\000\000\000\000\000\000\000\000\000\000\040\000\000\000\
\035\000\037\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\016\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\032\000\000\000\000\000\000\000\
\000\000\000\000\029\000\000\000\030\000\000\000\000\000\000\000\
\039\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\033\000\
\034\000\000\000\013\000\000\000\000\000\036\000\000\000\000\000\
\000\000\000\000\000\000\042\000\019\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\020\000\000\000\000\000\
\000\000\000\000\000\000\000\000\025\000\000\000\000\000\000\000\
\000\000\000\000\000\000\038\000\041\000\000\000\017\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\043\000\000\000\023\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\026\000\000\000\018\000\000\000\021\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\025\000\000\000\000\000\000\000\000\000\024\000"

let yydgoto = "\008\000\
\010\000\012\000\014\000\016\000\018\000\072\000\073\000\074\000\
\075\000\248\000\041\001\046\001\000\000\079\001\059\001\020\000\
\048\000\224\000\225\000\022\000\222\000\040\001"

let yysindex = "\040\000\
\022\255\034\255\035\255\036\255\053\255\054\255\055\255\000\000\
\017\255\000\000\052\255\000\000\056\255\000\000\006\255\000\000\
\045\255\000\000\030\255\000\000\020\255\000\000\042\255\043\255\
\048\255\058\255\040\255\061\255\044\255\065\255\049\255\066\255\
\067\255\068\255\071\255\072\255\073\255\074\255\000\000\075\255\
\023\255\031\255\037\255\080\000\038\255\081\000\039\255\081\255\
\041\255\084\255\086\255\087\255\000\000\088\255\000\000\089\255\
\000\255\050\255\000\000\000\000\000\000\000\000\000\000\064\255\
\057\255\059\255\060\255\062\255\063\255\069\255\091\255\092\255\
\096\255\099\255\102\255\103\255\100\255\105\255\106\255\107\255\
\108\255\109\255\070\255\046\255\047\255\007\255\005\255\106\000\
\076\255\077\255\078\255\079\255\080\255\082\255\085\255\110\255\
\083\255\112\255\090\255\113\255\101\255\115\255\093\255\000\000\
\114\255\116\255\117\255\118\255\119\255\120\255\123\255\127\255\
\128\255\129\255\130\255\138\255\137\255\140\255\139\255\141\255\
\142\255\143\255\144\255\145\255\146\255\098\255\151\000\111\255\
\152\000\121\255\000\000\122\255\000\000\124\255\125\255\126\255\
\131\255\132\255\133\255\134\255\135\255\000\000\151\255\000\000\
\152\255\136\255\147\255\148\255\149\255\155\255\150\255\154\255\
\156\255\157\255\000\000\000\000\158\255\159\255\160\255\161\255\
\153\255\162\255\165\255\171\255\163\255\180\255\181\255\164\255\
\166\255\167\255\168\255\000\000\169\255\170\255\172\255\173\255\
\021\255\010\255\174\255\182\255\176\255\184\255\179\255\185\255\
\183\255\189\255\177\255\178\255\190\255\186\255\192\255\193\255\
\194\255\195\255\196\255\187\255\199\255\200\255\188\255\000\000\
\191\255\197\255\198\255\201\255\202\255\203\255\000\000\000\000\
\204\255\205\255\206\255\207\255\208\255\209\255\000\000\213\255\
\000\000\000\000\219\255\220\255\221\255\225\255\210\255\226\255\
\227\255\211\255\212\255\214\255\253\254\229\255\254\254\255\254\
\232\255\216\255\217\255\222\255\215\255\000\000\175\255\234\255\
\224\255\236\255\230\255\235\255\237\255\243\255\242\255\228\255\
\001\000\002\000\003\000\005\000\000\000\223\255\231\255\159\000\
\233\255\018\255\000\000\238\255\000\000\239\255\004\000\007\000\
\000\000\241\255\008\000\245\255\247\255\009\000\218\255\015\000\
\016\000\018\000\017\000\021\000\022\000\025\000\026\000\000\000\
\000\000\244\255\000\000\246\255\248\255\000\000\249\255\029\000\
\030\000\031\000\255\255\000\000\000\000\010\000\033\000\034\000\
\039\000\027\000\251\255\001\255\008\255\000\000\041\000\042\000\
\006\000\020\000\038\000\028\000\000\000\046\000\048\000\047\000\
\050\000\049\000\053\000\000\000\000\000\011\000\000\000\012\000\
\003\255\052\000\036\000\044\000\058\000\059\000\060\000\061\000\
\019\000\000\000\023\000\000\000\064\000\051\000\066\000\065\000\
\067\000\002\255\057\000\032\000\068\000\055\000\071\000\072\000\
\074\000\070\000\000\000\078\000\000\000\035\000\000\000\043\000\
\079\000\045\000\062\000\082\000\054\000\063\000\083\000\056\000\
\086\000\000\000\084\000\004\255\073\000\088\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\193\000\
\194\000\000\000\000\000\000\000\000\000\000\000\097\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000"

let yytablesize = 358
let yytable = "\236\000\
\239\000\241\000\064\000\049\001\085\001\068\001\109\001\102\000\
\026\000\100\000\051\001\027\000\188\000\101\000\103\000\069\001\
\069\001\086\001\052\001\103\000\011\001\023\000\009\000\187\000\
\050\001\012\001\013\001\101\000\065\000\066\000\067\000\068\000\
\069\000\070\000\011\000\013\000\015\000\240\000\242\000\237\000\
\001\000\002\000\003\000\004\000\005\000\006\000\007\000\028\000\
\096\000\098\000\029\000\097\000\099\000\017\000\019\000\021\000\
\024\000\030\000\032\000\033\000\025\000\031\000\035\000\036\000\
\034\000\037\000\039\000\038\000\050\000\041\000\042\000\043\000\
\044\000\040\000\046\000\045\000\051\000\047\000\049\000\053\000\
\055\000\057\000\052\000\054\000\056\000\059\000\058\000\060\000\
\061\000\062\000\063\000\076\000\084\000\071\000\083\000\077\000\
\085\000\078\000\079\000\086\000\080\000\081\000\087\000\089\000\
\088\000\104\000\113\000\082\000\090\000\091\000\092\000\093\000\
\094\000\115\000\112\000\095\000\114\000\119\000\116\000\117\000\
\118\000\105\000\106\000\107\000\108\000\109\000\126\000\110\000\
\127\000\111\000\129\000\128\000\120\000\130\000\121\000\122\000\
\123\000\124\000\125\000\131\000\132\000\133\000\134\000\141\000\
\135\000\136\000\137\000\138\000\139\000\140\000\142\000\144\000\
\155\000\156\000\172\000\157\000\143\000\161\000\009\001\000\000\
\165\000\168\000\169\000\170\000\171\000\173\000\145\000\146\000\
\174\000\147\000\148\000\149\000\160\000\158\000\175\000\154\000\
\150\000\151\000\152\000\153\000\177\000\178\000\197\000\198\000\
\190\000\162\000\000\000\200\000\159\000\163\000\186\000\164\000\
\196\000\199\000\189\000\201\000\202\000\203\000\204\000\205\000\
\207\000\208\000\107\001\249\000\215\000\000\000\217\000\218\000\
\176\000\179\000\191\000\180\000\181\000\182\000\183\000\184\000\
\223\000\185\000\192\000\193\000\195\000\194\000\226\000\227\000\
\228\000\229\000\231\000\232\000\002\001\216\000\238\000\253\000\
\206\000\209\000\243\000\000\000\210\000\023\001\254\000\247\000\
\255\000\219\000\211\000\212\000\000\001\001\001\213\000\214\000\
\220\000\221\000\244\000\245\000\250\000\251\000\252\000\230\000\
\233\000\234\000\003\001\235\000\005\001\004\001\016\001\246\000\
\006\001\017\001\042\001\022\001\007\001\020\001\019\001\021\001\
\024\001\025\001\027\001\039\001\008\001\026\001\010\001\018\001\
\028\001\029\001\030\001\014\001\015\001\031\001\036\001\037\001\
\038\001\032\001\044\001\033\001\043\001\034\001\035\001\045\001\
\048\001\047\001\053\001\056\001\054\001\057\001\058\001\060\001\
\055\001\061\001\062\001\063\001\064\001\065\001\070\001\071\001\
\066\001\067\001\072\001\073\001\074\001\097\001\076\001\075\001\
\080\001\077\001\082\001\083\001\078\001\087\001\084\001\081\001\
\091\001\094\001\092\001\093\001\089\001\088\001\090\001\095\001\
\096\001\100\001\098\001\103\001\108\001\101\001\104\001\106\001\
\110\001\111\001\099\001\166\000\000\000\167\000\000\000\000\000\
\000\000\000\000\000\000\102\001\000\000\105\001"

let yycheck = "\003\001\
\003\001\003\001\003\001\003\001\003\001\003\001\003\001\003\001\
\003\001\003\001\003\001\006\001\003\001\007\001\010\001\013\001\
\013\001\016\001\011\001\010\001\003\001\005\001\001\001\003\001\
\024\001\008\001\009\001\007\001\029\001\030\001\031\001\032\001\
\033\001\034\001\001\001\001\001\001\001\040\001\040\001\043\001\
\001\000\002\000\003\000\004\000\005\000\006\000\007\000\003\001\
\003\001\003\001\006\001\006\001\006\001\001\001\001\001\001\001\
\005\001\028\001\017\001\017\001\005\001\042\001\005\001\024\001\
\017\001\005\001\002\001\024\001\046\001\004\001\004\001\004\001\
\002\001\025\001\002\001\004\001\046\001\004\001\004\001\000\000\
\000\000\001\001\046\001\046\001\046\001\002\001\046\001\002\001\
\002\001\002\001\002\001\028\001\001\001\044\001\004\001\039\001\
\001\001\039\001\039\001\001\001\039\001\039\001\001\001\004\001\
\002\001\000\000\024\001\039\001\004\001\004\001\004\001\004\001\
\004\001\024\001\005\001\046\001\005\001\025\001\006\001\019\001\
\006\001\046\001\046\001\046\001\046\001\046\001\004\001\046\001\
\002\001\045\001\002\001\004\001\019\001\004\001\019\001\019\001\
\019\001\019\001\019\001\002\001\004\001\002\001\004\001\046\001\
\004\001\004\001\004\001\004\001\004\001\004\001\000\000\000\000\
\002\001\002\001\002\001\020\001\046\001\003\001\000\000\255\255\
\004\001\004\001\004\001\004\001\004\001\004\001\046\001\046\001\
\004\001\046\001\046\001\046\001\024\001\027\001\004\001\041\001\
\046\001\046\001\046\001\046\001\001\001\001\001\006\001\006\001\
\003\001\036\001\255\255\002\001\041\001\036\001\018\001\036\001\
\004\001\004\001\021\001\004\001\004\001\004\001\004\001\004\001\
\002\001\002\001\106\001\029\001\002\001\255\255\002\001\002\001\
\046\001\046\001\035\001\046\001\046\001\046\001\046\001\046\001\
\004\001\046\001\035\001\041\001\038\001\037\001\004\001\004\001\
\004\001\001\001\001\001\001\001\001\001\026\001\002\001\002\001\
\046\001\046\001\003\001\255\255\046\001\020\001\004\001\025\001\
\004\001\035\001\046\001\046\001\002\001\004\001\046\001\046\001\
\041\001\041\001\035\001\035\001\019\001\030\001\019\001\046\001\
\046\001\046\001\002\001\046\001\002\001\004\001\003\001\042\001\
\004\001\003\001\001\001\003\001\046\001\025\001\007\001\025\001\
\002\001\002\001\002\001\021\001\046\001\004\001\046\001\039\001\
\004\001\004\001\002\001\046\001\046\001\004\001\002\001\002\001\
\002\001\046\001\001\001\046\001\004\001\046\001\046\001\001\001\
\046\001\015\001\002\001\024\001\003\001\008\001\019\001\002\001\
\043\001\002\001\004\001\002\001\004\001\001\001\003\001\020\001\
\046\001\046\001\015\001\002\001\002\001\019\001\002\001\004\001\
\001\001\047\001\001\001\003\001\046\001\013\001\004\001\021\001\
\002\001\004\001\003\001\002\001\009\001\046\001\024\001\002\001\
\046\001\020\001\004\001\021\001\001\001\004\001\004\001\002\001\
\016\001\002\001\046\001\155\000\255\255\156\000\255\255\255\255\
\255\255\255\255\255\255\046\001\255\255\046\001"

let yynames_const = "\
  LT\000\
  GT\000\
  SL\000\
  EQ\000\
  EOF\000\
  CORPUS\000\
  GRAPH\000\
  GRAPH_EDGE\000\
  LIST_PREDICATE\000\
  ACC_PREDICATE\000\
  ATTRIBUTE\000\
  VAR\000\
  STRING\000\
  INT\000\
  INT_STRING\000\
  ROOTS\000\
  NODE\000\
  SIZE\000\
  END_LINE\000\
  SYMBOL\000\
  NODE1\000\
  NODE2\000\
  S\000\
  X\000\
  ID\000\
  NAME\000\
  LAYER\000\
  VALUE\000\
  RULES\000\
  NORMAL\000\
  SPECIFIC\000\
  DELETE\000\
  ACCUMULATE\000\
  ACCUMULATE_LEFT\000\
  ACCUMULATE_RIGHT\000\
  SEM\000\
  MATCHED_SYMBOL\000\
  MATCHED_LEFT\000\
  MATCHED_RIGHT\000\
  STATUS\000\
  MATCHED\000\
  WHITE\000\
  PROJECT\000\
  SUBCORPUS\000\
  CORPUS_FILENAME\000\
  RULES_FILENAME\000\
  "

let yynames_block = "\
  VAL\000\
  NUM\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 5 : (string * graph) list) in
    Obj.repr(
# 59 "xmlParser.mly"
                                                            ( int_of_string _5, List.rev _7 )
# 448 "xmlParser.ml"
               : int * (string * Types.graph) list))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 5 : (string * string Xstd.StringMap.t) list) in
    Obj.repr(
# 62 "xmlParser.mly"
                                                             ( int_of_string _5, List.rev _7 )
# 456 "xmlParser.ml"
               : int * (string * string Xstd.StringMap.t) list))
; (fun __caml_parser_env ->
    Obj.repr(
# 65 "xmlParser.mly"
  ( [] )
# 462 "xmlParser.ml"
               : (string * graph) list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 11 : (string * graph) list) in
    let _6 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 4 : graph) in
    Obj.repr(
# 66 "xmlParser.mly"
                                                             ( (_6,_8) :: _1 )
# 471 "xmlParser.ml"
               : (string * graph) list))
; (fun __caml_parser_env ->
    Obj.repr(
# 69 "xmlParser.mly"
  ( [] )
# 477 "xmlParser.ml"
               : (string * string Xstd.StringMap.t) list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 11 : (string * string Xstd.StringMap.t) list) in
    let _6 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 4 : string Xstd.StringMap.t) in
    Obj.repr(
# 70 "xmlParser.mly"
                                                             ( (_6,_8) :: _1 )
# 486 "xmlParser.ml"
               : (string * string Xstd.StringMap.t) list))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 73 "xmlParser.mly"
                              ( int_of_string _5 )
# 493 "xmlParser.ml"
               : int))
; (fun __caml_parser_env ->
    Obj.repr(
# 76 "xmlParser.mly"
                      ( raise End_of_file )
# 499 "xmlParser.ml"
               : string * Types.graph))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 4 : graph) in
    Obj.repr(
# 77 "xmlParser.mly"
                                                  ( _5,_7 )
# 507 "xmlParser.ml"
               : string * Types.graph))
; (fun __caml_parser_env ->
    Obj.repr(
# 80 "xmlParser.mly"
                      ( raise End_of_file )
# 513 "xmlParser.ml"
               : string * string Xstd.StringMap.t))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 4 : string Xstd.StringMap.t) in
    Obj.repr(
# 81 "xmlParser.mly"
                                                 ( _5,_7 )
# 521 "xmlParser.ml"
               : string * string Xstd.StringMap.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 84 "xmlParser.mly"
  ( SyntaxGraph.empty )
# 527 "xmlParser.ml"
               : graph))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 20 : graph) in
    let _6 = (Parsing.peek_val __caml_parser_env 15 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 12 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _17 = (Parsing.peek_val __caml_parser_env 4 : language_formula) in
    Obj.repr(
# 86 "xmlParser.mly"
         ( SyntaxGraph.add _1 (_6,int_of_string _9,int_of_string _12) (_17,int_of_string _15) )
# 539 "xmlParser.ml"
               : graph))
; (fun __caml_parser_env ->
    Obj.repr(
# 89 "xmlParser.mly"
  ( StringMap.empty )
# 545 "xmlParser.ml"
               : string Xstd.StringMap.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 10 : string Xstd.StringMap.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 90 "xmlParser.mly"
                                                           ( StringMap.add _1 _6 _9 )
# 554 "xmlParser.ml"
               : string Xstd.StringMap.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 93 "xmlParser.mly"
  ( PredicateSet.empty )
# 560 "xmlParser.ml"
               : language_formula))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 11 : language_formula) in
    let _6 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 4 : variable list) in
    Obj.repr(
# 94 "xmlParser.mly"
                                                                                           ( PredicateSet.add _1 (List(_6,List.rev _8)) )
# 569 "xmlParser.ml"
               : language_formula))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 19 : language_formula) in
    let _6 = (Parsing.peek_val __caml_parser_env 14 : string) in
    let _11 = (Parsing.peek_val __caml_parser_env 9 : IntSet.t) in
    let _16 = (Parsing.peek_val __caml_parser_env 4 : (variable * IntSet.t) IntMap.t) in
    Obj.repr(
# 95 "xmlParser.mly"
                                                                                                          ( PredicateSet.add _1 (Acc(_6,(_11,_16))) )
# 579 "xmlParser.ml"
               : language_formula))
; (fun __caml_parser_env ->
    Obj.repr(
# 98 "xmlParser.mly"
  ( [] )
# 585 "xmlParser.ml"
               : variable list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : variable list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : variable) in
    Obj.repr(
# 99 "xmlParser.mly"
                                   ( _2 :: _1 )
# 593 "xmlParser.ml"
               : variable list))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _11 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 102 "xmlParser.mly"
                                                          ( (_5,int_of_string _8,int_of_string _11) )
# 602 "xmlParser.ml"
               : variable))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 5 : IntSet.t) in
    let _9 = (Parsing.peek_val __caml_parser_env 0 : IntSet.t) in
    Obj.repr(
# 105 "xmlParser.mly"
                                     ( _4,IntMap.empty )
# 610 "xmlParser.ml"
               : acc_graph))
; (fun __caml_parser_env ->
    Obj.repr(
# 109 "xmlParser.mly"
  ( IntMap.empty )
# 616 "xmlParser.ml"
               : (variable * IntSet.t) IntMap.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 20 : (variable * IntSet.t) IntMap.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 15 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 12 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _17 = (Parsing.peek_val __caml_parser_env 4 : IntSet.t) in
    Obj.repr(
# 111 "xmlParser.mly"
          ( IntMap.add _1 (int_of_string _6) ((_9,int_of_string _12,int_of_string _15),_17) )
# 628 "xmlParser.ml"
               : (variable * IntSet.t) IntMap.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 114 "xmlParser.mly"
  ( IntSet.empty )
# 634 "xmlParser.ml"
               : IntSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 8 : IntSet.t) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : string) in
    Obj.repr(
# 115 "xmlParser.mly"
                                   ( IntSet.add _1 (int_of_string _5) )
# 642 "xmlParser.ml"
               : IntSet.t))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 5 : RuleSet.t) in
    Obj.repr(
# 118 "xmlParser.mly"
                                        ( _4 )
# 649 "xmlParser.ml"
               : Types.RuleSet.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 121 "xmlParser.mly"
  ( RuleSet.empty )
# 655 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 20 : RuleSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 15 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 12 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _17 = (Parsing.peek_val __caml_parser_env 4 : grammar_symbol list) in
    Obj.repr(
# 123 "xmlParser.mly"
    ( RuleSet.add _1 (Normal(status_of_string _6, _9, List.rev _17, _12, _15)) )
# 667 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 20 : RuleSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 15 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 12 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _17 = (Parsing.peek_val __caml_parser_env 4 : variable list) in
    Obj.repr(
# 125 "xmlParser.mly"
    ( RuleSet.add _1 (Specific(status_of_string _6, _9, _12, List.rev _17, _15)) )
# 679 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 10 : RuleSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 127 "xmlParser.mly"
    ( RuleSet.add _1 (Delete(status_of_string _6, _9)) )
# 688 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 19 : RuleSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 14 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 11 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _18 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 129 "xmlParser.mly"
    ( RuleSet.add _1 (Accumulate(status_of_string _6, _9, _12, _15, _18)) )
# 700 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 22 : RuleSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 17 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 14 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 11 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _18 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _21 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 131 "xmlParser.mly"
    ( RuleSet.add _1 (AccumulateLeft(status_of_string _6, _9, _12, _15, _18, _21)) )
# 713 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 22 : RuleSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 17 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 14 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 11 : string) in
    let _15 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _18 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _21 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 133 "xmlParser.mly"
    ( RuleSet.add _1 (AccumulateRight(status_of_string _6, _9, _12, _15, _18, _21)) )
# 726 "xmlParser.ml"
               : RuleSet.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 136 "xmlParser.mly"
  ( [] )
# 732 "xmlParser.ml"
               : grammar_symbol list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 7 : grammar_symbol list) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 137 "xmlParser.mly"
                                            ( _6 :: _1 )
# 740 "xmlParser.ml"
               : grammar_symbol list))
; (fun __caml_parser_env ->
    Obj.repr(
# 140 "xmlParser.mly"
  ( [] )
# 746 "xmlParser.ml"
               : variable list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 13 : variable list) in
    let _6 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _12 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 141 "xmlParser.mly"
                                                                       ( (_6,int_of_string _9,int_of_string _12) :: _1 )
# 756 "xmlParser.ml"
               : variable list))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 19 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 16 : string) in
    let _11 = (Parsing.peek_val __caml_parser_env 13 : string) in
    let _14 = (Parsing.peek_val __caml_parser_env 10 : string) in
    let _17 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _19 = (Parsing.peek_val __caml_parser_env 5 : subcorpus StringMap.t) in
    Obj.repr(
# 144 "xmlParser.mly"
                                                                                                                                       ( _5,_8,_11,_14,_17,_19 )
# 768 "xmlParser.ml"
               : string * string * string * string * string * Types.subcorpus Xstd.StringMap.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 147 "xmlParser.mly"
  ( StringMap.empty )
# 774 "xmlParser.ml"
               : subcorpus StringMap.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 14 : subcorpus StringMap.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 9 : string) in
    let _9 = (Parsing.peek_val __caml_parser_env 6 : string) in
    let _11 = (Parsing.peek_val __caml_parser_env 4 : StringSet.t) in
    Obj.repr(
# 149 "xmlParser.mly"
    ( StringMap.add _1 _6 {status=(subcstatus_of_string _9); ids=_11})
# 784 "xmlParser.ml"
               : subcorpus StringMap.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 152 "xmlParser.mly"
  ( StringSet.empty )
# 790 "xmlParser.ml"
               : StringSet.t))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 7 : StringSet.t) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 153 "xmlParser.mly"
                            ( StringSet.add _1 _6 )
# 798 "xmlParser.ml"
               : StringSet.t))
(* Entry corpus *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry corpus2 *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry corpus_start *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry graph *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry graph2 *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry rules *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry project *)
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
let corpus (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : int * (string * Types.graph) list)
let corpus2 (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 2 lexfun lexbuf : int * (string * string Xstd.StringMap.t) list)
let corpus_start (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 3 lexfun lexbuf : int)
let graph (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 4 lexfun lexbuf : string * Types.graph)
let graph2 (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 5 lexfun lexbuf : string * string Xstd.StringMap.t)
let rules (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 6 lexfun lexbuf : Types.RuleSet.t)
let project (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 7 lexfun lexbuf : string * string * string * string * string * Types.subcorpus Xstd.StringMap.t)
;;
# 156 "xmlParser.mly"

# 849 "xmlParser.ml"
