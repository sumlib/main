%{
(********************************************************)
(*                                                      *)
(*  Copyright 2007, 2008 Wojciech Jaworski.             *)
(*                                                      *)
(*  All rights reserved.                                *)
(*                                                      *)
(********************************************************)

open Types;;
open Xstd;;
%}

  %token LT GT SL EQ EOF
  %token CORPUS GRAPH GRAPH_EDGE LIST_PREDICATE ACC_PREDICATE ATTRIBUTE 
  %token VAR STRING INT INT_STRING ROOTS NODE SIZE
  %token END_LINE
  %token SYMBOL NODE1 NODE2 S X ID NAME LAYER VALUE
  %token RULES NORMAL SPECIFIC DELETE ACCUMULATE ACCUMULATE_LEFT ACCUMULATE_RIGHT
  %token SEM MATCHED_SYMBOL MATCHED_LEFT MATCHED_RIGHT STATUS MATCHED WHITE
  %token PROJECT SUBCORPUS CORPUS_FILENAME RULES_FILENAME
  %token <string> VAL NUM

  %start corpus
  %start corpus2
  %start corpus_start
  %start graph
  %start graph2
  %type <int * (string * Types.graph) list> corpus
  %type <int * (string * string Xstd.StringMap.t) list> corpus2
  %type <(string * graph) list> graph_list
  %type <(string * string Xstd.StringMap.t) list> graph_list2
  %type <int> corpus_start
  %type <string * Types.graph> graph
  %type <string * string Xstd.StringMap.t> graph2
  %type <graph> graph_edge
  %type <string Xstd.StringMap.t> attribute
  %type <language_formula> predicate
  %type <variable list> predicate_arg_list
  %type <variable> predicate_arg
  %type <acc_graph> acc_graph
  %type <(variable * IntSet.t) IntMap.t> node
  %type <IntSet.t> int

  %start rules
  %type <Types.RuleSet.t> rules
  %type <RuleSet.t> rule
  %type <grammar_symbol list> matched
  %type <variable list> matched2

  %start project
  %type <string * string * string * string * string * Types.subcorpus Xstd.StringMap.t> project
  %type <subcorpus StringMap.t> subcorpus
  %type <StringSet.t> ids

  %%

corpus:
  LT CORPUS SIZE EQ VAL GT graph_list LT SL CORPUS GT EOF   { int_of_string $5, List.rev $7 }

corpus2:
  LT CORPUS SIZE EQ VAL GT graph_list2 LT SL CORPUS GT EOF   { int_of_string $5, List.rev $7 }

graph_list:
  { [] }
| graph_list LT GRAPH ID EQ VAL GT graph_edge LT SL GRAPH GT { ($6,$8) :: $1 }

graph_list2:
  { [] }
| graph_list2 LT GRAPH ID EQ VAL GT attribute LT SL GRAPH GT { ($6,$8) :: $1 }

corpus_start:
  LT CORPUS SIZE EQ VAL GT    { int_of_string $5 }

graph:
  LT SL CORPUS GT EOF { raise End_of_file }
| LT GRAPH ID EQ VAL GT graph_edge LT SL GRAPH GT { $5,$7 }

graph2:
  LT SL CORPUS GT EOF { raise End_of_file }
| LT GRAPH ID EQ VAL GT attribute LT SL GRAPH GT { $5,$7 }

graph_edge:
  { SyntaxGraph.empty }
| graph_edge LT GRAPH_EDGE SYMBOL EQ VAL NODE1 EQ VAL NODE2 EQ VAL LAYER EQ VAL GT predicate LT SL GRAPH_EDGE GT    
         { SyntaxGraph.add $1 ($6,int_of_string $9,int_of_string $12) ($17,int_of_string $15) }

attribute:
  { StringMap.empty }
| attribute LT ATTRIBUTE NAME EQ VAL VALUE EQ VAL SL GT    { StringMap.add $1 $6 $9 }

predicate:
  { PredicateSet.empty }
