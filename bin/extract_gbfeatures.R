## Extract CDS features from an embl or genbank file as a tibble ##

# INPUT - a single-entry embl or genbank file
# OUTPUT - a tibble with the required fields (capitalized) as in SAF files (GeneID, Chr, Start, End and Strand) plus some more
# REQUIRES - biofiles

extract_gbfeatures <- function(gbfile) {
  #require(reticulate)
  require(biofiles)
  require(tidyverse)
  #bio <- reticulate::import("Bio")
  
  mol <- biofiles::gbRecord(gbfile)
  mol <- mol["CDS"]
  #mol <- mol[-1]
  tibble(GeneID = locusTag(mol),
         Chr = biofiles::getLocus(mol), 
         Start = biofiles::start(mol),
         End = biofiles::end(mol),
         Strand = biofiles::strand(mol) %>% str_replace(pattern = "-1", "-") %>% str_replace(pattern = "1", replacement = "+"),
         gene = biofiles::geneID(mol),
         product = biofiles::product(mol))
}
