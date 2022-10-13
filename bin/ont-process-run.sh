#! /usr/bin/env sh

# cat, compress, rename fastq files from a runfolder based on csv sample-barcode sheet
# cd in the run directory to execute


# arg1 - csv file
# a ',' separated csv file with unix line endings. First column is barcode01, barcode02..., second column is target name 
#------------------------
# barcode01,sample1
# barcode02, sample2
#------------------------

mkdir processed

while IFS="," read col1 col2
do
# check if dir exists 
currentdir="fastq_pass"/${col1// /}
[ -d $currentdir ] && cat $currentdir/*.fastq.gz > processed/$col2.fastq.gz || echo folder ${currentdir} not found!
done < "$1"


