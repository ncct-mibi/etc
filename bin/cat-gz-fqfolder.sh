#! /usr/bin/env sh

# script used to prep raw ONT data for transfer to qbic
# merges and then gzips all fastq files found in fastq_passed and fastq_failed folders
# finds the fastq_passed/failed recursively

# takes 2 args:
# 1 arg is a folder containing fastq_passed and fastq_failed folders,
# 2 arg is barcode (name for the merged fastq file)
# does cat on all fastq files found there, gzips and deletes original fastq

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
		exit 1
fi

find "$1" \
-type d \
-name 'fastq_*' \
-execdir sh -c '
	cat {}/*.fastq > {}/"$1"_$(basename {}).fastq && pigz -v -f {}/"$1"_$(basename {}).fastq
	' \
sh "$2" ";"
# for the sh- c script: sh is $0 and "$2" is $1

# second pass to delete original fastq files
find "$1" \
-type f \
-name "*.fastq" \
-exec echo {} deleted ";"
