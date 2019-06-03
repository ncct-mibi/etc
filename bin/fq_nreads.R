# get number of reads from fastq files
library(Biostrings)
library(tibble)

fq_nreads <- function(x) {tibble(read = x, nreads = Biostrings::fastq.geometry(x)[1])}

# usage
#map_dfr(files, fqnreads)

# or, to use all cores with furrr
# plan(multiprocess)
# future_map2_dfr(files[1:4], fq_nreads, .progress = TRUE)