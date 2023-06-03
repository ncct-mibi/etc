#! /usr/bin/env bash

# duplex and simplex dorado basecalling 
# samtools, dorado (GPU!) and pigz should be installed and in your path

# positional args are:
# 1 dorado model to use, one of 'fast', 'hac' or 'sup'
# 2 pod5 folder
# 3 path to output folder

# oitput is:
# simplex_[model].fastq.gz
# duplex_[model].fastq.gz

set -e

# set latest model
MODELVERSION=v4.2.0
POD5FILES=$(find ${2} -type f -name '*.pod5' | wc -l)

echo === $(date "+%Y-%m-%d %H:%M:%S") Starting dorado basecalling pipeline... ===
echo === POD5 directory is ${2} ===
echo === Found ${POD5FILES} pod5 files 

if [ $POD5FILES -le 0 ]; then
    echo === No pod5 files found...
    exit 1
fi

# check # of args
if [ "$#" -ne 3 ]; then
	echo "3 arguments required:
1) dorado model to use, one of 'fast', 'hac' or 'sup'
2) path to pod5s folder
3) path to output folder
You have used $# arguments."
	exit 1
fi

# check if output dir exist
if [ ! -d "$3" ]; then
	echo === $(date "+%Y-%m-%d %H:%M:%S") Made output directory ${3} ===
    mkdir -p ${3}
	#exit 1
fi


MODEL=dna_r10.4.1_e8.2_400bps_${1}@${MODELVERSION}

# download model if not in output directory
if [ ! -d ${3}/${MODEL} ]; then
    echo === $(date "+%Y-%m-%d %H:%M:%S") Will attempt to download ${MODEL} ===
    dorado download \
    --model ${MODEL} \
    --directory ${3}
fi

echo === $(date "+%Y-%m-%d %H:%M:%S") Running dorado... ===

dorado duplex ${3}/${MODEL} ${2} | \
tee >(samtools view -h -d dx:1 - | samtools fastq > ${3}/duplex.fastq) \
>(samtools view -h -d dx:0 - | samtools fastq > ${3}/simplex.fastq) > /dev/null

echo === $(date "+%Y-%m-%d %H:%M:%S") Running pigz... ===
pigz ${3}/duplex.fastq
pigz ${3}/simplex.fastq

echo === $(date "+%Y-%m-%d %H:%M:%S") Done! ===
