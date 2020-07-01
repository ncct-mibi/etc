#! /usr/bin/env sh

# script used to prep raw ONT data for transfer to qbic
# merges and then gzips all fastq files found in folders specified by pattern
# finds all the pattern folders recursively

# takes 2 args:
# 1 arg is a path to a fastq_passed or fastq_failed folder, containing barcode folders, 
# 2 arg is QBiC pattern, common to all samples

# for each barcode folder, cat all fastq files to a new barcode.fastq file, gzips and deletes original fastq

if [ "$#" -ne 2 ]; then
	echo "Two arguments required:
1) path to fastq_ folders, e.g. /path/to/fastq_pass or /path/to/fastq_fail
2) QBiC barcode pattern, common for all samples, e.g. 'QNANO*' (use single quotes)
You have used $# arguments."
	exit 1
fi

# https://unix.stackexchange.com/questions/389705/understanding-the-exec-option-of-find/389706

# using pigz for parallel gzip, much faster of course
find "$1" \
-type d \
-name "$2" \
-ls \
-execdir sh -c '
	[ -n "$(find {} -name '*.fastq')" ] && cat {}/*.fastq > {}/{}.fastq && pigz -f {}/{}.fastq
	' \
sh ";"

# explanation:
# [ -n "$(find {} -name '*fastq' | head -1)" ]
# check if fastq files are found in the directory before executing cat ...
# otherwise the new fastq file is generated even if no files there

# second pass to delete original fastq files
echo "The above directories were visited and the fastq file there were merged and gzipped.\n\
The original fastq files there will now be deleted.\n\
Type [yes] or [no]  and press [ENTER] to continue."
read confirm

if  [ "$confirm" = "no" ]; then
	echo "Nothing will be deleted, quitting."
	exit 1
elif [ "$confirm" = "yes" ]; then
	echo "Deleting..."

	find "$1" \
	-type d \
	-name "$2" \
	-exec sh -c 'rm -v {}/*.fastq' ";"
else
	echo "Type [yes] or [no] and press [ENTER]"
	exit 1
fi
