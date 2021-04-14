## Merge fastq reads from resequenced libraries

# For example, sample (or library) named AA_01 was resequenced and the reseq was named AA2_01. 
# The original and the reseq files are (they will be usually in different folders):


# | old_seqs
#    | AA_01_S4_R1_001.fastq
#    | AA_01_S4_R2_001.fastq
#    | AA_02_S5_R1_001.fastq
#    | AA_02_S5_R2_00 1.fastq
# | new_seqs
#    | AA2_01_S7_R1_001.fastq
#    | AA2_01_S7_R2_001.fastq
#    | AA2_02_S8_R1_001.fastq
#    | AA2_02_S8_R2_001.fastq


# The aim is to `cat` each AA2 read into the corresponding AA read, for many samples, R1 into R1 and R2 into R2. 
# The strategy is to take one new file, locate its id and use it to find the corresponding old file. 
# Then `cat` the new into the old...
require(stringr)
require(magrittr)

mergefq_reseq <- function(newpattern, newdir, oldpattern, olddir, dryrun = TRUE) {
    
   oldfiles <- dir(path = olddir, pattern = "fastq.+", full.names = TRUE)
   newfiles <- dir(path = newdir, pattern = "fastq.+", full.names = TRUE)

   for (i in newfiles) {
      # build the pattern used to search in old files
      
      pattern <- basename(i) %>% 
         str_replace(newpattern, oldpattern) %>% 
         #str_extract("MW_[0-9]+_S[0-9]+_R[1-2]") %>%
         str_replace("_S[0-9]+_", "_S[0-9]+_")        # keep S flexible (can be any number)
      
      #cat("pattern = ", pattern, "\n")
      
      
      y <- grep(pattern = pattern, x = oldfiles, value = TRUE)
      if(length(y) == 0) { stop(paste(pattern, "not found!")) }
      
      if(isTRUE(dryrun)) { cat(i, "====>", y, "\n", sep = " ") }
      #readline(prompt = "OK?")
      
      syscom <- paste("cat", i, ">>", y, sep = " ")
      if(!isTRUE(dryrun)) {
         system(syscom)
         cat(i, "was added to", y, "\n", sep = " ")
      }
   
   }
   if(isTRUE(dryrun)) cat("Run the script with dryrun = FALSE to actually merge the sequences")
 }





