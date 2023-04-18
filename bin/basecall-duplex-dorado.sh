#! /usr/bin/env bash

# duplex guppy basecalling using duplex_tools to find read pairs
# duplex_tools, samtools and dorado (GPU!) should be installed and in your path

# positional args are:
# 1 pod5 folder
# 2 path to model to use 
# 3 name of output duplex fastq file



set -e

# check # of args
if [ "$#" -ne 3 ]; then
	echo "3 arguments required:
1) path to pod5s folder
2) path to dorado model to use
3) name of output duplex fastq file
You have used $# arguments."
	exit 1
fi

# check if output dir exist
if [ ! -d "basecall_duplex" ]; then
	echo "made basecall_duplex directory..."
    mkdir basecall_duplex
	#exit 1
fi

# recommended workflow for dorado
# 1. Simplex basecall with dorado (with --emit-moves)
# 2. Pair reads
# 3. Duplex-basecall reads

# 1

touch basecall_duplex/basecall_duplex.log
date "+%Y-%m-%d %H:%M:%S" >> basecall_duplex/basecall_duplex.log

echo "running dorado simplex basecaller..."
dorado basecaller \
    "$2" \
    "$1" | samtools view -Sh > basecall_duplex/reads.bam
    #--emit-moves > basecall_duplex/reads_with_moves.sam 2>&1 | tee -a basecall_duplex/basecall_duplex.log


# 2
echo "running duplex_tools..."
duplex_tools pair \
    --output_dir basecall_duplex/pairs_from_bam \
    basecall_duplex/reads.bam 2>&1 | tee -a basecall_duplex/basecall_duplex.log

# 3
echo "running dorado duplex basecaller..."
dorado duplex \
    "$2" \
    "$1" \
    --emit-fastq \
    --pairs basecall_duplex/pairs_from_bam/pair_ids_filtered.txt > basecall_duplex/"$3".fastq