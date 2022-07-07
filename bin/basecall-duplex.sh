#! /usr/bin/env bash

# duplex guppy basecalling using duplex_tools to find read pairs
# duplex_tools and guppy (GPU!) should be installed and in your path

# positional args are:
# 1 run folder
# 2 sequencing summary file
# 3 name of model to use (must be visible to your guppy installation) 
# fastq_pass and fast5_pass must be there

set -e

# check # of args
if [ "$#" -ne 3 ]; then
	echo "3 arguments required:
1) path to run folder
2) path to sequencing summary file
3) guppy model to use, e.g. dna_r10.4_e8.1_sup.cfg
You have used $# arguments."
	exit 1
fi

# check if fast5_pass and fastq_pass are there
if [ ! -d "" ]; then
	echo ""
	exit 1
fi


echo "writing pair ids..."
touch "$1"/duplex_basecalls.log
date >> "$1"/duplex_basecalls.log
duplex_tools pairs_from_summary "$2" "$1"/pairs_from_summary 2>&1 | tee "$1"/duplex_basecalls.log

echo "writing filtered ids..."
duplex_tools filter_pairs "$1"/pairs_from_summary/pair_ids.txt "$1"/fastq_pass 2>&1 | tee -a "$1"/duplex_basecalls.log

echo "running duplex guppy basecaller"
guppy_basecaller_duplex \
    -r \
    -i "$1"/fast5_pass \
    -s "$1"/duplex_basecalls \
 	-x 'cuda:all' \
 	-c "$3" \
 	--duplex_pairing_mode from_pair_list \
 	--duplex_pairing_file "$1"/pairs_from_summary/pair_ids_filtered.txt 2>&1 | tee -a "$1"/duplex_basecalls.log