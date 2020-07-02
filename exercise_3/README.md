# Exercise 3

In this exercise we will write an `awk` program to splitting a fasta file into chunks. 

This is useful to parallelise certain programs (looking at you Interproscan) that don't behave well with lots of sequences or aren't properly parallelised internally.  

We'll use blast as a convenient example but in reality blast is quite well parallelised.

## Inputs

- A large `fasta` file containing xxxx sequences.

## Task

- Use `bioawk` to split this into chunks with 1000 sequences per chunk

