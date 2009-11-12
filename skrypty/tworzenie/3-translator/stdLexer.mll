{
(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)
exception Fail of string;;
open StdParser;;
}

rule token = parse
| '\n'                       { NEWLINE }
| [' '','';''\t']+           { token lexbuf }
| [^'\n'' '','';''\t''"''@''\\']+{ TERM (Lexing.lexeme lexbuf) }
| '"'                        { let a = token2 lexbuf in token3 lexbuf; TERM a }
| '@'                        { ESC }
| eof                        { EOF }
| _                          { raise (Fail ("illegal symbol " ^ Lexing.lexeme lexbuf ^ " at " ^ (string_of_int (Lexing.lexeme_start lexbuf))))}
and token2 = parse
| ([^'"''\\']+ | "\\\"" | "\\\\" | '\\'['0'-'9']['0'-'9']['0'-'9'] | "\\t")*        { Lexing.lexeme lexbuf }
(*| _                          { raise (Fail ("illegal symbol2 " ^ Lexing.lexeme lexbuf))}*)
and token3 = parse
| '"'                        { Lexing.lexeme lexbuf }
| _                          { raise (Fail ("illegal symbol3 " ^ Lexing.lexeme lexbuf ^ " at " ^ (string_of_int (Lexing.lexeme_start lexbuf))))}
