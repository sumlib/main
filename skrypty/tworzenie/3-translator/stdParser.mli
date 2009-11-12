type token =
  | TERM of (string)
  | EOF
  | ESC
  | NEWLINE

val table :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string list list
val three_dim :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string list list list
val beginning :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> unit
val next_table :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string list list
