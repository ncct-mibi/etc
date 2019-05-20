# Merge lane-splitted fastq files
# using system cat
require(stringr)

mergefq_name <- function(fqdir = getwd(), pattern, dryrun = TRUE) {
  ffiles <- dir(path = fqdir, recursive = TRUE, pattern = "fastq+", full.names = TRUE)
  samples <- unique(stringr::str_extract(basename(ffiles), pattern = pattern))
  cat(length(samples), "samples and", length(ffiles),"fastq files were found", "\n")
  
  # inner function doing the cat for each sample
  # get all files belonging to one sample
  innerfunc <- function(y) {
    xfiles <- grep(pattern = paste0(y, "_"), x = ffiles, fixed = TRUE, value = TRUE)
    cat("These are the files for sample", y, "\n", sep = " ")
    cat(basename(xfiles), sep = "\n")
    
    #readline("Does it look good?")
    
    # make one file for R1 and one for R2
    forwreads <- grep(pattern = "_R1_", xfiles, value = TRUE)
    revreads <- grep(pattern = "_R2_", xfiles, value = TRUE)
  
    for (i in forwreads) {
      command <- paste("cat", i, ">>", paste(paste(y, "R1", sep = "_"), ".fastq.gz", sep = ""))
      if(!isTRUE(dryrun)) { system(command) }
    }
    
    for (i in revreads) {
     command <- paste("cat", i, ">>", paste(paste(y, "R2", sep = "_"), ".fastq.gz", sep = ""))
     if(!isTRUE(dryrun)) { system(command) }
     }
  }
  
# do the actual work
  
  invisible(lapply(samples, innerfunc))
  if(isTRUE(dryrun)) {
  cat("To actually execute the merge, run this function with dryrun = FALSE")
  }
# 
}
  
  