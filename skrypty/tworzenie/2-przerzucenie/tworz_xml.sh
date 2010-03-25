#!/bin/bash


rm ../data/dane.txt ../data/tekst.atf
./zapisz.sh 1 2 .
python atf2xml_xml.py tekst.atf dane.txt pliki_pom_xml_ .


