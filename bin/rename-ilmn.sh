#!/bin/bash
date=$(date +'%Y-%m-%dH')
while IFS="," read -r ob nb
do
  for f in "$ob"*
  do
    echo mv -v $f "$nb"_"$f" > $date-rename.sh
  done
done < $1
