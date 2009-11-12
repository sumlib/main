{
(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

exception Fail of string;;

open SemParser;;
}

rule token = parse
  ' '                         { token lexbuf }
| ";"                         { SEMIC }
| ","                         { COMMA }
| "("                         { LPAREN }
| ")"                         { RPAREN }
| "["                         { LBRACE }
| "]"                         { RBRACE }
| '"'[^'"']+'"'               { TEXT (let s = Lexing.lexeme lexbuf in String.sub s 1 (String.length s - 2)) }
| '"''"'                      { TEXT "" }
| "Unit"                      { UNIT }
| "String"                    { STRING }
| "Int"                       { INT }
| "IntString"                 { INTSTRING }
| "concat"                    { CONCAT }
| "concat_minus"              { CONCAT_MINUS }
| "concat_space"              { CONCAT_SPACE }
| "add_digits"                { ADD_DIGITS }
| "make_city"                 { MAKE_CITY }
| "make_god"                  { MAKE_GOD }
| "make_string"               { MAKE_STRING }
| "inter"                     { INTER }
| "shift"                     { SHIFT }
| "syntax"                    { SYNTAX }
| "concat_acc"                { CONCAT_ACC }
| "concat_as_list"            { CONCAT_AS_LIST }
| "predicate"                 { PREDICATE }
| "predicate_acc"             { PREDICATE_ACC }
| "string_list"               { STRING_LIST }
| "string_list_acc"           { STRING_LIST_ACC }
| "x"                         { X }
| "v"                         { V }
| ['0'-'9']+                  { INTTEXT (int_of_string (Lexing.lexeme lexbuf)) }
| eof                         { EOF }
| _                           { raise (Fail ("lexer: illegal symbol: " ^ (Lexing.lexeme lexbuf)))}
