#!/usr/bin/env bash

# run minimap on ONT data, sort and index bam files

usage()
{
    echo "Usage: minimapper [options] <target.fa> <query.fastq>"
    exit 2
}
# options
# -p number of processors to use

# output is sample.bam (sorted bam, if sample.fastq was input)

while getopts ":p:" c; do
  case ${c} in
    p )
      processors=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))


samplename=$(basename ${2%%.*})
#echo $samplename

minimap2 -t $processors -ax map-ont $1 $2 > $samplename.sam

samtools view -S -b -@ $processors $samplename.sam | \
samtools sort -@ $processors -o $samplename.bam -

samtools index -@ $processors $samplename.bam