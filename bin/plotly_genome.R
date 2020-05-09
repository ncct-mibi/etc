#### plotly genome browser ####
#### takes an embl file and number of CDS per line as input ####
#### returns a plotly object ####

plotly_genome <- function(emblfile, cdsperline = 50, from = NULL, to = NULL) {
  require(plotly)
  require(biofiles)
  require(tidyverse)
###################################################################################
### MAIN PLOTTING FUNCTION
###################################################################################
  makePlots <- function(z) {
    # To ensure a particular data value gets mapped to particular color, 
    # provide a character vector of color codes, 
    # and match the names attribute accordingly
    pal <- c("#2c7bb6", "#d7191c", "grey10")
    pal <- setNames(pal, c("+", "-", "tRNA"))
    
    plot_ly(z) %>% 
      # FORWARD SEGMENT
            add_segments(x = ~ start, xend = ~ end, 
                   #data = df_for,
                   y = "", yend = "",
                   opacity = 0.6,
                   color = ~strand,
                   colors = pal,
                   size = I(14), 
                   hoverinfo = "text", 
                   text =  ~paste("<b>", locus_tag, "</b>", "<br><i>", gene, "</i><br>", product))
      
    }
####################################################################################
  
  embl <- gbRecord(emblfile)
  embl <- embl[-1]
  
  if(is.null(from)) { from <- min(start(embl)) }
  if(is.null(to)) { to <- max(end(embl)) }
  if(from >= to) {stop("from..to not OK!")}
  
  embl <- biofiles::filter(embl, range = paste0(from, "..", to), key = c("CDS", "tRNA", "tmRNA"))
  # make the df from embl
  df <- tibble(start = start(embl), 
               end = end(embl), 
               strand = strand(embl), 
               key = biofiles::key(embl), 
               locus_tag = locusTag(embl), 
               gene = geneID(embl), 
               product = product(embl))
  df <- df %>% mutate(strand = if_else(strand == 1, "+", "-"),
                      strand = if_else(key == "tRNA", "tRNA", strand),
                      gene = if_else(is.na(gene), "", gene))
  
  # split df into n junks with this number of CDS per junk
  df.split <- split(df, ceiling(seq_along(df$start)/cdsperline))
  
  plotList <- lapply(df.split, makePlots)
  subplot(plotList, nrows = length(df.split), 
          shareY = FALSE, 
          shareX = FALSE,
          titleY = FALSE,
          margin = c(0, 0, 0, 0)) %>%
  layout(showlegend = FALSE, autosize = TRUE)
  
}
