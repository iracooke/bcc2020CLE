grep '>' H_mac_protein.fasta | \
	sed 's/>//' | \
	head -n 100 | \
	xargs samtools faidx H_mac_protein.fasta > H_mac_protein_first100.fasta

