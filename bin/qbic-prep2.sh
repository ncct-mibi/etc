#! /usr/bin/env sh

# script used to prep raw ONT data for transfer to qbic

# prep2 - merge and name the merged fastq files with the name of the parent folder --> gbic.fastq
# then gzip this fastq files --> qbic.fastq.gz
# delete original fastq files
# fast5 folders are left untouched

# takes 2 args:
# 1 arg is a path to a flow cell folder
# 2 arg is QBiC pattern, common to all samples


if [ "$#" -ne 2 ]; then
	echo "Two arguments required:
1) path to flow cell folder, which contains fastq_pass/qbic_code/blabla.fastq, fastq_fail, fast5_pass...
2) QBiC barcode pattern, common for all samples, e.g. 'QNANO*' (use single quotes)
You have used $# arguments."
	exit 1
fi

# https://unix.stackexchange.com/questions/389705/understanding-the-exec-option-of-find/389706
# fast5 folders are left untouched

find "$1" \
-type d \
-name "fastq_*/$2" \
-ls \
-execdir sh -c '
	[ -n "$(find {} -name '*.fastq')" ] && cat {}/*.fastq > {}/{}.fastq && pigz -f {}/{}.fastq
	' \
sh ';'
# explanation:
# [ -n "$(find {} -name '*fastq' | head -1)" ]
# check if fastq files are found in the directory before executing cat - otherwise the new fastq file is generated even if no files there

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
	-execdir sh -c 'rm -v {}/*.fastq' sh ';'
else
	echo "Nothing will be deleted, quitting."
	exit 1
fi