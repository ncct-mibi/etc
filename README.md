---
title: "etc"
author: "Angel Angelov"
output:
  html_document:
    toc: TRUE
    keep_md: TRUE
---

Various workflows, scripts and functions. Mostly in `R`.

***

### himap.R
**File**: `bin/himap.R`   
This is a wrapper around the [HiMAP package](https://www.biorxiv.org/content/10.1101/565572v1) for 16S rDNA analysis. It processes `fastq` files to Operational Strain Units (OSU) abundance. The script is intended to be run from the command line. Try `himap.R -h` for help.   
**Usage:**   
Download the `himap.R` file and put it in your `$PATH` (e.g. `$HOME/bin`). For example in a terminal:   
```{r}
wget https://raw.githubusercontent.com/angelovangel/etc/master/bin/himap.R
mv himap.R $HOME/bin
chmod a+x $HOME/bin/himap.R
```
After that, the script can be run directly from terminal (but adjust the shebang to your system), e.g. `himap.R --help`. It will also attempt to install the required `R` packages.

***

### Merge lane-splitted `fastq` files   
**File:** `bin/mergefq_name.R`   
**Required:** `stringr`   
Sometimes, you get `fastq` files which are split by lane, that is, the sequences from one sample are split in several different directories and files. This is the default behaviour of Basespace, or if the `bcl2fastq` was executed without the `--no-lane-splitting` option. The file structure in such cases might look like this:
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

### Merge `fastq` files from resequenced libraries

***

### Subset protein `fasta` file
**File:** `bin/subset_proteins.R`   
**Required:** `Biostrings`, `stringr`   
Thus `R` function takes a string vector of protein fasta headers and a protein fasta file and returns 
the protein sequences with matching headers. Partial or exact match is supported (partial means that the string from beginning of the line upto the next whitespace is used in the search).   
**Usage:**   
In an `R` session, do:
`devtools::source_url("https://raw.githubusercontent.com/angelovangel/etc/master/bin/subset_proteins.R")`   
Then the function `subset_proteins()` should be available in your session.
