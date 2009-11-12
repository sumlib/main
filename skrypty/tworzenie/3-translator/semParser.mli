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

val base :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Types.semantic_action
val acc_base :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Types.acc_semantic_action
