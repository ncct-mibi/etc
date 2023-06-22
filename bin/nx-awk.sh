#! /usr/bin/env bash

# pass a ONT sequencing summary file and return NX of reads (pass only)
# usage
# nx_awk.sh nx file
#


# get col index as they are not very consistent
pass=$(head -1 ${2} | sed 's/\t/\n/g' | nl | grep 'passes_filtering' | cut -f 1)
len=$(head -1 ${2} | sed 's/\t/\n/g' | nl | grep 'sequence_length_template' | cut -f 1)
#echo $pass, $len


gawk -v nx="${1}" -v a="$pass" -v b="$len" '
$a == "TRUE" {lenarray[idx++] = $b; sum+=$b}
END {n = asort(lenarray); halfsum = sum * nx;

# go backwards from large to small contigs
for (i = n; i >= 0; i--) {
    if (cumsum <= halfsum){
        cumsum+=lenarray[i]
    }
    else { 
        nxvalue = lenarray[i]
        break
    }
}
print nxvalue

}' "${2}"

