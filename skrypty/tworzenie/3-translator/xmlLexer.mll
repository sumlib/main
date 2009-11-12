{
(********************************************************)
(*                                                      *)
(*  Copyright 2007, 2008 Wojciech Jaworski.             *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

exception Fail of string
open XmlParser

let buf = Buffer.create 1000
}

rule token = parse
  '\n'             { token lexbuf }
| ' '              { token lexbuf }
| '"'              { Buffer.clear buf; string lexbuf }
| ['0'-'9']+       { NUM (Lexing.lexeme lexbuf) }
| '<'              { LT }
| '>'              { GT }
| '/'              { SL }
| '='              { EQ }
| "corpus"         { CORPUS }
| "graph"          { GRAPH }
| "graph_edge"     { GRAPH_EDGE }
| "attribute"      { ATTRIBUTE }
| "list_predicate" { LIST_PREDICATE }
| "acc_predicate"  { ACC_PREDICATE }
| "value"          { VALUE }
| "var"            { VAR }
| "string"         { STRING }
| "int"            { INT }
| "intstring"      { INT_STRING }
| "roots"          { ROOTS }
| "node1"          { NODE1 }
| "node2"          { NODE2 }
| "node"           { NODE }
| "symbol"         { SYMBOL }
| "size"           { SIZE }
| "s"              { S }
| "x"              { X }
| "id"             { ID }
| "name"           { NAME }
| "layer"          { LAYER }
| "rules"          { RULES }
| "normal"         { NORMAL }
| "specific"       { SPECIFIC }
| "delete"         { DELETE }
| "accumulate"     { ACCUMULATE }
| "accumulate_left" { ACCUMULATE_LEFT }
| "accumulate_right" { ACCUMULATE_RIGHT }
| "sem"            { SEM }
| "matched_symbol" { MATCHED_SYMBOL }
| "matched_left"   { MATCHED_LEFT }
| "matched_right"  { MATCHED_RIGHT }
| "matched"        { MATCHED }
| "status"         { STATUS }
| "white"          { WHITE }
| "project"        { PROJECT }
| "subcorpus"      { SUBCORPUS }
| "end_line"          { END_LINE }
| "corpus_filename"{ CORPUS_FILENAME }
| "rules_filename" { RULES_FILENAME }
| eof                         { EOF }
| _                           { raise (Fail ("lexer: illegal symbol: " ^ (Lexing.lexeme lexbuf) ^ " at " ^ (string_of_int (Lexing.lexeme_start lexbuf))))}
and string = parse
    [^'"''\n''&']+        { Buffer.add_string buf (Lexing.lexeme lexbuf); string lexbuf }
| "&amp;"   { Buffer.add_char buf '&'; string lexbuf }
| "&lt;"   { Buffer.add_char buf '<'; string lexbuf }
| "&gt;"   { Buffer.add_char buf '>'; string lexbuf }
| "&apos;"   { Buffer.add_char buf '\''; string lexbuf }
| "&quot;"   { Buffer.add_char buf '"'; string lexbuf }
| "&#"  { Buffer.add_char buf (char_code lexbuf); string lexbuf }
| '"' { VAL (Buffer.contents buf) }
and char_code = parse
    ['0'-'9']+    { let x = int_of_string (Lexing.lexeme lexbuf) in char_code2 lexbuf; Char.chr x }
and char_code2 = parse
    ';' { () }

