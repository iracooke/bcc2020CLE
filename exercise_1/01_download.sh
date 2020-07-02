base_url="https://s3-ap-southeast-2.amazonaws.com/bc3203/EM_10k/"
for sample_num in $(seq 1 12)
do
  for r in R1 R2
    do
    wget "${base_url}EM${sample_num}_${r}.fastq.gz"
  done
done
