#!/usr/local/bin/Rscript

# script to download RefSeq (bacterial) genomes from ncbi
# use assembly_summary.txt to filter and get ftp paths to genomes of interest
# and use curl to get files
# use hints from
# https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/#allcomplete

  PKGs <- c("data.table", "dplyr", "optparse", "curl")
  
  invisible(
    lapply(PKGs, function(x) {suppressPackageStartupMessages(library(x, character.only = TRUE)) })
  )

  # options are: 
  # -s --seqsummary --> path to seqsummary file, default ~/db/seqsummary
  # -u --update --> download new seqsummary file, do not use -s, default FALSE
  # -r --repres --> logical, download representative genomes only, all otherwise, default TRUE
  # -a --assembly --> character, filter by assembly level, options: complete, chromosome, contig, scaffold
  # -d --dry --> dry run, do not download data, just list files to be downloaded
  
  option_list <- list(
    make_option(c("-s", "--seqsummary"), type = "character", default = "~/db/assembly_summary.txt", 
                help="path to downloaded assembly_summary.txt file [default = %default]"),
    make_option(c("-u", "--update"), type = "logical", default = FALSE,
                help = "download and use new seqsummary file from ncbi [default = %default]" ),
    make_option(c("-t", "--type"), type = "character", default = "fna",
                help = "type of sequence to download, possible values are 'fna', 'faa', 'gff', 'gtf', 'gbff', 'ft' [default = %default]"),
    make_option(c("-r", "--repres"), type = "logical", default = TRUE,
                help = "download only representative genomes [default = %default] "),
    make_option(c("-a", "--assembly"), type = "character", default = "complete", 
                help = "filter by assembly level, possible values are 'complete', 'chromosome', 'contig', 'scaffold', 'all' [default = %default]"),
    make_option(c("-d", "--dryrun"), type = "logical", default = FALSE,
                help = "dry run, do not download data, just list files to be downloaded [default = %default] ")
  )
  
  opt_parser <- OptionParser(description = "\nDownload refseq genomes from ncbi using a assembly_summary.txt file",
                             option_list = option_list,
                             add_help_option = TRUE,
                             usage = "usage: get_refseq_genomes.R [options] \n---------------------------------",
                             epilogue = "A. Angelov | 2020 | aangeloo@gmail.com")
  opt <- parse_args(opt_parser)
  
  # initialization variables
  seqsummary_url <- "https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt"
  seqsummary_file <- normalizePath(opt$seqsummary)
  # get timestamp of seqsummary file
  seqsummary_date <- file.info(seqsummary_file)$mtime[1] %>% as.Date() 
  cat("Using seqsummary file", seqsummary_file, "from", as.character(seqsummary_date))
  
  # 
  # function to read seqsummary in dt
  read_summary <- function(x) {
    fread(x, quote = "")
  }
  
