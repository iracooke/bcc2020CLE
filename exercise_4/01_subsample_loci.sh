grep -v '^#' aten_example.vcf | 
	awk '{printf("%s:%s-%s\n",$1,$2-50,$2+50)}' | 
	shuf -n 1000 > aten_example_random1k.txt
