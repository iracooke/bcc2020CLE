
if [[ ! -f H_mac_cds.1.bt2 ]]; then
	bowtie2-build H_mac_transcripts_codingseq.fasta H_mac_cds --threads 6
fi


for r1 in *R1.fastq.gz;do
	r2=${r1/R1/R2}
	sample=${r1%_R1.fastq.gz}
	bowtie2 -x H_mac_cds -1 $r1 -2 $r2 > $sample.sam
done

