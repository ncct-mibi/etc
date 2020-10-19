# Various workflows, scripts and functions

*aangeloo@gmail.com*

***

## himap.R

**Rscript**: `bin/himap.R`   
This is a wrapper around the [HiMAP package](https://www.biorxiv.org/content/10.1101/565572v1) for 16S rDNA analysis. It processes `fastq` files to Operational Strain Units (OSU) abundance. The script is intended to be run from the command line. Try `himap.R -h` for help.   

**Usage:**   
Download the `himap.R` file and put it in your `$PATH` (e.g. `$HOME/bin`). For example in a terminal:   

```{r}
wget https://raw.githubusercontent.com/angelovangel/etc/master/bin/himap.R
mv himap.R $HOME/bin
chmod a+x $HOME/bin/himap.R
```

After that, the script can be run directly from terminal (but adjust the shebang to your system). Try `himap.R --help` as a start, it will give you an idea of what you need to run it. The script will also attempt to install the required `R` packages, if missing.

***

## Merge lane-splitted `fastq` files

**Function:** `bin/mergefq_name.R`   

**Required:** `stringr`   
Sometimes you get `fastq` files which are split by lane, that is, the sequences from one sample are split in several different directories and files. This is the default behaviour of Basespace, or if the `bcl2fastq` was executed without the `--no-lane-splitting` option. The file structure in such cases might look like this:

```
├── 201903MW-125089967
│   └── FASTQ_Generation_2019-04-26_21_28_46Z-176397177
│       ├── MW2_100_L001-ds.a02e85d3e8f84a8ba6ef8909ea3fec30
│       │   ├── MW2-100_S4_L001_R1_001.fastq.gz
│       │   └── MW2-100_S4_L001_R2_001.fastq.gz
│       ├── MW2_100_L002-ds.3f91c8aa99f44b159d621bdbaecd5611
│       │   ├── MW2-100_S4_L002_R1_001.fastq.gz
│       │   └── MW2-100_S4_L002_R2_001.fastq.gz
...
```

This function merges the `fastq` files belonging to one sample, keeping the forward and reverse reads separate.

**Usage:**   
Source the file and use the function in an `R` session. The `mergefq_name()` function takes these arguments:   

- `fqdir` - where to start looking for `fastq` files (the search is recursive). Default is the current directory.     
- `pattern` - regex pattern matching the sampleID part of the file.    
- `dryrun` - logical, whether to actually do the merge. Default is `FALSE`      

```{r}
devtools::source_url("https://raw.githubusercontent.com/angelovangel/etc/master/bin/mergefq_name.R") 
mergefq_name(pattern = "sampleID_regex_pattern")
```

***

## Merge re-sequenced Illumina libraries

**Function:** `bin/mergefq_reseq.R`       

**Required:**  `stringr` `magrittr`   

For example, sample (or library) named AA_01 was resequenced and the reseq was named AA2_01.   
The original and the reseq files are (they will be usually in different folders):   

```
 | old_seqs
    | AA_01_S4_R1_001.fastq
    | AA_01_S4_R2_001.fastq
    | AA_02_S5_R1_001.fastq
    | AA_02_S5_R2_00 1.fastq
 | new_seqs
    | AA2_01_S7_R1_001.fastq
    | AA2_01_S7_R2_001.fastq
    | AA2_02_S8_R1_001.fastq
    | AA2_02_S8_R2_001.fastq
```

**Usage:**   

***

## Download bacterial genomes from NCBI

**Rscript:** `bin/get_refseq_genomes.R`   

**Required:** `data.table`, `dplyr`, `purrr`, `optparse`, `stringr`   
This R script downloads bacterial genomes from ncbi, using an assembly_summary.txt to filter and get ftp paths to genomes of interest. System calls to rsync are used, so `rsync` has to be available on the system.   

**Usage:**
In a terminal, do `bin/get_refseq_genomes.R -h` to get an idea how to use it. For example, to download all representative and complete genomes, using a fresh assembly_summary.txt from ncbi : 

```
get_refseq_genomes.R -urcd
```

The script supports filtering by taxid, i.e. `get_refseq_genomes.R -u -d -t 1423` will download all *Bacillus subtilis* genomes. A great program for working with taxonomy data (and to get all taxids for a certain phylogenetic rank) is [taxonkit](https://github.com/shenwei356/taxonkit).


***

## Find the edit distance in two sets of sequences

**Function:** `bin/edist.R`   
Function to count the number of differences between two strings of equal length, to be used for e.g. 
index pool designs in Illumina seq

**Required:** `stringr`

**Usage:**   
*INPUT*   
`a = string1, b = string2`, string2 can be a string vector!!!

*OUTPUT*   
integer, edit distance (number of changes needed to get from a to b). If b is a string vector, a list is returned with position(minpos), edit distance (minedist) and sequence (minseq) of the most similar string in the vector

```
# for a single a vector, b can be a list:
edist(a, b)

# for a list of a arguments:
map_df(a, edist, b) 

# or even 
cbind(celero, map_df(celero$index1, edist, xt$i7_bases))
```

**Advanced usage:**   
To check one character vector (charvec) of indices for the next closest index:

```
map_df(1:length(charvec), function(x) { edist(charvec[x], charvec[-x]) })
```

***

## Subset protein `fasta` file

**Function:** `bin/subset_proteins.R`   
This `R` function takes a string vector of protein fasta headers and a protein fasta file and returns the protein sequences with matching headers. Partial or exact match is supported (partial means that the string from beginning of the line upto the next whitespace is used in the search).   

**Required:** `Biostrings`, `stringr`   

**Usage:**   
In an `R` session, do:

```
devtools::source_url("https://raw.githubusercontent.com/angelovangel/etc/master/bin/subset_proteins.R")
```

Then the function `subset_proteins()` should be available in your session.