| predicate LT LIST_PREDICATE NAME EQ VAL GT predicate_arg_list LT SL LIST_PREDICATE GT    { PredicateSet.add $1 (List($6,List.rev $8)) }
| predicate LT ACC_PREDICATE NAME EQ VAL GT LT ROOTS GT int LT SL ROOTS GT node LT SL ACC_PREDICATE GT    { PredicateSet.add $1 (Acc($6,($11,$16))) }

predicate_arg_list:
  { [] }
| predicate_arg_list predicate_arg { $2 :: $1 }

predicate_arg:
  LT VAR SYMBOL EQ VAL NODE1 EQ VAL NODE2 EQ VAL SL GT    { ($5,int_of_string $8,int_of_string $11) }

acc_graph:
  LT ROOTS GT int LT SL ROOTS GT int { $4,IntMap.empty }
/*  LT ROOTS GT int LT SL ROOTS GT node { $4,$9 }*/

node:
  { IntMap.empty }
| node LT NODE ID EQ VAL SYMBOL EQ VAL NODE1 EQ VAL NODE2 EQ VAL GT int LT SL NODE GT 
          { IntMap.add $1 (int_of_string $6) (($9,int_of_string $12,int_of_string $15),$17) }

int:
  { IntSet.empty }
| int LT INT GT NUM LT SL INT GT   { IntSet.add $1 (int_of_string $5) }

rules:
  LT RULES GT rule LT SL RULES GT EOF   { $4 }

rule:
  { RuleSet.empty }
| rule LT NORMAL STATUS EQ VAL SYMBOL EQ VAL WHITE EQ VAL SEM EQ VAL GT matched LT SL NORMAL GT 
    { RuleSet.add $1 (Normal(status_of_string $6, $9, List.rev $17, $12, $15)) }
| rule LT SPECIFIC STATUS EQ VAL SYMBOL EQ VAL ID EQ VAL SEM EQ VAL GT matched2 LT SL SPECIFIC GT 
    { RuleSet.add $1 (Specific(status_of_string $6, $9, $12, List.rev $17, $15)) }
| rule LT DELETE STATUS EQ VAL SYMBOL EQ VAL SL GT 
    { RuleSet.add $1 (Delete(status_of_string $6, $9)) }
| rule LT ACCUMULATE STATUS EQ VAL SYMBOL EQ VAL MATCHED_SYMBOL EQ VAL WHITE EQ VAL SEM EQ VAL SL GT 
    { RuleSet.add $1 (Accumulate(status_of_string $6, $9, $12, $15, $18)) }
| rule LT ACCUMULATE_LEFT STATUS EQ VAL SYMBOL EQ VAL MATCHED_SYMBOL EQ VAL MATCHED_LEFT EQ VAL WHITE EQ VAL SEM EQ VAL SL GT 
    { RuleSet.add $1 (AccumulateLeft(status_of_string $6, $9, $12, $15, $18, $21)) }
| rule LT ACCUMULATE_RIGHT STATUS EQ VAL SYMBOL EQ VAL MATCHED_SYMBOL EQ VAL MATCHED_RIGHT EQ VAL WHITE EQ VAL SEM EQ VAL SL GT 
    { RuleSet.add $1 (AccumulateRight(status_of_string $6, $9, $12, $15, $18, $21)) }

matched:
  { [] }
| matched LT MATCHED SYMBOL EQ VAL SL GT    { $6 :: $1 }

matched2:
  { [] }
| matched2 LT MATCHED SYMBOL EQ VAL NODE1 EQ VAL NODE2 EQ VAL SL GT    { ($6,int_of_string $9,int_of_string $12) :: $1 }

project:
  LT PROJECT NAME EQ VAL CORPUS_FILENAME EQ VAL RULES_FILENAME EQ VAL WHITE EQ VAL END_LINE EQ VAL GT subcorpus LT SL PROJECT GT EOF   { $5,$8,$11,$14,$17,$19 }

subcorpus:
  { StringMap.empty }
| subcorpus LT SUBCORPUS NAME EQ VAL STATUS EQ VAL GT ids LT SL SUBCORPUS GT 
    { StringMap.add $1 $6 {status=(subcstatus_of_string $9); ids=$11}}

ids:
  { StringSet.empty }
| ids LT ID ID EQ VAL SL GT { StringSet.add $1 $6 } 

    %%

