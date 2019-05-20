# etc
Various workflows, scripts and functions. Mostly in `R`.

***

## himap.R
**File**: `bin/himap.R`   
This is a wrapper around the [HiMAP package](https://www.biorxiv.org/content/10.1101/565572v1) for 16S rDNA analysis. It processes `fastq` files to Operational Strain Units (OSU) abundance. The script is intended to be run from the command line. Try `himap.R -h` for help.   
**Usage:**   
Download the `himap.R` file and put it in your `$PATH` (e.g. `$HOME/bin`). For example in a terminal:   
```{r}
wget https://raw.githubusercontent.com/angelovangel/etc/master/bin/himap.R
mv himap.R $HOME/bin
chmod a+x $HOME/bin/himap.R
```
After that, the script can be run directly from terminal, e.g. `himap.R --help`. It will also attempt to install the required `R` packages.

***

## Merge lane-splitted `fastq` files   
**File:** `bin/mergefq_name.R`   
**Required:** `stringr`   
Sometimes, you get `fastq` files which are split by lane, that is, the sequences from one sample are split in several different files. This is the default behaviour of Basespace, or if the `bcl2fastq` was executed without the `--no-lane-splitting` option. The file structure in such cases might look like this:
```


```
**Usage:**   
Source the file, then use like this:   
```{r}
devtools:github_source()

```

***

## Merge `fastq` files from resequenced libraries

***

## Subset protein `fasta` file
**File:** `bin/subset_proteins.R`   
**Required:** `Biostrings`, `stringr`   
Thus `R` function takes a string vector of protein fasta headers and a protein fasta file and returns 
the protein sequences with matching headers. Partial or exact match is supported (partial means that the string from beginning of the line upto the next whitespace is used in the search).   
**Usage:**   
In an `R` session, do:
`devtools::source_url("https://raw.githubusercontent.com/angelovangel/etc/master/bin/subset_proteins.R")`   
Then the function `subset_proteins()` should be available in your session.
