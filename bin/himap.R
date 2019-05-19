#!/usr/local/bin/Rscript
#
### A wrapper around HiMAP (Segota et al., 2019) to process fastq files to Operational Strain Units (OSU) abundance ###
# https://www.biorxiv.org/content/10.1101/565572v1
# A. Angelov, 2019 ##################################

PKGs <- c("devtools", "optparse", "data.table", "dplyr", "crayon", "stringr", "writexl") # himap and dada2 are loaded later, because slow
loadPKGs <- function(x) { suppressPackageStartupMessages(library(x, character.only = TRUE)) }
# very fancy check instelled packages function

check <- PKGs %in% installed.packages()
if(sum(check) != length(PKGs)) {
    cat(
      "Some required packages are not installed on this machine. These are:", 
      PKGs[!check],
      "and they will be installed now.", 
      sep = "\n")
  
    cat("Installing", PKGs[!check], sep = " ", "\n")
    invisible(lapply(PKGs[!check], install.packages, repos = "https://cloud.r-project.org"))
    invisible(lapply(PKGs, loadPKGs))
} else {
    cat("Loading required packages ...")
    invisible(lapply(PKGs, loadPKGs)) # himap is loaded later, because it is slow
    #devtools::install_github("taolonglab/himap")
}

### getting-setting arguments with optparse
description <- cat(
"A wrapper around HiMAP (Segota et al., 2019) to process fastq files to Operational Strain Units (OSU) abundance\n",
"Author: A. Angelov, aangeloo@gmail.com\n",
"======================================\n",
"This script executes the following modules:\n",
"01 - merge forward and reverse reads\n",
"02 - remove primer sequences\n",
"03 - fixed-length trimming (the length is determined so that 99% of the reads are longer than this length)\n",
"04 - denoising (DADA2) of the trimmed sequences\n",
"05 - OSU abundance table\n",
"06 - OSU taxonomy table\n",
"Note that if the output for a certain step already exists it will be skipped (with a warning).\n",
"If you want to re-execute a certain step, delete the corresponding output.\n",
"To make a clean re-run of the whole pipeline, delete the output folder (or specify a different output folder using the -o argument).\n",
"======================================\n",
sep = "")

option_list <- list(
  make_option(c("-f", "--fqfolder"), type = "character", default = "fastq", 
              help="folder with fastq files (relative to current directory) [default = %default]"),
  make_option(c("-o", "--outdir"), type="character", default="himap_output", 
              help="output folder [default= %default]"),
  make_option(c("-s", "--sep"), type="character", default = "_", 
              help = "sample id separator, e.g. in 'samplename_R1_001.fastq' it is '_' [default = %default]"),
  make_option(c("-r", "--region"), type="character", default = "V3-V4", 
              help = "hypervariable region, used in 'remove_pcr_primers' and 'blast' [default = %default]"),
  make_option(c("-k", "--keep"), type = "logical", default = TRUE,
              help = "keep intermediary fastq files? [default = %default]")
  # make_option(c("-p", "--plot"), type = "logical", default = FALSE, 
  #             help = "produce some plots? [default = %default]")
) 

opt_parser <- OptionParser(option_list=option_list, 
                           description = description, usage = "usage: himap.R [options]",
                           epilogue = "A. Angelov | 2019 | aangeloo@gmail.com")
opt <- parse_args(opt_parser)

# setting args
fastq_path <- file.path(getwd(), opt$fqfolder)
outdir <- file.path(getwd(), opt$outdir)
################################################
# crayon messages helper functions (f as list)
mess <- list(
  ok = function(x) {cat(crayon::bgGreen(x), sep = "\n")},
  w = function(x) {cat(crayon::bgYellow(x), sep = "\n")},
  err = function(x) {cat(crayon::bgRed(crayon::white(x)), sep = "\n")},
  bold = function(x) {cat(crayon::bold(x), sep = "\n")}
)

################################################

# startup messages
mess$ok("Starting himap, your working directory is:")
cat(getwd(), "\n")

cat("========================================\n",
    "The following arguments will be used:\n",
    "========================================\n",
    "fastq folder: ", crayon::bold(opt$fqfolder), "\n",
    "output folder: ", crayon::bold(opt$outdir), "\n",
    "sampleid separator: ", crayon::bold(opt$sep), "\n",
    "sequenced region: ", crayon::bold(opt$region), "\n", sep = ""
    )

