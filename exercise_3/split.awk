(NR-1)%1000==0{
	file=sprintf("H_mac%d.fa",(NR-1));
	print file
}

{
	printf(">%s\t%s\n%s\n",$name,$comment,$seq) >> file
}


# {
# 	if( (NR-1)%1000==0 ){
# 		file=sprintf("H_mac%d.fa",(NR-1));
# 	}
# 	printf(">%s\t%s\n%s\n",$name,$comment,$seq) >> file
# }