#! /usr/bin/env bash

# this is used on the GPU as a helper script that calls basecall-dorado.sh - has to be in ~/code/etc/bin/ or in path
# input is:
# path to pod5_pass, including

# output is:
# pod5_pass_dorado directory
# file-spx.fastq.gz and file-dpx.fastq.gz in pod5_pass_dorado

# logic - check if there are barcodeXX folders and loop in them, 
# if not just do basecalling
# name output according to ONT scheme - use sequencing_summary...

# assign models, GPU specific
fastmodel=/home/angeloas/bin/dorado-0.3.0-linux-x64/models/dna_r10.4.1_e8.2_400bps_fast@v4.2.0
hacmodel=/home/angeloas/bin/dorado-0.3.0-linux-x64/models/dna_r10.4.1_e8.2_400bps_hac@v4.2.0
supmodel=/home/angeloas/bin/dorado-0.3.0-linux-x64/models/dna_r10.4.1_e8.2_400bps_sup@v4.2.0

# check if output dir exist
if [ ! -d "${1}/fastq_pass_dorado" ]; 
then
	echo "made basecall_duplex directory..."
    mkdir ${1}/fastq_pass_dorado
	#exit 1
else
    exit 1
fi

if [ 0 -lt $(find  ${1} -type d -name 'barcode*' -mindepth 1 | wc -w) ] # barcoded run, go in a loop
then 
    for i in "${1}"/barcode*; 
    do  /home/angeloas/code/etc/bin/basecall-dorado.sh $supmodel output; done
else 
    echo 'non barcoded run'
fi