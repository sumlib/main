{
(********************************************************)
(*                                                      *)
(*  Copyright 2007 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

exception Fail of string;;

}

rule token = parse
  ['\000'-'\064''\091'-'\096''\123'-'\127'] { Lexing.lexeme lexbuf }
| ['A'-'Z''a'-'z''\128'-'\255']+  { Lexing.lexeme lexbuf }
| eof                         { raise End_of_file }
| _                           { raise (Fail ("lexer: illegal symbol: " ^ (Lexing.lexeme lexbuf)))}
