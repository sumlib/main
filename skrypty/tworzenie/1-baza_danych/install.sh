#!/bin/bash
database=sumlib
user=asia
port=5432
pass=null
host=localhost
current=.

echo $*

if [ $# -gt 0 ]; then database=$1; shift 1; fi 
if [ $# -gt 0 ]; then host=$1; shift 1; fi 
if [ $# -gt 0 ]; then port=$1; shift 1; fi 
if [ $# -gt 0 ]; then user=$1; shift 1; fi
if [ $# -gt 0 ]; then pass=$1; shift 1; fi 
if [ $# -gt 0 ]; then current=$1; shift 1; fi 

function dodajTabele(){
    $current/../common/info "tworzenie tabeli $1"
    cat $current/$1.sql | psql -U $user $database -p $port -h $host
}

dodajTabele kolekcja
dodajTabele odczyty
dodajTabele okres
dodajTabele prowiniencja
dodajTabele tagi
dodajTabele typ
dodajTabele wartosc_tag
dodajTabele tabliczka

$current/../common/info "tworzenie funkcji"
cat $current/funkcje.sql | psql -U $user $database -p $port -h $host


# cat $current/odczyty.sql | psql -U $user $database
# cat $current/okres.sql | psql -U $user $database
# cat $current/prowiniencja.sql | psql -U $user $database
# cat $current/tagi.sql | psql -U $user $database
# cat $current/typ.sql | psql -U $user $database
# cat $current/wartosc_tag.sql | psql -U $user $database
# cat $current/tabliczka.sql | psql -U $user $database