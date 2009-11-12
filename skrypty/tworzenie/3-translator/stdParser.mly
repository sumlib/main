%{
(********************************************************)
(*                                                      *)
(*  Copyright 2006 Wojciech Jaworski.                   *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)
%}

%token <string> TERM
%token EOF ESC NEWLINE

%start table
%start three_dim
%start beginning
%start next_table
%type <string list list list> three_dim
%type <string list list> table
%type <string list list> next_table
%type <string list> line
%type <unit> beginning

%%

three_dim: ESC three_dim_rec { $2 }

beginning: ESC { () }
next_table: NEWLINE etabl  { $2 }
          | NEWLINE table  { $2 }
          | EOF            { raise End_of_file }

three_dim_rec: NEWLINE etabl three_dim_rec { $2 :: $3 }
             | NEWLINE table               { [$2] }

etabl: line etabl  { $1 :: $2 }
     | ESC         { [] }

table: line table  { $1 :: $2 }
     | EOF         { [] }

line: NEWLINE     { [] }
    | TERM line   { $1 :: $2 }


%%

