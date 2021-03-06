# Exercise 1

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

#### 03 Convert `sam` to `bam`

The `sam` format is human readable but isn't very efficient.  For further processing it is often better to convert to `bam` which is a more efficient binary format. One (of many) ways to do this is using the `samtools view` command.  For example to convert one file

```bash
samtools view -b -S EM1.sam > EM1.bam
```

We might want to do this for all the `.sam` files. We will use this an example to introduce the `parallel` tool which allows us to run operations in parallel in a simple way. 

Create a new empty script file, call it `03_sam2bam.sh` and save it inside the `example_1` directory. 

Paste the following code into the file and save it

```bash
sam2bam(){
	sample=${1%.sam}
	samtools view -b -S $sample.sam > $sample.bam
}

export -f sam2bam

parallel -j 12 sam2bam ::: *.sam
```

Now try running the script

```bash
bash 03_sam2bam.sh
```

Type `ls *.bam` to see all the new files it generated. 

What is going on in this script?  

There are two new concepts here

1. Functions. This script captures several commands into a function called `sam2bam()`  
2. The `parallel` command. This allows us to run `sam2bam()` on 12 processes simultaneously.

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