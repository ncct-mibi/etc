### SUBSET PROTEIN MULTIFASTA BY NAME ### 

# Thus function takes a string vector of protein fasta headers and a protein multifasta file and returns 
# the protein entries with matching headers
# fuzzy or exact match is suported, 
# @argument exact = TRUE
require(Biostrings)
require(stringr)

subset_proteins <- function(headers, faa, exact = TRUE)
  {
    if(!file.exists(faa)) 
      {
      return("No fasta file found with this name in the current directory!")
    }
    
    fasta <- Biostrings::readAAStringSet(faa)
    if(isTRUE(exact)) {  
    
        fasta[names(fasta) %in% headers]
    
    } else {
    
      # grepl-based match of fasta headers, takes the string from beginning of line upto the next whitespace character
      mystrings <- str_extract(headers, "^\\S*")
      fasta[str_detect(names(fasta), mystrings)]
      
      }
  }
