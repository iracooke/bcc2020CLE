# Exercise 2

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

-------------