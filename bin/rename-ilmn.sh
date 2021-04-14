#!/usr/bin/env bash

# 
# usage rename-ilmn.sh < rename.csv > rename.sh
# generate rename.sh, which is then visually checked if OK and executed


#date=$(date +'%Y-%m-%d')
while IFS=";" read ob nb
do
  for f in "$ob"*
  do
    echo mv -v $f "$nb"_"$ob"
  done
done
