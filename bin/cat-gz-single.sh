#! /usr/bin/env sh

# script used to prep raw ONT data for transfer to qbic
# merges and then gzips all fastq files found in fastq_passed and fastq_failed folders 
# fast5_passed/failed are not touched
# finds all the fastq_passed/failed folders recursively

# takes 2 args:
# 1 arg is a folder containing fastq_passed and fastq_failed folders,
# 2 arg is qbic barcode (name for the merged fastq file)
# does cat on all fastq files found there, gzips and deletes original fastq

if [ "$#" -ne 2 ]; then
	echo "Two arguments required: 1) folder to search and 2) barcode. You have used $# arguments."
	exit 1
fi

# https://unix.stackexchange.com/questions/389705/understanding-the-exec-option-of-find/389706

# using pigz for parallel gzip, much faster of course
find "$1" \
-type d \
-name 'fastq_*' \
-ls \
-execdir sh -c '
	[ -n "$(find {} -name '*.fastq')" ] && cat {}/*.fastq > {}/"$1"_$(basename {}).fastq && pigz -f {}/"$1"_$(basename {}).fastq
	' \
sh "$2" ";"
# for the sh- c script: sh is $0 and "$2" is $1

# second pass to delete original fastq files
echo "The above directories were visited and the fastq file there were merged and gzipped.\n\
The original fastq files there will now be deleted.\n\
Type [yes] or [no]  and press [ENTER] to continue."
read confirm

if  [ "$confirm" == "no" ]; then
	echo "Nothing will be deleted, quitting."
	exit 1
elif [ "$confirm" == "yes" ]; then
	echo "Deleting..."

	find "$1" \
	-type d \
	-name "fastq_*" \
	-exec sh -c 'rm -v {}/*.fastq' ";"
else
	echo "Type [yes] or [no] and press [ENTER]"
	exit 1
fi
