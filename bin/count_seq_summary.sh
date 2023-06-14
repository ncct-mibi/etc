#! /usr/bin/env ksh

# pass a ONT sequencing summary file and return bases and reads (pass only)
# use ksh to be able to return SI units automagically

# bases \t reads
z=$(awk '$12 ~ /TRUE/ {sum+=$16; count++} END {printf "x=%s \n y=%s", sum, count}' "${1}")
#bases=$(awk '$12 ~ /TRUE/ {sum+=$16} END {printf "%s", sum}' "${1}")
#reads=$(awk '$12 ~ /TRUE/ {count++} END {printf "%s", count}' "${1}")

# the above assigns bases and reads in awk and assigns to z, when z is evaluated x and y become shell variables
# this way only one pass is needed 
# https://www.theunixschool.com/2012/08/awk-passing-awk-variables-to-shell.html
eval $z
file=$(basename ${1})
#printf "file,reads,bases\n"
printf "$file,%#d,%#d\n" $x $y
