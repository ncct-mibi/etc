#! /usr/bin/env bash

# cat, compress, rename fastq files from a fastq_pass based on csv sample-barcode sheet
# runs faster (required dependency) to generate summary data

# arg1 - csv file
# a ',' separated csv file with unix line endings. Columns are sample and barcode, in any order
#------------------------
# sample1, barcode01
# sample2, barcode02
#------------------------

# arg2 - path to fastq_pass

# checks
if [[ $# -ne 2 ]]; then
    echo "Two parameters needed: path/to/csv and path/to/fastq_pass" >&2
    exit 2
fi

if [[ ! -f ${1} ]] || [[ ! -d ${2} ]]; then
    echo "File ${1} or ${2} does not exist" >&2
    exit 2
fi

[ -d processed ] && \
echo "Results folder exists, will be deleted ..." && \
rm -rf processed
mkdir -p processed/fastq

# get col indexes
samplename_idx=$(head -1 ${1} | sed 's/,/\n/g' | nl | grep -E 'S|sample' | cut -f 1)
barcode_idx=$(head -1 ${1} | sed 's/,/\n/g' | nl | grep -E 'B|barcode' | cut -f 1)

# check samplesheet is valid
num='[0-9]+'
if  [[ ! $samplename_idx =~ $num ]] || [[ ! $barcode_idx =~ $num ]]; then
    echo "Samplesheet is not valid, check that columns 'sample' and 'barcode' exist" >&2
    exit 2
fi

counter=0
while IFS="," read line; do
    samplename=$(echo $line | cut -f $samplename_idx -d,)
    barcode=$(echo $line | cut -f $barcode_idx -d,)
    currentdir=${2}/${barcode// /}
    ((counter++)) # counter to add to sample name
    prefix=$(printf "%02d" $counter) # prepend zero
    # skip if barcode is NA or is not a valid barcode name. Also skip if there is no user or sample name specified
    if [[ $barcode != barcode[0-9][0-9] ]] || [[ $samplename == 'NA' ]]; then
        echo "skipping $line"
        continue
    fi
    
    # check if dir exists and has files and cat
    [ -d $currentdir ] && 
    [ "$(ls -A $currentdir)" ] && 
    echo "merging ${samplename}-${barcode}" && 
    cat $currentdir/*.fastq.gz > processed/fastq/${prefix}_${samplename}.fastq.gz ||
    echo folder ${currentdir} not found or empty!
done < "$1"

# get fastq stats for the merged files

nsamples=$(ls -A processed/fastq/*.fastq.gz | wc -l)
[ "$(ls -A processed/fastq/*.fastq.gz)" ] && 
echo "Running faster on $nsamples samples ..." && 
echo -e "file\treads\tbases\tn_bases\tmin_len\tmax_len\tmean_len\tQ1\tQ2\tQ3\tN50\tQ20_percent\tQ30_percent" > processed/fastq-stats.tsv &&
parallel -k faster -ts ::: processed/fastq/*.fastq.gz >> processed/fastq-stats.tsv || 
echo "No fastq files found"
