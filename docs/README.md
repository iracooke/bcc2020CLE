# Command line essentials for Bioinformatians

This website is a companion reference for the corresponding [BCC2020 conference session](https://sched.co/c7Sz). 

This workshop is designed for students who already have a basic familiarity with running programs and navigating the filesystem in a unix shell.  It aims to refresh some of that basic knowledge and then build upon it to demonstrate powerful features of the shell that can be used to speed up common bioinformatics tasks.

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

## Introduction

Start with [this presentation](https://rpubs.com/iracooke/bcc2020cle) which outlines why command line skills are important and runs through the key features of the Bash shell.

## Exercise 1

This exercise picks up from the last point in the introductory presentation (see above).  It explores methods for automating repetitive tasks.  

Our analysis goal in this exercise is to map paired end Illumina reads from an RNA sequencing run onto a de-novo assembled transcriptome.  There are 12 samples and we need to align each of them. We will then run some summary stats on the aligned reads. 

Change directory into the `exercise_1` folder and then use `ls` to display the files present
```bash
cd bcc2020cle/exercise_1
```

```bash
ls
```

**Inputs**
- A reference transcriptome file `H_mac_transcripts_codingseq.fasta`
- Remote URLs for downloading the 12 samples. 

#### 01 downloading samples

Use the `rstudio` interface to create a new text file inside the `exercise_1` directory. Name your new file `01_download.sh`
![new script](img/newscript.png)

Copy the following code into your script.  This code comes from the last few slides of the introductory presentation

```bash
base_url="https://s3-ap-southeast-2.amazonaws.com/bc3203/EM_10k/"
for sample_num in $(seq 1 2)
do
  for r in R1 R2
    do
    echo "${base_url}EM${sample_num}_${r}.fastq.gz"
  done
done
```

Now try running the script
```bash
bash 01_download.sh
```

The script emits four URLs corresponding to 2 samples.

Now try downloading the first URL using the `wget` command

```bash
wget https://s3-ap-southeast-2.amazonaws.com/bc3203/EM_10k/EM1_R1.fastq.gz
```

1. How would you modify this script so that it emits all 24 URLs for the 12 samples required?
2. How would you modify this script so that it actually downloads all 24 URLs

If you need help you can view the final answer [here](https://github.com/iracooke/bcc2020CLE/blob/master/exercise_1/01_download.sh)

#### 02 aligning reads to the transcriptome

We will now align each of the pairs of reads to the transcriptome using `bowtie2`. Before we can do this we first need to index the transcriptome using `bowtie2-build`. 

```bash
bowtie2-build H_mac_transcripts_codingseq.fasta H_mac_transcripts_codingseq
```

While you wait for this command to finish create a new script file. Call it `02_align.sh` and save it in the `exercise_1` directory.

This file will contain commands for iterating over the samples and running the `bowtie2` alignment program separately for each sample.  Start by practising the command for a single sample. Try running `bowtie2` with no arguments like this

```bash
bowtie2
```

You should see a whole lot of text printed.  These are all the `bowtie2` options.  Scroll to the top to see basic usage which looks like this

> Usage: bowtie2 [options]* -x <bt2-idx> -1 <m1> -2 <m2>

For paired-end reads we need to supply three arguments
- `-x` : The indexed reference. In this case `H_mac_transcripts_codingseq`
- `-1` : File containing forward reads
- `-2` : File containing reverse reads

For example

```bash
bowtie2 -x H_mac_transcripts_codingseq -1 EM1_R1.fastq.gz -2 EM1_R2.fastq.gz
```

This prints output in `sam` format directly to standard output.  We could redirect this to a `sam` file like so

```bash
bowtie2 -x H_mac_transcripts_codingseq -1 EM1_R1.fastq.gz -2 EM1_R2.fastq.gz > EM1.sam
```

Now that we have a method for aligning a single sample our goal is to write a script to automate the process for all 12 samples. 


Start by pasting the following code into your `02_align.sh` file

```bash
for r1 in *R1.fastq.gz;do
	echo $r1
done
```

Then run your file like this 

```bash
bash 02_align.sh
```

This is step 1 of the process.  We have a method for iterating over each of the forward read files.  We still need to figure out how to do the following;

1. Obtain the name of the reverse read file based on the name of the forward read
2. Obtain the name of the sample itself
3. Enter code to run the command (instead of `echo`)

Note that we are using `echo` here for debugging purposes.  It allows us to build up the script gradually, verifying that we have each piece of information before we put it all into a working command. 

Now try the following (just in your Terminal don't enter it into the `02_align.sh` script)

```bash
r1=EM1_R1.fastq.gz
echo $r1
echo ${r1/R1/R2}
```

The second `echo` command uses an example of [parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) which is a very powerful feature of bash. It is often use to manipulate text and is very useful for transforming filenames. The form we used above has the general form:

> ${parameter/pattern/string}

And will substitute `string` for the first occurrence of `pattern`.

Now try another form of `parameter expansion`.

```bash
r1=EM1_R1.fastq.gz
echo ${r1%_R1.fastq.gz}
```

This time parameter expansion chopped off the trailing part of the `$r1` variable to produce the sample name. 

Now we have the pieces we need to implement `02_align.sh`

Replace the code in `02_align.sh` with the following code

```bash
for r1 in *R1.fastq.gz;do
	r2=${r1/R1/R2}
	sample=${r1%_R1.fastq.gz}
	bowtie2 -x H_mac_transcripts_codingseq -1 $r1 -2 $r2 > $sample.sam
done
```

And run it like this

```bash
bash 02_align.sh
```


#### 03 Summarising `sam` files

Try running the tool `samtools flagstat` on one of the `.sam` files

```bash
samtools flagstat EM1.sam
```

This prints some useful summary information. We might want to do this for all the `.sam` files. We will use this an example to introduce the `parallel` tool which allows us to run operations in parallel in a simple way. 

Create a new empty script file, call it `03_flagstat.sh` and save it inside the `example_1` directory. 

Paste the following code into the file and save it

```bash
dostats(){
	sample=${1%.sam}
	samtools flagstat $sample.sam > $sample.stats
}

export -f dostats

parallel -j 12 dostats ::: *.sam
```

Now try running the script

```bash
bash 03_flagstat.sh
```

Type `ls *.stats` to see all the new files it generated. 

What is going on in this script?  

There are two new concepts here

1. Functions. This script captures several commands into a function called `dostats()`  
2. The `parallel` command. This allows us to run `dostats()` on 12 processes simultaneously.

Let's play with these in the Terminal to get familiar with them. 

First the parallel command

```bash
parallel -j 4 echo ::: $(seq 1 12)
```

On the right of the `:::` we have generated a sequence 1 through to 12.  Each of these is passed to `echo` but parallel is running them 4 at a time. 

When running complex sequences of commands with `parallel` it is often easier to capture these in a function. Try defining a function as follows;

```bash
myecho() { sleep 1; echo "my $1"; }
```

This waits one second and then prints it's argument along with a `my ` prefix.

Now try running this with `parallel`

```bash
export -f myecho
parallel -j 4 myecho ::: $(seq 1 12)
```

#### 04 (Optional) Explore `sam` files

Try viewing the contents of one of the `.sam` files with `samtools view`

```bash
samtools view -S EM1.sam
```

This looks complicated but it is just a tabular format.  The columns are all [described here](https://en.wikipedia.org/wiki/SAM_%28file_format%29).  Each line in the file represents an alignment (a read and its position in the reference). A single read can have multiple alignments. 

Our data is extremely sparse. We have just 200 reads for each sample and something like 22.5k transcript sequences in the reference. One nice aspect of this is that it allows us to see the paired nature of the reads easily.  Since each pair comes from the same cDNA fragment there should usually be exactly 2 reads for each gene.  This is because the data is very sparse we will rarely have independent reads from the same gene. 

You can verify this as follows

1. Use `awk` to extract the third column of the file which contains the gene name
```bash
samtools view -S EM1.sam | awk '{print $3}'
```
2. Use `sort` and `uniq` to count occurrences
```bash
samtools view -S EM1.sam | awk '{print $3}' | sort | uniq -c
```

-------------

## Exercise 2

In this exercise we will perform a very basic functional annotation on a small subset of proteins from a large database.  The functional annotation is obtained by running a blast search against uniprot.  We then take the information from blast and combine it back into the `fasta` header line for the corresponding proteins.

We will make use of the following tools;  `sed`, `xargs`, `samtools faidx`, `grep`, `blastp`, `join`, `bioawk`, `awk`

Each of these tools (especially `awk`) are sufficiently complex to warrant an entire workshop dedicated to their use alone.  We will cover a tiny subset of what they can do here but hopefully enough to encourage you to read further. Despite being very old the [Grymoire](https://www.grymoire.com/Unix/) is still a great resource for learning about these tools.


Change directory into the `exercise_2` folder and then use `ls` to display the files present. 
```bash
cd ~/bcc2020cle/exercise_2
ls
```

**Inputs**
- A translated transcriptome (proteome) of unknown proteins `H_mac_protein.fasta`


#### 01 Extract first 100

It would take quite a while to blast search all the proteins in `H_mac_protein.fasta` so we will focus on just the first 100. 

To extract these we start by extracting the names of proteins in the file (note the use of `head` to avoid printing huge amounts of text to your screen). `head` simply shows the first 10 lines of output.

```bash
grep '>' H_mac_protein.fasta | head
```

We need to remove the `>` character from the start of these.  This is easy to do with `sed`

```bash
grep '>' H_mac_protein.fasta | sed 's/>//' | head
```

We could easily modify the `head` command to print the first 100 (what we want) instead of just the first 10

```bash
grep '>' H_mac_protein.fasta | sed 's/>//' | head -n 100
```

Now the task is to extract the full sequence entries for each of these 100 named proteins.  The tool `samtools faidx` can be used for this.  As an example try extracting a single protein

```bash
samtools faidx H_mac_protein.fasta g1.t1
```

Now we have the components we need.  We can obtain all 100 of the sequence IDs and we also have a method to extract them one at a time.  One way to put this together (not the best way) would be to use a for loop like this

```bash
for id in $(grep '>' H_mac_protein.fasta | sed 's/>//' | head -n 100);do
	samtools faidx H_mac_protein.fasta $id
done
```

This works but it is slow.  A much better way it so use the versatile `xargs` utility.  This takes advantage of the fact that `samtools faidx` can grab more than one protein at a time but also avoids problems that arise when the list of proteins is very large. 

```bash
grep '>' H_mac_protein.fasta | sed 's/>//' | head -n 100 | xargs samtools faidx H_mac_protein.fasta
```

Finally we need to redirect the output of this command to a file called `first100.fasta`

```bash
grep '>' H_mac_protein.fasta | sed 's/>//' | head -n 100 | xargs samtools faidx H_mac_protein.fasta > first100.fasta
```

> Good practice would be to capture this final command into a numbered script file (eg `01_first100.sh`)

#### 02 blast

When working with genomic data from non-model organisms the majority of sequenced genes and their protein products do not have functional data.  We can roughly infer gene function by homology to genes for which genuine functional information is available.  The best available database of functionally annotated genes/proteins is Swissprot. 

Try typing `blastp -help` to see a full detailed list of options to the `blastp` command. Among the huge numbers of options we will use the following;

- `-db` : The blast database for searching ( `uniprot/swissprot`)
- `-query` : The list of proteins to use as queries (`first100.fasta`)
- `-outfmt` : Controls the output format.  We will use `-outfmt '6 std stitle'` 
- `num_threads` : Number of threads to use.
- `evalue`: The maximum E-value to accept a match. Only matches with low e-values are likely homologs
- `max_hsps` : We set this 1 to show only one matching region per pair of proteins
- `max_target_seqs` : We set this to 1* because we only want the best match for each query

> Note that in a real application you shouldn't use `max_target_seqs 1` because it is not guaranteed to give the best match. 

Create a new script file and call it `02_blast.sh`.  (Save it in `exercise_2`). Paste the following content into the file

```bash
blastp -db uniprot/swissprot \
	-query first100.fasta \
	-outfmt '6 std stitle' \
	-num_threads 6 \
	-evalue 0.00001 \
	-max_hsps 1 \
	-max_target_seqs 1 > first100.blastp
```

Run the script

```bash
bash 02_blast.sh
```

Inspect the first few lines of the blast results file

```bash
head first100.blastp
```

#### 03 Join

This next step brings quite a few tools together.  We will build the logic in stages. 

Our final goal is to run the `join` command which has the form

> join file1 file2

If `file1` and `file2` are tabular files the join command will combine the values in both files. A single row of output will be printed for every row in `file1` and `file2` where the values in the first column match. 

For our purposes the two files we want to join are `first100.fasta` and `first100.blastp`.  This is tricky because `first100.fasta` is not tabular.  It is `fasta`.  We can deal with that using `bioawk` as follows;

```bash
bioawk -c fastx 'OFS="\t"{print $name,$seq}' first100.fasta
```

Now for the blastp results file.  It has lots of columns be we actually only want the first column, which matches the IDs in `first100.fasta` and the 13th column which has a description of blast match. 

```bash
cat first100.blastp | awk -F '\t' 'OFS="\t"{print $1,$13}'
```

In both cases we used `OFS="\t"` to ensure that the output field separator is set to tabs.  This is essential because the description field in the blastp result has many spaces (so we don't want spaces as our delimiter). 

Using the two commands above we can generate `file1` and `file2` as follows;

```bash
bioawk -c fastx 'OFS="\t"{print $name,$seq}' first100.fasta | sort > file1
cat first100.blastp | awk -F '\t' 'OFS="\t"{print $1,$13}' | sort > file2
```

Note that we also added a pipe to `sort`.  This is because `join` only works on sorted inputs.

Now the `join` command

```bash
join -t $'\t' file1 file2
```

Note that the syntax `-t $\'\t'` tells `join` to use tab as the delimiter between columns

This is very close to what we want but not quite.  Let's count the number of rows in the output

```bash
join -t $'\t' file1 file2 | wc -l
```

Our original `first100.fasta` file has 100 proteins so we want 100 rows back (one for each). This is because `join` does an inner join by default.  We would like to join in a way that prints a row for every item in `file1` even if there is no match in `file2`.  This is done as follows;

```bash
join -t $'\t' -a 1 file1 file2 
```

Finally we would like to transform the outputs from tabular back to `fasta`.  This can be done with `awk` as follows;

```bash
join -t $'\t' -a 1 file1 file2 | awk -F '\t' '{printf(">%s\t%s\n%s\n",$1,$3,$2)}'
```

Here the `-F` option is provided to `awk` to use tab as the separator.  Then we use a `printf` command to format outputs into fasta. The `printf` command has this general form

> printf("format",...args)

Since this is a tutorial about the features of bash it is also worth noting that we need not generate the intermediate files, `file1`, and `file2` here.  We can use a feature of bash called process substitution to directly pass the outputs of one command in as the inputs of another, as if they were contained in a file.  Using this, our entire join command can be written in a single line as;

```bash
join -t $'\t' -a 1 \
	<(bioawk -c fastx 'OFS="\t"{print $name,$seq}' first100.fasta) \
	<(cat first100.blastp | awk -F '\t' 'OFS="\t"{print $1,$13}') | \
	awk -F '\t' '{printf(">%s\t%s\n%s\n",$1,$3,$2)}'
```

## Exercise 3

In this exercise we will write an `awk` program to split a fasta file into chunks. 

This is useful to parallelise certain programs (eg Interproscan) that don't behave well with lots of sequences or aren't properly parallelised internally.  

**Inputs**
- A large `fasta` file `H_mac_protein.fasta` containing over 22k sequences

Create a new blank script file called `split.awk` and save it in the `exercise_3` directory. 

Before we start working with this file it's worth going over a few of the concepts of `awk`. 

#### About `awk` and `bioawk`

The awk command processes text line by line. The awk programming language is used to specify actions to be performed on each line.  The `bioawk` program extends the functionality of normal `awk` to deal with common bioinformatics data formats.  This is very very useful in cases like `fasta` where a single record spans multiple lines. `bioawk` allows us to work on a record, by record basis rather than line by line as a normal `awk` program would. 


For example the following `bioawk` command prints the name of each fasta record

```bash
cat H_mac_protein.fasta | bioawk -c fastx '{print $name}'
```

Note that I always start by `awk` commands using `cat` to send data via a pipe.  This is handy because it puts the `awk` command at the end of the line so I can easily edit it. 

The general usage of `awk` is

> awk 'program' file

Where ‘program’ is a small program written in the awk language. In general awk programs are organised like this;

```awk
pattern { action }
```

*Action*
:ets look closely at the action in the example above. The action is

```awk
print $name
```

Here the print command is used to print a specific field variable.

*Pattern*

As it runs through its input awk will test each line against pattern. If the line matches the pattern then the action will be performed. For example we could modify our `bioawk` program to only show sequences where the name ends with `.t2`

```bash
cat H_mac_protein.fasta | bioawk -c fastx '$name~/.t2$/{print $name}'
```

As awk (or `bioawk`) processes each line it breaks it up into fields. By default it will look for whitespace characters (eg space, tab) and will split each line into fields using whitespace as a separator. In `bioawk` the record is parsed and divided up into `name`, `seq`, and `comment`

In addition to these data fields `awk` automatically populates several internal variables.  The most important one for our purposes is `NR` which holds the current record number.  This will be the key to allowing us to split the file into chunks of 1000 records at a time. 

#### 01 Split

Let's start with a `bioawk` program that takes an action every 1000 records

```bash
cat H_mac_protein.fasta | bioawk -c fastx '(NR-1)%1000==0{print $name, NR}'
```

This isn't what we want yet but it is a start.  Since we want separate files for each 1000 proteins we can use this action specifier to change a filename variable.  Let's start putting this into `split.awk`. Copy the following into `split.awk`

```awk
(NR-1)%1000==0{
	file=sprintf("H_mac%d.fa",(NR-1));
	print file
}
```

And test it like this

```bash
cat H_mac_protein.fasta | bioawk -c fastx -f split.awk
```

The rest is relatively easy.  We just print data to whatever the current file variable is.  

Change your `awk` program to

```awk
(NR-1)%1000==0{
	file=sprintf("H_mac%d.fa",(NR-1));
	print file
}

{
	printf(">%s\t%s\n%s\n",$name,$comment,$seq) >> file
}
```

Check that the correct number of entries is present in each file

```bash
grep -c '>' *.fa
```

## Exercise 4

In this exercise we will attempt to design probes for a random subset of variant loci in a genome

**Inputs**
- A large `vcf` formatted file containing variant sites `aten_example.vcf`
- A corresponding genome sequence `aten_filal_0.11.fasta`

Our strategy is as follows;

1. Use `grep` and `awk` to extract coordinates of all variants in the variant file
2. Use `shuf` to take a random subsample of 10000 of these
3. Use `samtools faidx` to extract a small flanking region around each variant

Start by taking a look at the `vcf` file.  THe first few lines are header content

```bash
head aten_example.vcf
```

Using tail shows the actual variant entries

```bash
tail aten_example.vcf
```

All the header entries start with a `#` character.  We can exclude them using `grep` as follows;

```bash
grep -v '^#' aten_example.vcf | head
```

These are `vcf` entries with lots of information but we only need the first and second columns.  The first column denotes the chromosome (or genomic scaffold) and the second gives the genomic position of the variant.  We can extract these easily with `awk`

```bash
grep -v '^#' aten_example.vcf | awk '{print $1,$2}'
```

Now let's skip to the final step and explore how we can use this information to retrieve the genomic sequence flanking this SNP. With `samtools faidx` we can extract a specific region with the syntax

> chrom:start-end

For example;

```bash
samtools faidx aten_final_0.11.fasta Sc0000000:2118-2138
```

If we want probes 50bp either side of a SNP we can modify our `awk` command to print these intervals

```bash
grep -v '^#' aten_example.vcf | awk '{printf("%s:%s-%s\n",$1,$2-50,$2+50)}'
```

These are sorted according to genomic position.  If we want a random subset we can do

```bash
grep -v '^#' aten_example.vcf | awk '{printf("%s:%s-%s\n",$1,$2-50,$2+50)}' | shuf -n 1000
```

Finally we can pipe this directly to `samtools faidx` via `xargs`

```bash
grep -v '^#' aten_example.vcf | awk '{printf("%s:%s-%s\n",$1,$2-50,$2+50)}' | shuf -n 1000 | xargs samtools faidx aten_final_0.11.fasta
```

> Note. This strategy illustrates some bash principles but it isn't perfect.  We can run off the ends of chromosomes. A more precise way to do this is using the `bedtools` utility.


## About the Instructor

[Ira Cooke](https://research.jcu.edu.au/portfolio/ira.cooke/) is a senior lecturer in bioinformatics at James Cook University and co-director of its [Centre for Tropical Bioinformatics and Molecular Biology](https://www.jcu.edu.au/ctbmb).  You can find out more about his research interests on his [staff webpage](https://research.jcu.edu.au/portfolio/ira.cooke/), at [marine-omics.net](https://www.marine-omics.net/) and [marine-molecular-biology.group](https://www.marine-molecular-biology.group/).  He is also occasionally active on twitter [@iracooke](https://twitter.com/iracooke)






