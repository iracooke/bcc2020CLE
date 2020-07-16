# Command line essentials for Bioinformatians

This website is a companion reference for the corresponding [BCC2020 conference session](https://sched.co/c7Sz). 

This workshop is designed for students who already have a basic familiarity with running programs and navigating the filesystem in a unix shell.  It aims to refresh some of that basic knowledge and then build upon it to demonstrate powerful features of the shell that can be used to speed up common bioinformatics tasks.



## About the Instructor

[Ira Cooke](https://research.jcu.edu.au/portfolio/ira.cooke/) is a senior lecturer in bioinformatics at James Cook University and co-director of its [Centre for Tropical Bioinformatics and Molecular Biology](https://www.jcu.edu.au/ctbmb).  

You can find out more about his research interests on his [staff webpage](https://research.jcu.edu.au/portfolio/ira.cooke/), at [marine-omics.net](https://www.marine-omics.net/) and [marine-molecular-biology.group](https://www.marine-molecular-biology.group/).  

He is also occasionally active on twitter [@iracooke](https://twitter.com/iracooke)


## Setup

#### If you are a BCC2020 workshop participant

All the files you need to run the exercises should already be setup in your user account on [rstudio.bioinformatics.guide](https://rstudio.bioinformatics.guide)

1. Log in to the workshop server using the credentials provided by your instructor.  
The workshop server is available at [rstudio.bioinformatics.guide](https://rstudio.bioinformatics.guide)
2. The server is running rstudio but for this workshop we will just use the `Terminal` feature provided by rstudio.  Click `Tools` -> `Terminal` -> `New Terminal`.  

#### If you want to run the exercises on your own computer

1. Open a Terminal window on your computer. 
2. Create a directory for workshop materials
```bash
mkdir bcc2020cle
```
3. Download and run the setup script
```bash
cd bcc2020cle
wget -L https://raw.githubusercontent.com/iracooke/bcc2020CLE/master/setup.sh
bash setup.sh
```
4. Install the following required packages, `samtools`, `parallel`, `bowtie2`, `bioawk`


## Introduction

Start with [this presentation](https://rpubs.com/iracooke/bcc2020cle) which outlines why command line skills are important and runs through the key features of the Bash shell.

## Exercises

- [Exercise 1](exercise_1.md)
- [Exercise 2](exercise_2.md)
- [Exercise 3](exercise_3.md)
- [Exercise 4](exercise_4.md)


