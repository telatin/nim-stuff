#!/bin/bash

for i in $(find ~/MEGA -name "*.fa"); 
do 
	TOT=$(grep -c '>' $i); FA=$(./fa_threads $i|cut -f2); 
	if [[ $FA -ne $TOT ]]; 
	then 
		echo "ERROR: $i: $FA != $TOT";
        else
		OK=$((OK+1))
	fi; 
done

echo $OK OK
