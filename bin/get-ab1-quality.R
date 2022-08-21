# read ab1 file
# output is a data table with quality stats

# usage
# purrr::map_dfr(file_list, process_ab1)

get_ab1_quality <- function(abfile) {
  require(sangeranalyseR)
  
  # used just to get parent folder of ab1 file
  get_parent_dir = function(pathStr) {
    parts = unlist(strsplit(pathStr, "/"))
    parent.dir = do.call(file.path, as.list(parts[length(parts) - 1]))
    
    if (parent.dir == "" || is_empty(parent.dir)) return("/")
    else return(parent.dir)
  }
  
  obj <- sangeranalyseR::SangerRead(readFileName = abfile, readFeature = 'Forward Read')
    if(obj@objectResults@creationResult) {
      
      # calculate bases >Q20, >Q30, >Q40 as they are not explicitly stored in the SangerRead S4 instance
      phredscores <- obj@QualityReport@qualityPhredScores
      
      # continuous read length (CRL) - The longest uninterrupted stretch of bases with a running QV average of 20 or higher
      # use rle
      rl20 <- rle(obj@QualityReport@qualityPhredScores > 20)
      #rl30 <- rle(obj@QualityReport@qualityPhredScores > 30)
      crl20 <- max(rl20$lengths[rl20$values])
      #crl30 <- max(rl30$lengths[rl30$values])
      
      
      data.frame(
        parent = get_parent_dir(normalizePath(abfile)),
        file = obj@objectResults@readResultTable$readName,
        rundate = paste0(obj@abifRawData@data$RUND.1$year, "-", obj@abifRawData@data$RUND.1$month, "-", obj@abifRawData@data$RUND.1$day),
        rawSeqLen = obj@QualityReport@rawSeqLength, 
        trimSeqLen = obj@QualityReport@trimmedSeqLength,
        trimStart = obj@QualityReport@trimmedStartPos,
        trimEnd = obj@QualityReport@trimmedFinishPos,
        rawMeanQscore = obj@QualityReport@rawMeanQualityScore,
        trimMeanQscore = obj@QualityReport@trimmedMeanQualityScore,
        remainingRatio = obj@QualityReport@remainingRatio,
        basesQ20 = sum(phredscores >= 20),
        basesQ30 = sum(phredscores >= 30),
        basesQ40 = sum(phredscores >= 40),
        crl20 = crl20
        #crl30 = crl30
        )
    } else {
      stop(obj@objectResults@errorMessage)
    }
}