if(!dir.exists(outdir)) {
  mess$ok("Output directory created.")
  dir.create(outdir)
} else {
  mess$w("Output directory already exists and some steps will be skipped")
}
#
# check if dada2 and himap are installed and load #################################
if(!"dada2" %in% installed.packages()) {
  cat("The required package dada2 not installed, will attempt to install it...\n")
  devtools::install_github('benjjneb/dada2')
} else {
  suppressPackageStartupMessages(library(dada2)) #required to be loaded? himap loading should suffice
} 

if(!"himap" %in% installed.packages()) {
  cat("The required package himap not installed, will attempt to install it...\n")
  devtools::install_github('taolonglab/himap', INSTALL_opts = "--no-staged-install") # resolves an issue after updating R to 3.6.0
} else {
  suppressPackageStartupMessages(library(himap))
} 

####################################################################################

ncpu <- himap_option("ncpu")
cat(crayon::bold(ncpu), "CPUs were detected and will be used to the max", "\n")

#########################################################################################
# read fastq files and get sample ids
fq_fwd <- read_files(fastq_path, 'R1')
if(length(fq_fwd) < 1) {
  mess$w("No fastq files found. Did you correctly specify the folder with the fastq files?")
  mess$err("Exiting...")
  stop("No fastq files found")
} else {
  mess$bold("The following R1 files were found:") 
  cat(fq_fwd, sep = "\n")
}

fq_rev <- read_files(fastq_path, 'R2')
if(length(fq_fwd) < 1) {
  cat(crayon::bgYellow("No fastq files found. Did you correctly specify the folder with the fastq files?"), "Exiting...", sep = "\n")
  stop("No fastq files found")
} else {
  mess$bold("The following R2 files were found:") 
  cat(fq_rev, sep = "\n")
}

sample_ids <- sampleids_from_filenames(fq_fwd, separator = opt$sep) ###################TODO check if unique
mess$bold("The following sample names were found:")
cat(sample_ids, sep = "\n")
########################################################################################

### 01_merge reads
mess$ok("Starting merge of forward and reverse reads...")
fq_mer_dir <- file.path(outdir, '01_merged')
fq_mer <- file.path(fq_mer_dir, paste0(sample_ids, '.fastq'))

if(!dir.exists(fq_mer_dir)) {
  mergestats <- merge_pairs(fq_fwd, fq_rev, fq_mer, verbose=TRUE, timing = TRUE)
  mergestatsdf <- data.frame(sample_ids, 
                             total = as.numeric(mergestats[1, ]), 
                             low_pct_sim = as.numeric(mergestats[2, ]), 
                             low_aln_len = as.numeric(mergestats[3, ]))
  
  write.csv(mergestatsdf, file = file.path(outdir, "01_mergestats.csv"))
} else {
  mess$w("Merged fastq files already present...skipping merge")
}

mess$ok("Merge finished OK!")
cat("======================\n")

# stop()
### 02_trim PCR primers
mess$ok("Starting PCR primers trimming...")
fq_pcr_dir <- file.path(outdir, '02_primer_removed')
fq_pcr <- file.path(fq_pcr_dir, paste0(sample_ids, '.fastq'))

if(!dir.exists(fq_pcr_dir)) {
  trimstats <- remove_pcr_primers(fq_mer, fq_pcr, region = opt$region, verbose = TRUE, timing = TRUE)
  trimstatsdf <- data.frame(sample_ids, 
                          total = as.numeric(mergestats[1, ]), 
                          fwd_trim = as.numeric(trimstats[1,]), 
                          rev_trim = as.numeric(trimstats[2,]))
  write.csv(trimstatsdf, file = file.path(outdir, "02_primer_trimstats.csv"))
} else {
  mess$w("Trimmed fastq files already present...skipping trim")
  
}
mess$ok("Trim finished OK!")
cat("======================\n")

### 03_fixed-length trimming
mess$ok("Starting fixed length trimming...")
fq_tri_dir <- file.path(outdir, '03_fixed_length_trimming')
fq_tri <- file.path(fq_tri_dir, paste0(sample_ids, '.fastq'))

seqlen.ft <- sequence_length_table(fq_pcr)
# plot and save the plot
 pdf(file = file.path(outdir, "03_seqlen-ft-plot.pdf"), width = 7, height = 4)
 plot(seqlen.ft)
 dev.off()
 cat("A plot with the length distributions was saved to '03_seqlen-ft-plot.pdf'\n")
#
trimlen <- ftquantile(seqlen.ft, prob = 0.01)
cat(crayon::bold(trimlen), "bp will be used for fixed-length trimming, check the plot if this is OK.\n")

