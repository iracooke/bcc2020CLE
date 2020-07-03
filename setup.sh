
for n in $(seq 1 4);do mkdir -p exercise_$n;done

if [[ ! -f exercise_1/H_mac_transcripts_codingseq.fasta ]]; then
	wget "https://cloudstor.aarnet.edu.au/plus/s/v0wWlXGAaN1tKiY/download" -O exercise_1/H_mac_transcripts_codingseq.fasta
fi


if [[ ! -f exercise_2/H_mac_protein.fasta ]]; then
	wget "https://cloudstor.aarnet.edu.au/plus/s/APUXTkLZKWsXlEY/download" -O exercise_2/H_mac_protein.fasta && \
	cd exercise_3 && \
	ln -s ../exercise_2/H_mac_protein.fasta . &&
	cd ..
fi


if [[ ! -f exercise_4/aten_example.vcf ]]; then
	wget "https://cloudstor.aarnet.edu.au/plus/s/JmyKzTWksYmMuaU/download" -O exercise_4/aten_example.vcf
fi

if [[ ! -f exercise_4/aten_final_0.11.fasta ]]; then
	wget http://aten.reefgenomics.org/download/aten_final_0.11.fasta.gz -O exercise_4/aten_final_0.11.fasta
fi

if [[ ! -f exercise_2/uniprot/uniprot_sprot.fasta ]]; then
	echo "Downloading Swissprot. This could take a while"
	mkdir -p exercise_2/uniprot/ && \
	wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz -O exercise_2/uniprot/uniprot_sprot.fasta.gz && \
	cd exercise_2/uniprot/ && \
	gunzip uniprot_sprot.fasta.gz && \
	makeblastdb -dbtype 'prot' -in uniprot_sprot.fasta -title swissprot && \
	cd ../../
fi



