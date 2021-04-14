# GC content window function
# TODO: use seqkit and seqtk !! much faster ##############################

gc_window <- function(inputseq, windowsize, stepsize) {
  
  require(seqinr)

  fas <- seqinr::read.fasta(inputseq)
  fas <- fas[[1]]
  
  windowsize2 <- floor(windowsize/2)  
  totalGC <- seqinr::GC(fas)
  starts <- seq(1, length(fas)-stepsize, by = stepsize)
  ends <- seq(stepsize, length(fas), by = stepsize)
  n <- length(starts)    # Find the length of the vector "starts"
  chunkGCs <- numeric(n) # Make a vector of the same length as vector "starts", but just containing zeroes
  for (i in 1:n) {
    #ifelse to deal with beginning
    ifelse((starts[i] - windowsize2) <= 0,
           chunk <- fas[starts[i]:(starts[i] + windowsize2)],
           chunk <- fas[(starts[i] - windowsize2):(starts[i] + windowsize2)]
    )
    chunk <- chunk[!is.na(chunk)] # required to avoid NAs at the end
    
    chunkGC <- seqinr::GC(chunk)
    #print(chunkGC)
    chunkGCs[i] <- chunkGC
  }
  return(data.frame(start = starts, 
                    ends = ends,
                    gc = chunkGCs, 
                    diff_from_av = chunkGCs - totalGC))
  
}
