# edit distance function #
# counts the number of differences between two strings of equal length
# to be used for e.g. index pool designs in Illumina seq

# INPUT
# a=string1, 
# b = string2, can be a string vector!!!

# OUTPUT - integer, edit distance (number of changes needed to get from a to b)
# if b is a string vector, a list is returned with position(minpos), edit distance (minedist) and sequence (minseq) of the most similar string in the vector

## USAGE
# edist(a, b)
# for a list of a arguments, map_df(a, edist, b) 
# or even cbind(celero, map_df(celero$index1, edist, xt$i7_bases))
###

## ADVANCED USAGE
# to check one character vector (charvec) of indices for the next closest index:
# map_df(1:length(charvec), function(x) { edist(charvec[x], charvec[-x]) })

###
edist <- function(a, b) {
  require(stringr)
  #if(!is.character(a) | !is.character(b))  stop("Both arguments must be characters!")
  #if(nchar(a) != nchar(b)) stop("The two strings have to be of the same length!")
  a <- toupper(a)
  b <- toupper(b)
  
  if(length(b) > 1) {
    
      countslist <- lapply(str_split(b, ""), str_count, unlist(str_split(a, "")))
      sumslist <- lapply(countslist, function(x) { length(x) - sum(x) } )
      #unlist(sumslist)
      return(
        list(
      qseq = a,
      minhitseq = b[which.min(unlist(sumslist))],
      minhitpos = which.min(unlist(sumslist)),
      minhitedist = min(unlist(sumslist))
        )
      )
  } else {
    countvector <- str_count(string = unlist(str_split(a, "")), pattern = unlist(str_split(b, "")))
    return(
    length(countvector) - sum(countvector)
    )
  }
  
}



