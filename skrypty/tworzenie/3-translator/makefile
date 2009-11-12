OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep
INCLUDES=-I camlzip-1.02 -I +lablgtk2
OCAMLFLAGS=$(INCLUDES)
OCAMLOPTFLAGS=$(INCLUDES) lablgtk.cmxa unix.cmxa threads.cmxa zip.cmxa str.cmxa 

TRANSLATOR= stdParser.mli stdParser.ml stdLexer.ml xlist.ml xset.ml file.ml xmap.ml int.ml xstd.ml \
    progress.ml types.ml xmlParser.mli xmlParser.ml xmlLexer.ml syntax_graph.ml parser.ml \
    wordLexer.ml import.ml \
    meaning.ml pragmatics.ml semParser.mli semParser.ml semLexer.ml \
    ok_dialog.ml data_entry.ml cascade_entry.ml graph_view.ml \
    verse.ml project.ml atf_lexer.ml subcorpus_viewer.ml project_viewer.ml graph_viewer.ml verse_viewer.ml \
    rules_viewer.ml translator.ml

MTRANSLATOR= stdParser.mli stdParser.ml stdLexer.ml xlist.ml xset.ml file.ml xmap.ml int.ml xstd.ml \
    progress.ml types.ml xmlParser.mli xmlParser.ml xmlLexer.ml syntax_graph.ml parser.ml \
    wordLexer.ml import.ml \
    meaning.ml pragmatics.ml semParser.mli semParser.ml semLexer.ml \
    ok_dialog.ml data_entry.ml cascade_entry.ml graph_view.ml \
    verse.ml project.ml atf_lexer.ml subcorpus_viewer.ml project_viewer.ml graph_viewer.ml verse_viewer.ml \
    rules_viewer.ml mtranslator.ml

all: translator mtranslator

translator: stdParser.ml stdLexer.ml xmlParser.ml xmlLexer.ml semParser.ml semLexer.ml wordLexer.ml
	$(OCAMLOPT) -o translator -thread $(OCAMLOPTFLAGS) gtkThread.cmx gtkInit.cmx $(TRANSLATOR) 

mtranslator: stdParser.ml stdLexer.ml xmlParser.ml xmlLexer.ml semParser.ml semLexer.ml wordLexer.ml
	$(OCAMLOPT) -o mtranslator -thread $(OCAMLOPTFLAGS) gtkThread.cmx gtkInit.cmx  $(MTRANSLATOR) 


.SUFFIXES: .mll .mly .ml .mli .cmo .cmi .cmx

.mll.ml:
	ocamllex $<

.mly.mli:
	ocamlyacc $<

.mly.ml:
	ocamlyacc $<

.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFALGS) -c $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

clean:
	rm -f *~ *.cm[oix] *.o translator mtranslator xmlParser.mli xmlParser.ml xmlLexer.ml semParser.mli semParser.ml semLexer.ml wordLexer.ml slownikLexer.ml

