#!/bin/bash

i=0
if [ $# -gt 0 ]; then folder=$1; else folder=1; fi
max=1000
mkdir $folder

echo "Zaczynam folderować $folder"

for plik in `ls`; do
  if cat $plik >/dev/null 2>/dev/null; then
	mv $plik $folder
	i=` echo $i+1 | bc `
	if [ $i -gt $max ]; then
		i=0
		folder=`echo $folder+1 | bc`
		mkdir $folder
	fi
  fi
done