filtstats <- filter_and_trim(fq_pcr, fq_tri, truncLen=trimlen, verbose=T)
mess$ok("Fixed-length trimming finished OK!")
cat("======================\n")

### 04_denoise (DADA2)
mess$ok("Starting denoising (DADA2)...")
if(!file.exists(file.path(outdir, '04_denoise.rds'))) {
  dada_result <- dada_denoise(fq_tri, fq_pcr, verbose = TRUE, timing = TRUE)
  saveRDS(dada_result, file = file.path(outdir, "04_denoise.rds"))
} else {
  dada_result <- readRDS(file = file.path(outdir, "04_denoise.rds"))
  mess$w("Denoise file already present...skipping DADA denoise")
}
mess$ok("DADA denoise finished OK!")
cat("======================\n")

### 05_sequence abundance table + remove bimeric sequences
mess$ok("Starting sequence abundance table...")
ab.dt <- sequence_abundance(dada_result)
ab.dt.nobim <- sequence_abundance(dada_result, remove_bimeras = FALSE)
bimeras_by_unique <- (max(ab.dt.nobim$qseqid) - max(ab.dt$qseqid)) / max(ab.dt.nobim$qseqid) * 100
bimeras_by_abundance <- (ab.dt.nobim[,sum(raw_count)]-ab.dt[,sum(raw_count)])/ab.dt[,sum(raw_count)] * 100
cat(crayon::bold(round(bimeras_by_unique, digits = 2)), "% of the unique sequences are bimeras\n", sep = "")
cat(crayon::bold(round(bimeras_by_abundance, digits = 2)), "% of the total number of sequences are bimeras\n", sep = "")

write.csv(ab.dt, file = file.path(outdir, "05_abundance_table.csv"))
mess$ok("Sequence abundace table + remove chimeras finished OK!")
cat("======================\n")

### 06_blast + calculate OSU abundance + add taxonomy

mess$ok("Starting BLAST, OSU table generation and taxonomy...")

if(!file.exists(file.path(outdir, "06_blast_result.rds"))) {
  blast_output <- blast(ab.dt, region = opt$region, verbose = TRUE)
  saveRDS(blast_output, file = file.path(outdir, "06_blast_result.rds"))
} else {
  blast_output <- readRDS(file.path(outdir, "06_blast_result.rds"))
  mess$w("Blast output already present...skipping")
}
  
 ################ TODO skip if exists
osu_ab.dt <- abundance(abundance_table = ab.dt, blast_object = blast_output, verbose = TRUE)
osu_tax.dt <- taxonomy(osu_ab.dt, verbose = TRUE)
# The numbers in brackets show the number of strains belonging to the specific taxonomic rank.
osu_seq.dt <- osu_sequences(osu_ab.dt, blast_output)

write_table(osu_ab.dt, file.path(outdir, "06_osu_abundance_table.txt"))
write_table(osu_tax.dt, file.path(outdir, "06_osu_taxonomy_table.txt"))
write_table(osu_seq.dt, file.path(outdir, "06_osu_sequence_table.txt"))

mess$w("Generating custom OSU abundance table with taxonomy, will write it also to excel file...")
osu_tax.dt <- osu_tax.dt %>% mutate_if(is.character, stringr::str_replace, "_.+", "")
osu_custom <- osu_ab.dt %>% left_join(osu_tax.dt, by = "osu_id")

write_table(osu_custom, file.path(outdir, "06_osu_custom_table.txt"))
writexl::write_xlsx(osu_custom, path = file.path(outdir, "06_osu_custom_table.xlsx"))
mess$ok("BLAST, OSU table generation and taxonomy finished OK!")
cat("======================\n")

#############################################
# here remove dir if opts$k is false 
if(!isTRUE(opt$k)) {
  mess$w("Deleting intermediate fastq files ...")
  unlink(fq_mer_dir, recursive = TRUE)
  cat(fq_mer, sep = "\n")
  mess$w("...deleted.")
  unlink(fq_pcr_dir, recursive = TRUE)
  cat(fq_pcr, sep = "\n")
  mess$w("...deleted.")
  unlink(fq_tri_dir, recursive = TRUE)
  cat(fq_tri, sep = "\n")
  mess$w("...deleted.")
}
#############################################


#######################################################################
#cat("=============================================\n")
mess$ok(c("himap finished successfully!", "Cheers!"))
########################################################################


