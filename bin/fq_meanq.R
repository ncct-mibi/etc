# read a fastq and return a dataframe with name, length and mean qscore per read
# the mean qscore is calculated by first converting phred to probabilities, taking the mean, and then back to phred
# e.g. geometric mean
# TODO: implement BiocParallel
# or just use
# data.frame(name = system2(command = "seqkit", args =  c("seq", "-i", "-n", "fastq-benchmark/sample5.fastq"), stdout = TRUE))

fq_meanq <- function(fqfile) {
  if (!require("ShortRead")) { stop("Please install the ShortRead library first...") }
  if (!require("stringr")) { stop("Please install the stringr library first...") }
  
    meanq <- function(x) { -10*log10(mean(10^(-x/10))) }
    
    fq <- readFastq(fqfile)
    pb1 <- txtProgressBar(style = 3, max = length(fq), char = "i")
    pb2 <- txtProgressBar(style = 3, max = length(fq), char = "q")
    
    return(data.frame(
      read_name = sapply(1:length(fq), function(x) { setTxtProgressBar(pb1, x); 
                                                     str_extract(as(ShortRead::id(fq)[x], "character"), "^([\\S]+)") }),
      read_length = width(fq),
      read_meanq = sapply(1:length(fq), function(x) { setTxtProgressBar(pb2, x); 
                                                      meanq(as(Biostrings::quality(fq)[x], "numeric")) } )
          )
    )
    close(pb)
}


