#!/bin/bash
CNT=0
MAX=1000
for i in $(find ~/MEGA -name "*.fq"); 
do 
	CNT=$((CNT+1))
	if [[ $CNT == $MAX ]]; then
		echo $OK OK
		exit
	fi
	TOT=$(($(cat $i | wc -l) / 4));
	FQ=$(./fq_threads $i|cut -f2); 
	if [[ $FQ -ne $TOT ]]; 
	then 
	  if [[ $FQ -gt $TOT ]]; then
			OFF=$(($FQ - $TOT))
			echo "ERROR: $i: $FQ > $TOT ($OFF)";
		else
			echo "ERROR: $i: $FQ < $TOT";
		fi
  else
		OK=$((OK+1))
	fi; 
done

echo $OK OK
