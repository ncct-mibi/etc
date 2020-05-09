# This function takes the output of featureCounts() from the Rsubread package and
# outputs a data frame summary grouped on the gene_biotype attribute

# For it to work, featureCounts() has to be run with the GTF.attrType.extra = "gene_biotype" argument,
# and the gene_biotype has to be present in the GTF file

# Also, the bam files used have to end with "BAM" (as is the case if align() from Rsubread was used)

summarize_featureCounts <- function(x) {
  
  as.data.frame(x$counts) %>% 
    mutate(GeneID = rownames(.)) %>% #add GeneID var using the rownames
    left_join(x$annotation) %>% #join with annotations, which contain gene_biotype
    group_by(gene_biotype) %>% 
    summarise_at(vars(ends_with("BAM")), sum) %>% #row counts per gene_biotype
    rename_at(vars(ends_with("BAM")), list(~stringr::str_extract(., "\\w+"))) #%>%  #just prettify vars
    #mutate_if(is.numeric, list(percent = ~100*./sum(.) )) #add percentage vars
}