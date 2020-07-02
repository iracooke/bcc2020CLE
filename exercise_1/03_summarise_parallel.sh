
# Basic command
# samtools flagstat EM1.sam > EM1.stats

# # Doing with a loop
# for f in *.sam;do
# 	samtools flagstat $f > ${f%.sam}.stats
# done

# Doing with gnu parallel

dostats(){
	sample=${1%.sam}
	samtools flagstat $sample.sam > $sample.stats
}

export -f dostats

parallel -j 12 dostats ::: *.sam

