#!/bin/bash

current=.
if [ $# -gt 0 ]; then folder=$1; shift 1; else exit 1; fi 
if [ $# -gt 0 ]; then current=$1; shift 1; fi 

for fold in `ls $current/$folder`; do
  if [ -d $current/$folder/$fold -a `echo -n $fold | wc -c` -lt 3 ]; then
#     echo $fold
     for t in `ls $current/$folder/$fold`; do
	f=`./$current/../common/get_folder $t`
	if [ ! -d $current/$folder/$f ]; then
	    mkdir $current/$folder/$f
	fi
	mv $current/$folder/$fold/$t $current/$folder/$f/
# 	echo `./$current/../common/get_folder $t`
     done
  fi
#   if cat $plik >/dev/null 2>/dev/null; then
# 	mv $plik $folder
# 	i=` echo $i+1 | bc `
# 	if [ $i -gt $max ]; then
# 		i=0
# 		folder=`echo $folder+1 | bc`
# 		mkdir $folder
# 	fi
#   fi
done
