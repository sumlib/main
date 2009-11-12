#!/bin/bash
# dokonczyc
# jaka bedzie struktura katalogow i nazwy plikow pomocniczych?


# sciaganie
#mv id_new.txt id.txt
#sciaganie/sciagnij.sh
cd 2-sciaganie
#rm tekst.atf
#rm dane.txt
./zapisz.sh $*
#sciaganie/wyrzuc


# powstale pliki: id_new.txt, tekst.atf, sumlib.atf, tab.sql

#usuwanie &gt; z pliku tekst.atf
plik='tekst.atf'
tmp='tmp'
co="&gt;"
na=">"
cat $plik | sed s/$co/$na/g >$tmp
mv $tmp $plik

# przerabianie tekst.atf (sumlib.atf oddzielnie do sprawdzenia unknown signs)
# mtranslator
cd ../3-translator/
./mtranslator

# wrzucanie do bazy
cd ../5-wrzucanie/
python wrzuc_do_bazy.py

# poprawianie
cd ../4-poprawianie
zcat show.xml.gz > show.xml
zcat sign.xml.gz > sign.xml
zcat sign_name.xml.gz > sign_name.xml

python popraw.py
python xmltosql.py nowy_sign.xml Odczyty
python xmltotext.py



