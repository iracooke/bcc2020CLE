# Exercise 3

In this exercise we will write an `awk` program to split a fasta file into chunks. 

This is useful to parallelise certain programs (eg Interproscan) that don't behave well with lots of sequences or aren't properly parallelised internally.  

Change directory into the `exercise_3` folder and then use `ls` to display the files present. 
```bash
cd ~/bcc2020cle/exercise_3
ls
```

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

Note that I always start my `awk` commands using `cat` to send data via a pipe.  This is handy because it puts the `awk` command at the end of the line so I can easily edit it. 

The general usage of `awk` is

> awk 'program' file

Where ‘program’ is a small program written in the awk language. In general awk programs are organised like this;

```awk
pattern { action }
```

*Action*

Lets look closely at the action in the example above. The action is

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

In this case the *Pattern* we have used is quite interesting. It is;

```awk
(NR-1)%1000==0
```

This uses the modulo operator `%` which gives the remainder of a division.  In this case it gives the remainder after dividing (NR-1) by 1000.  This will equal 0 when NR is 1, 1001, 2001 and so on.

Eventually we will build our `awk` program up quite a bit so let's put it into a file instead of running it on one line. Create a file called `split.awk` and copy the following contents into it;

```awk
(NR-1)%1000==0{
	print $name, NR
}
```

Now we can achieve the same result as before by referring to the `awk` program in our file

```bash
cat H_mac_protein.fasta | bioawk -c fastx -f split.awk
```

This isn't what we want yet but it is a start.  

Since we want separate files for each 1000 proteins we can use the action specifier to change a filename variable.  Let's start putting this into `split.awk`. Replace the contents of `split.awk` with this

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

The rest is relatively easy.  We just print data to whatever the current file variable is.  We can do this by adding another action to print the current fasta record. This time the pattern for the action is blank so it gets triggered for every record.

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

-------------