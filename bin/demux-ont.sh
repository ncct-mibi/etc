#!/usr/bin/env bash

# demux ont fastq files, using the barcodeXX in the read names
# when re-basecalling multiplexed runs all fastq end up in one file
# this script takes the sequencing summary.txt and the fastq and outputs fastq per barcode (found 'barcode' keyword in the sequencing_summary.txt)
# seqkit and faster are required in your path

usage() 
{
    echo "demux-ont.sh <barcode_name> <sequencing_summary.txt> <fastq_file>"
    exit 2
}

if ! command -v seqkit &> /dev/null
then
    echo "seqkit could not be found but is required by this script"
    usage
fi

temp_file=$(mktemp) 

grep $1 $2 | cut -f2 > temp_file
seqkit grep --quiet -f temp_file $3 > $1.fastq
numreads=$(seqkit stats -T $1.fastq | tail -n 1 | cut -f4)

rm temp_file

echo "found $numreads reads for $1"

# usage in fish for barcode01...
# for i in (string sub -s -2 -- barcode0(seq 1 24)); echo barcode$i; end