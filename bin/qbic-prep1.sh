#! /usr/bin/env sh

# script used to prep raw ONT data for transfer to qbic

# prep1 - rename barcode to qbic number using a csv
# usage - redirect output to a sh file and execute after checking everything is OK

# takes 2 args:
# 1 arg is a path to a flow cell folder, 
# 2 arg is a csv file with "," as separator

# check # of args
if [ "$#" -ne 2 ]; then
	echo "Two arguments required:
1) path to flow cell folder, which contains fastq_pass, fastq_fail, fast5_pass...
2) a ',' separated csv file with unix line endings. First column is barcode01, barcode02..., second column is target name 
You have used $# arguments."
	exit 1
fi

# loop through each fast folder and rename according to csv
fastfolders=("fast5_fail" "fast5_pass" "fastq_fail" "fastq_pass")

for f in ${fastfolders[@]}
do 

    # strip white spaces in or around variables read from the csv
    # https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
    while IFS="," read col1 col2
    do
    # check if dir exists and rename only if so 
    currentdir="$1"/$f/${col1// /}
    [ -d $currentdir ] && echo mv "$1"/$f/${col1// /} "$1"/$f/${col2// /} || echo folder ${currentdir} not found!
    done < "$2"

done

# second pass to actually rename
echo "To actually execute the above commands type [yes] and press [ENTER]. Otherwise just [ENTER]."
read confirm

if  [ "$confirm" = "yes" ]; then

	echo "Renaming..."
for f in ${fastfolders[@]}
do 

    # strip white spaces in or around variables read from the csv
    # https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
    while IFS="," read col1 col2
    do
    # check if dir exists and rename only if so 
    currentdir="$1"/$f/${col1// /}
    [ -d $currentdir ] && mv -v "$1"/$f/${col1// /} "$1"/$f/${col2// /} || echo folder ${currentdir} not found!
    done < "$2"

done

else
	echo "Nothing will be renamed, quitting."
	exit 1
fi