# etc
Various workflows, scripts and functions. Mostly in `R`.

## himap.R
This is a wrapper around the [HiMAP package](https://www.biorxiv.org/content/10.1101/565572v1) for 16S rDNA analysis. It processes `fastq` files to Operational Strain Units (OSU) abundance. The script is intended to be run from the command line.
Try `hymap.R -h` to see how to use it.

## Merge lane-splitted `fastq` files by name

## Merge `fastq` files from resequenced libraries

## Subset protein `fasta` file
Thus function takes a string vector of protein fasta headers and a protein fasta file and returns 
the protein sequences with matching headers. Partial or exact match is supported (partial means that the string from beginning of the line upto the next whitespace is used in the search).
