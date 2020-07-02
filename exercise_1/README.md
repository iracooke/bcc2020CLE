# Exercise 1

In this exercise we will imagine that we have a large number of samples and wish to map these to a denovo assembled transcriptome. 

It is a good example of where a relatively simple bash script can be used to automate and parallelise. 

## Inputs

- A reference transcriptome file
- Remote URLs for downloading 12 samples of RNA-seq

## Tasks

1. Download the files
2. How many reads are in each file?
3. Build an index with bowtie2-build
4. Use a for loop to align across all files
5. Use gnu parallel to automate alignment

