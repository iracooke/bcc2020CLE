blastp -db uniprot/swissprot \
	-query H_mac_protein_first100.fasta \
	-outfmt '6 std stitle' \
	-num_threads 6 \
	-evalue 0.00001 \
	-max_hsps 1 \
	-max_target_seqs 1 > H_mac_protein_first100.blastp




