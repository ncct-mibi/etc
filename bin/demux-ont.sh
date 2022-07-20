#!/usr/bin/env bash

# demux ont fastq files, using the barcodeXX in the read names
# this happens when basecalling is done without demultiplexing

# seqkit is required in your path

usage() 
{
    echo ""
    exit 2
}

if ! command -v seqkit &> /dev/null
then
    echo "seqkit could not be found but is required by this script"
    usage
fi

