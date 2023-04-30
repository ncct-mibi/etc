#! /usr/bin/env bash

# duplex guppy basecalling using duplex_tools to find read pairs
# duplex_tools and guppy (GPU!) should be installed and in your path

# required args are:
# -r run folder - fastq_pass and fast5_pass must be there
# -s sequencing summary file
# -m name of model to use (must be visible to your guppy installation) 
# 
# optional args
# -c chunk size for 

while getopts ":r:s:m:" opt; do
  case $opt in
    r)
      echo "run folder is $OPTARG" >&2
	  runfolder=$OPTARG
      ;;
	s)
      echo "sequencing summary file is $OPTARG" >&2
	  seqsummary=$OPTARG
      ;;
	m)
      echo "model is $OPTARG" >&2
	  model=$OPTARG
      ;;
	c)
      echo "chunk size is $OPTARG" >&2
	  chunksize=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


set -e

# check # of args
# if [ "$#" -ne 3 ]; then
# 	echo "3 arguments required:
# 1) path to run folder
# 2) path to sequencing summary file
# 3) guppy model to use, e.g. dna_r10.4_e8.1_sup.cfg
# You have used $# arguments."
# 	exit 1
# fi

# check if fast5_pass and fastq_pass are there
# if [ ! -d "" ]; then
# 	echo ""
# 	exit 1
# fi


echo "Writing pair ids..."
touch "$runfolder"/duplex_basecalls.log
date >> "$runfolder"/duplex_basecalls.log
duplex_tools pairs_from_summary "$seqsummary" "$runfolder"/pairs_from_summary 2>&1 | tee "$runfolder"/duplex_basecalls.log

echo "writing filtered ids..."
duplex_tools filter_pairs "$runfolder"/pairs_from_summary/pair_ids.txt "$runfolder"/fastq_pass 2>&1 | tee -a "$runfolder"/duplex_basecalls.log

echo "running duplex guppy basecaller"
guppy_basecaller_duplex \
    -r \
    -i "$runfolder"/fast5_pass \
    -s "$runfolder"/duplex_basecalls \
 	-x 'cuda:all' \
 	-c "$model" \
 	--duplex_pairing_mode from_pair_list \
 	--duplex_pairing_file "$runfolder"/pairs_from_summary/pair_ids_filtered.txt 2>&1 | tee -a "$runfolder"/duplex_basecalls.log