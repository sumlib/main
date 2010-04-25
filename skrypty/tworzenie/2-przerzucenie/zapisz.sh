#!/bin/bash
#set -x
#zostawia puste linie na ko�cu plik�w; co z P010099 ?

datafile=dane.txt
atffile=tekst.atf

start=1
end=999999
current=.
clear=0

if echo "$1" | grep -v "^\-.*" > /dev/null; then start=$1; shift 1; fi 
if echo "$1" | grep -v "^\-.*" > /dev/null; then end=$1; shift 1; fi 
if echo "$1" | grep -v "^\-.*" > /dev/null; then current=$1; shift 1; fi 

while getopts d:a:c opcja 
do 
 case $opcja in
  d) datafile=$OPTARG;;
  a) atffile=$OPTARG;;
  c) clear=1;;
  ?) ;;
 esac
done

dane=$current/../data/dane_cdli
strony=$current/../data/strony_cdli

common=$current/../common

datafile=$current/../data/$datafile
atffile=$current/../data/$atffile

#wyrzuca atf-a
atf() {
id=$1
folder=$2


linia=`cat $dane/$folder/$id.html | grep "Language"`

pom1=${linia#*value\">}
pom2=${pom1%%<*}
#echo $pom2
case "$pom2" in
"Akkadian")               echo akk;;
"Aramaic")                echo arc;;
"Elamite")                echo elx;;
"Ancient Greek")          echo grc;;
"Hittite")                echo hit;;
"Old Persian")            echo peo;;
"Amorite")                echo qam;;
"Carian")                 echo xcr;;
"Undetermined cuneiform") echo qcu;;	
"Eblaite")                echo qeb;;
"Hurrian")                echo xhu;;
"Lycian")                 echo xlc;;
"Lydian")                 echo xld;;
"Cuneiform Luvian")       echo xlu;;
"Hieroglyphic Luvian")    echo hlu;;
"Milyan (Lycian B)")      echo imy;;
"Proto-Cuneiform")        echo qpc;;
"Proto-Elamite")          echo qpe;;
"Palaic")                 echo plq;;
"Urartian")               echo xur;;
"Sumerian")               echo sux;;
"Ugaritic")               echo uga;;
*)                        echo qcu
esac

}


publication() {
	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Primary Publication" | head -n 1 | cut -d: -f 1`

	ktora=$ktora+3
	#publikacja=`cat $input | tail -n $ktora | head -n 1`
	publikacja=`cat $input | head -n $ktora | tail -n 1`
	echo $publikacja
}


#nowy plik z tekstem
tekst() {
	id=$1
	folder=$2
	input=$strony/$folder/$id.html
	publ=`publication $input`
	
	declare -i ktora

	ktora=`cat $input | grep -n 'class="transliteration"' | cut -d: -f 1`
	firstline=`cat $input | grep -n 'class="transliteration"' | cut -d: -f 2`
	first=${firstline##*>}

	ktora=$ktora+1

	#echo "&$id = $publ"
	echo "&$id"
	zm_atf=`atf $id $folder`
	echo "#atf: lang" $zm_atf
	echo $first
	cat $input | tail -n +$ktora | grep -v ">" | grep -v "^[ ]*$"
}


#dopisuje do pliku z collection
collection() {
	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Collection" | head -n 1 | cut -d: -f 1`

	ktora=$ktora+3

	pom=`cat $input | tail -n +$ktora | head -n 1`
	pom1=${pom#*>}
	pom2=${pom1%<*}

	echo $pom2
}

#dopisuje do pliku z museum
museum() {

	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Museum no." | head -n 1 | cut -d: -f 1`

	ktora=$ktora+2

	pom=`cat $input | tail -n +$ktora | head -n 1`
	pom1=${pom#*>}
	pom2=${pom1%<*}

	echo $pom2
}


#dopisuje do pliku z prowiniencja
provenience() {
	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Provenience" | head -n 1 | cut -d: -f 1`

	ktora=$ktora+2

	pom=`cat $input | tail -n +$ktora | head -n 1`
	pom1=${pom#*>}
	pom2=${pom1%<*}

	echo $pom2

}


#dopisuje do pliku z genre
genre() {
	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Genre" | cut -d: -f 1`

	ktora=$ktora+2

	pom=`cat $input | tail -n +$ktora | head -n 1`
	pom1=${pom#*>}
	pom2=${pom1%<*}

	echo $pom2
}

#dopisuje do pliku z subgenre
subgenre() {

	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Subgenre" | head -n 1 | cut -d: -f 1`

	ktora=$ktora+2

	pom=`cat $input | tail -n +$ktora | head -n 1`
	pom1=${pom#*>}
	pom2=${pom1%<*}

	echo $pom2
}

#dopisuje do pliku z period
period() {

	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Period" | head -n 1 | cut -d: -f 1`

	ktora=$ktora+2

	pom=`cat $input | tail -n +$ktora | head -n 1`
	pom1=${pom#*>}
	pom2=${pom1%<*}

	echo $pom2
}

#dopisuje do pliku z measurements
measurements() {
	input=$1
	declare -i ktora
	ktora=`cat $input | grep -n "Measurements" | head -n 1 | cut -d: -f 1`

	ktora=$ktora+3

	pom=`cat $input | tail -n +$ktora | head -n 1`

	echo $pom
}

data(){
#   cols="id_cdli, publikacja, prowiniencja, okres, rozmiary, typ, podtyp, kolekcja, muzeum"
    id=$1
    input=$strony/$2/$id.html
    publ=`publication $input`
    prov=`provenience $input`
    okr=`period $input`
    rozm=`measurements $input`
    typ=`genre $input`
    podtyp=`subgenre $input`
    kol=`collection $input`
    mus=`museum $input`
  echo "$id || $publ || $prov || $okr || $rozm || $typ || $podtyp || $kol || $mus"
}


if [ $clear -gt 0 ]; then
    echo -n > $datafile
    echo -n > $atffile
fi

#główna pętla programu
for i in `$current/../common/ids $start $end`; do
    folder=`$common/get_folder $i`
    if [ ! -s $strony/$folder/$i.html ]; then
	$common/info "Tabliczka $i nie została ściągnięta"
    else
    if [ ! -s $dane/$folder/$i.html ]; then
	$common/info "Dane tabliczki $i nie zostały ściągnięte"
    else
	$common/info "$i:Tworzenie atf-a"
	tekst $i $folder >> $atffile
	$common/info "$i:Zbieranie danych"
	data $i $folder >> $datafile
    fi; fi
done

# if [ $# -gt 1 ]; then 
# 	od=$1
# 	do=$2
# else
# 	if [ $# -gt 0 ]; then 
# 		od=$1
# 		do=$MAX_DO
# 	else
# 		od=1
# 		do=$MAX_DO
# 	fi
# fi
# cd strony_cdli
# for folder in `seq $od $do`; do
# #	echo $folder
# 	if cd $folder; then
# #		echo $folder
# 		for plik in `ls`; do
# 			echo "$folder -> $plik"	
# 			tekst $folder $plik `publication $plik`
# 			sql $plik $folder
# 		done
# 		cd ..
# 	else
# 		echo "nie ma folderu $folder"
# 		exit 0;
# 	fi
# done