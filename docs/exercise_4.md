# Exercise 4

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





