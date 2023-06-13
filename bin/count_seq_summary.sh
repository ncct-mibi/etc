#! /usr/bin/env ksh

# pass a ONT sequencing summary file and return bases and reads (pass only)
# use ksh to be able to return SI units magically


# bases \t reads
# awk '$12 ~ /TRUE/ {sum+=$16; count++} END {printf "%s \t %s\n", sum, count}' "${1}"
bases=$(awk '$12 ~ /TRUE/ {sum+=$16} END {printf "%s", sum}' "${1}")
reads=$(awk '$12 ~ /TRUE/ {count++} END {printf "%s", count}' "${1}")

printf "%#d\n" $bases
printf "%#d\n" $reads