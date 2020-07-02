

join -t $'\t' -a 1 \
	<(bioawk -c fastx 'OFS="\t"{print $name,$seq}' H_mac_protein_first100.fasta) \
	<(cat H_mac_protein_first100.blastp | awk -F '\t' 'OFS="\t"{print $1,$13}') | \
	awk -F '\t' '{printf(">%s\t%s\n%s\n",$1,$3,$2)}'



