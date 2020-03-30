#!/usr/local/bin/Rscript

# script to download RefSeq (bacterial) genomes from ncbi
# use assembly_summary.txt to filter and get ftp paths to genomes of interest
# and rsync in system calls to download
# use hints from
# https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/

  PKGs <- c("data.table", "dplyr", "purrr","optparse", "curl", "stringr")
  
  # rsync is required for this script to run!
  # just a check here for rsync
  rsync_installed <- system("rsync --version", ignore.stdout = TRUE) == 0
  if(!rsync_installed) {
    stop("rsync is needed to run this script, and it was not found on your system!")
  }
  
  invisible(
    lapply(PKGs, function(x) {suppressPackageStartupMessages(library(x, character.only = TRUE)) })
  )

  # options are: 
  # -s --seqsummary --> path to seqsummary file, default ~/db/seqsummary
  # -u --update --> download new seqsummary file, do not use -s, default FALSE
  # -r --repres --> logical, download representative genomes only, all otherwise, default TRUE
  # -a --assembly --> character, filter by assembly level, options: complete, chromosome, contig, scaffold
  # -d --dry --> dry run, do not download data, just list files to be downloaded
  # -k --keep --> keep original files, gunzip otherwise
  
  option_list <- list(
    make_option(c("-s", "--seqsummary"), type = "character", default = "~/db/assembly_summary.txt", 
                help="path to downloaded assembly_summary.txt file [default = %default]"),
    make_option(c("-u", "--update"), type = "logical", default = FALSE, 
                action = "store_true", # if '-u' is seen, set to TRUE
                help = "download and use new seqsummary file from ncbi [default = %default]" ),
    make_option(c("-t", "--type"), type = "character", default = "fna",
                help = "type of sequence to download, possible values are 'fna', 'faa', 'gff', 'gtf', 'gbff', 'ft' [default = %default]"),
    make_option(c("-r", "--repres"), type = "logical", default = FALSE,
                action = "store_true",
                help = "download only representative genomes [default = %default] "),
    make_option(c("-c", "--complete"), type = "logical", default = FALSE,
                action = "store_true",
                help = "download only complete genomes [default = %default]"),
    make_option(c("-d", "--download"), type = "logical", default = FALSE,
                action = "store_true",
                help = "by default, the script does not download data, 
                use this option to ACTUALLY DOWNLOAD - might take a while! [default = %default] "),
    make_option(c("-k", "--keep"), type = "logical", default = FALSE, 
                action = "store_true", 
                help = "keep original (.gz) files, by default they are unzipped [default = %default]")
  )
  
  opt_parser <- OptionParser(
    description = "\n Download refseq genomes from ncbi using a assembly_summary.txt file\n
 EXAMPLE to download representative complete genomes:\n
 get_refseq_genomes.R -u -r -c -d\n",
    option_list = option_list,
    add_help_option = TRUE,
    usage = "usage: get_refseq_genomes.R [options] \n---------------------------------",
    epilogue = "A. Angelov | 2020 | aangeloo@gmail.com")
  opt <- parse_args(opt_parser, )
  
  # initialization variables
  seqsummary_url <- "https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt"
  
  # handle seqsummary file
  if( opt$update ) {
    
    # download seqsummary and store in local
    summary_file <- file.path(getwd(), "assembly_summary.txt")
    cat("Downloading assembly_summary.txt, please wait...\n")
    download.file(seqsummary_url, destfile = summary_file)
    cat("assembly_summary.txt downloaded and stored in", summary_file, "\n")
    
  } else if ( file.exists(opt$seqsummary) ) {
    summary_file <- normalizePath(opt$seqsummary)
    
  } else {
    stop("No assembly_summary.txt file present, consider using '-u' to download a new one!")
  }
    
  # get timestamp of seqsummary file
  seqsummary_date <- file.info(summary_file)$mtime[1] %>% as.Date() 
  cat("Using seqsummary file", summary_file, "from", as.character(seqsummary_date), "\n")
  
  # 
  # read seqsummary in df, apply filters according to opts
  # using purrr::when() here for integrating ifelse in pipes
  read_summary <- function(x, repr, compl) {
    fread(x, quote = "") %>% 
      purrr::when( repr ~ filter(., refseq_category == "representative genome"), ~ .) %>%
      purrr::when( compl ~ filter(., assembly_level == "Complete Genome"), ~ .)
  }
  
  df <- read_summary(summary_file, opt$repres, opt$complete)
  
  # generate complete ftp urls
  
  download_urls <- file.path(
    df$ftp_path, paste(basename(df$ftp_path),
    case_when(opt$type == "fna" ~ "_genomic.fna.gz",
              opt$type == "faa" ~ "_protein.faa.gz",
              opt$type == "gff" ~ "_genomic.gff.gz",
              opt$type == "gtf" ~ "_genomic.gtf.gz",
              opt$type == "gbff" ~ "_genomic.gbff.gz",
              opt$type == "ft" ~ "_feature_table.txt.gz"), sep = "")
              )
  n_files <- length(download_urls)
  
  # download data (or not)----
  # build rsync command, change protocol
  download_urls <- str_replace(download_urls, "^ftp", "rsync")
  
  rsync <- function(x, unzip) {
    # checks if file exists due to previous attempts
    system2("rsync", args = c("--progress", "--times", "--human-readable",  
                              "--update", x, "downloads/"))
    
    if(!unzip)                                                          # opt$keep is false by default
      system2("gunzip", args = file.path("downloads", basename(x)) )
    }
  
  if(opt$download) {
    cat("Startind download of", n_files, "files\n")
    invisible(
      lapply(download_urls[1:10], rsync, unzip = opt$keep) # opt$keep is false by default
    )
    cat("download of", n_files, "files finished, the files are in the downloads/ directory")
    #rsync(filelist)
  
  } else {
    cat(paste(download_urls, "\n", sep = ""))
    cat(n_files, "files found\n")
    cat("these will be downloaded if you use the '-d' option\n")
  }
  
  
    
