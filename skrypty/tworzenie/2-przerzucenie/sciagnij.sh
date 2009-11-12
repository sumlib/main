#!/bin/bash


#TODO: jeśli jest force to sprawdzić, czy coś się zmieniło i gdzieś zaznaczyć
maxdl=286

if [ -z "$MAX_PROC" ]; then MAX_PROC=5; fi

start=1
end=999999
current=.
force=0

curl1log=logs/curl1.log
curl2log=logs/curl2.log

if echo "$1" | grep -v "^\-.*" > /dev/null; then start=$1; shift 1; fi 
if echo "$1" | grep -v "^\-.*" > /dev/null; then end=$1; shift 1; fi 
if echo "$1" | grep -v "^\-.*" > /dev/null; then current=$1; shift 1; fi 

# pobieram opcje
while getopts f opcja 
do 
 case $opcja in
  f) force=1;;
  ?) exit 1;;
 esac
done

function test_curl(){
    for i in `seq 10`; do
	echo "$1 : $i"
	sleep 1
    done
}


function get_one(){
	id=$1
	plik=$2
	plik2=$3
	$current/../common/info "Ściąganie tabliczki $id"
	echo "http://cdli.ucla.edu/search/result.pt?id_text=$id"
	curl "http://cdli.ucla.edu/search/result.pt?id_text=$id" > $plik 2>>$curl1log&
 	curl "http://cdli.ucla.edu/search/result.pt?id_text=$id&start=0&result_format=fullcatalog&size=100" >$plik2 2>>$curl1log
# 	test_curl "test_curl1-$id" &
# 	test_curl "test_curl2-$id"
	
        wait
	$current/../common/info "Ściągnięta tabliczka $id"
# 	echo "$id-sprawdzanie"
        if [ `cat $plik | wc -l` -le $maxdl ]; then
		$current/../common/info "Pusta tabliczka:  $id"
		rm $plik;
		rm $plik2;
		return 1
        fi    
	$current/../common/info "Niepusta tabliczka:  $id"
	return 0

}

echo -n >$curl1log
echo -n >$curl2log

ok=0
wrong=0

nproc=0
for i in `$current/../common/ids $start $end`; do
    folder=`$current/../common/get_folder $i`
    f1=$current/../data/strony_cdli/$folder
    f2=$current/../data/dane_cdli/$folder
    plik=$f1/$i.html
    if [ ! -d $f1 ]; then mkdir $f1; fi
    if [ ! -d $f2 ]; then mkdir $f2; fi
    #-s $plik -a `cat $plik | wc -l` -le $maxdl -o !-s $plik 
    
    if [ $force -eq 1 -o ! -s $plik -o `cat $plik 2>/dev/null | wc -l` -le $maxdl ]; then 
	if get_one $i $f1/$i.html $f2/$i.html; then 
	    ok=`echo $ok+1 | bc`
	   # echo ok:$ok
	else 
	    wrong=`echo $wrong+1 | bc`
	    #echo wrong:$wrong
	fi &
	nproc=$(($nproc+1))
	if [ "$nproc" -ge $MAX_PROC ]; then  
	    wait  
	    nproc=0  
	fi  
    else
	$current/../common/info "Tabliczka $i została pominięta"
    fi
done

wait

# echo "Ściągnięto $ok tabliczek"
# echo "Nie było $wrong tabliczek"

