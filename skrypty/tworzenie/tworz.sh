#!/bin/bash

#TODO: jeśli jest force to sprawdzić, czy coś się zmieniło i gdzieś zaznaczyć, żeby nie zmieniać

function bledneUzycie(){
  echo "USAGE: $0 <logfilename> [-p] [-d] [-g] [-x] [-i] [-f] [-s <n> -e <m>]"
  echo "see $0 help for help"
  exit 0
}

function bigInfo(){
    #echo "BIG INFO: $1" 
    debug "BIG INFO: $1" 
}	


# jeśli nie ma żadnych opcji
if [ $# -eq 0 ]; then
  bledneUzycie
fi

# włączenie pomocy
if [ $1 = "help" ]; then
  echo "Options:"
  echo " -p : prepare serwer (only postgres)"
  echo " -d : install database (only postgres)"
  echo " -g : get data from web"
  echo " -i database: insert into database (postgres, xml or both)"
  echo " -f : force (overwrite data)"
  echo " -s n, -e m: start from tablet nr n to m"
#  echo " -sf n, -ef m: start from folder n to m"
  exit 0
fi

#domyślne wartości zmiennych
start=0
end=999999
serwer=0
database=0
get=0
force=0
insert=0
log=debug.log
options=""
db_name=sumlib
#db_port=5432
db_port=5433
db_host=localhost
db_user=asia
db_pass=achajka

#ustawianie danych do bazy:
for line in `cat common/database.conf`; do 
    zm=`echo $line | cut -d= -f2`
    case `echo $line | cut -d= -f1` in
	DB_HOST) db_host=$zm;;
	DB_PORT) db_port=$zm;;
	DB_NAME) db_name=$zm;;
	DB_USER) db_user=$zm;;
	DB_PASS) db_pass=$zm;;
    esac
done

# sprawdzam, czy użytkownik wybrał nazwę pliku do logów
if echo "$1" | grep -v "\-.*" > /dev/null; then log=$1; shift 1; fi 

# pobieram opcje
while getopts pdgfi:s:e: opcja 
do 
 case $opcja in
  s) start=$OPTARG;;
  e) end=$OPTARG;;
  p) serwer=1;;
  d) database=1;;
  g) get=1;;
  f) force=1;;
  i) insert=1 ; db_kind=$OPTARG;;
  ?) bledneUzycie;;
 esac
done

# poprawiam plik do logów
log=logs/$log

if [ -e $log ]; then
    mv $log ${log}_`date +%Y-%m-%d-%H:%M`
fi    

# przygotowuję opcje:
if [ $force -eq 1 ]; then options="-f"; fi

# inicjuję plik do logów
echo >>$log
echo -n "TIME: " >>$log
date >>$log

# ile na raz podprocesów może się wykonywać
export MAX_PROC=4


me=`whoami`

if [ $serwer -eq 1 ]; then
  bigInfo "Tworzenie bazy" 2>>$log
  sudo su postgres -c ". 1-baza_danych/tworzenie_bazy.sh $db_name $db_host $db_port $db_user $db_pass 1-baza_danych" 2>>$log
fi

if [ $database -eq 1 ]; then
  bigInfo "Tworzenie tabel" 2>>$log
  1-baza_danych/install.sh $db_name $db_host $db_port $db_user $db_pass 1-baza_danych 2>>$log >/dev/null
fi

if [ $get -eq 1 ]; then
  bigInfo "Ściąganie danych" 2>>$log >/dev/null
  2-przerzucenie/sciagnij.sh $start $end 2-przerzucenie 2>>$log $options
fi

if [ $insert -eq 1 ]; then
	if [ $force -eq 1 ]; then
		python 2-przerzucenie/wyczysc_baze.py $db_name $db_user $db_pass $db_host $db_port 2-przerzucenie 2>>$log
		2-przerzucenie/zapisz.sh $start $end 2-przerzucenie -d data.txt -a tekst.atf -c 2>>$log
	else
		2-przerzucenie/zapisz.sh $start $end 2-przerzucenie -d data.txt -a tekst.atf 2>>$log
	fi
	
	if [ "$db_kind" = "postgres" -o "$db_kind" = "both" ]; then
		echo postgres
		python 2-przerzucenie/wrzuc_do_bazy.py data.txt $db_name $db_user $db_pass $db_host $db_port 2-przerzucenie 2>>$log
		#python 2-przerzucenie/atf2xml.py tekst.atf show.xml 2-przerzucenie 2>>$log
		python 2-przerzucenie/wrzuc_tekst.py tekst.atf $db_name $db_user $db_pass $db_host $db_port 2-przerzucenie 2>>$log
		python 2-przerzucenie/wrzuc_sekwencje.py tekst.atf $db_name $db_user $db_pass $db_host $db_port 2-przerzucenie 2>>$log
	fi
	if [ "$db_kind" = "xml" -o "$db_kind" = "both" ]; then
		echo xml
		python 2-przerzucenie/atf2xml_xml.py tekst.atf data.txt sumlib.xml .
	fi
fi

# Potrzebne opcje:
# - zrób wszystko wszystko
# - update brakujących
# - update z nadpisaniem (sprawdza tagi, tymczasowa tabelka)