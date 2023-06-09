#! /usr/bin/env bash

# duplex and simplex dorado basecalling 
# samtools, dorado (GPU!) and pigz should be installed and in your path

# positional args are:
# 1 path to dorado model to use
# 2 pod5 folder
# 3 base name of output file (will be supplemented with _spx.fastq.gz and _dpx.fastq.gz)

# output is:
# file_spx.fastq.gz
# file_dpx.fastq.gz

set -e

# check # of args
if [ "$#" -ne 3 ]; then
	echo "3 arguments required:
1) path to dorado model to use
2) path to pod5s folder
3) base name of output file (will be supplemented with _spx.fastq.gz and _dpx.fastq.gz)
You have used $# arguments."
	exit 1
fi

POD5FILES=$(find ${2} -type f -name '*.pod5' | wc -l)

echo === $(date "+%Y-%m-%d %H:%M:%S") Starting dorado basecalling pipeline... ===
echo === POD5 directory is ${2} ===
echo === Found ${POD5FILES} pod5 files 

if [ $POD5FILES -le 0 ]; then
    echo === No pod5 files found...
    exit 1
fi

# make outfile names
SPXFILE=${3}-spx.fastq
DPXFILE=${3}-dpx.fastq

echo === $(date "+%Y-%m-%d %H:%M:%S") Running dorado... ===

dorado duplex ${1} ${2} | \
tee >(samtools view -h -d dx:1 - | samtools fastq > ${DPXFILE}) \
>(samtools view -h -d dx:0 - | samtools fastq > ${SPXFILE}) > /dev/null

# check for empty files and rm
[ -s ${DPXFILE} ] || rm -rf ${DPXFILE}
[ -s ${SPXFILE} ] || rm -rf ${SPXFILE}

echo === $(date "+%Y-%m-%d %H:%M:%S") Running pigz... ===
pigz ${DPXFILE}
pigz ${SPXFILE}

echo === $(date "+%Y-%m-%d %H:%M:%S") Done! ===
