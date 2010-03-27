#!/bin/bash

script_folder=`echo $0 | sed -e "s/\/[^\/]*$/\//g;"`
tql_prog=$1

function do_test(){
    out=`echo $1 | cut -d. -f1`
    out=`echo $out.out`
    $tql_prog $1 | grep "<tablet " | cut -d\" -f2 | diff -wB - $out >/dev/null
    return $?    
}

errors=0

for t in `ls $script_folder*.in`; do
    if do_test $t; then
	errors=1
	echo "$t => ERROR"
    else
	echo "$t => OK"
    fi
done

exit $errors