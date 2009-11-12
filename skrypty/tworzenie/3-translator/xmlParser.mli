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

val corpus :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> int * (string * Types.graph) list
val corpus2 :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> int * (string * string Xstd.StringMap.t) list
val corpus_start :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> int
val graph :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string * Types.graph
val graph2 :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string * string Xstd.StringMap.t
val rules :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Types.RuleSet.t
val project :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string * string * string * string * string * Types.subcorpus Xstd.StringMap.t
