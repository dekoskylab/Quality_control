#!/bin/bash

#Usage:  bash precision_hamming_calculator.sh UNIQUE_FILE1 UNIQUE_FILE2
#calculates precision from file1 and file2
#file1 should be uniqe_pairs, as should file2

rm results.txt

FILE1=$1
FILE2=$2

awk '{print $2 "\t" $3 "\t" $1}' $FILE1 | sort -k 1,1 > temp1HCs.sorted.txt
awk '{print $2 "\t" $3 "\t" $1}' $FILE2 | sort -k 1,1 > temp2HCs.sorted.txt
join -j 1 -o 1.1 1.2 2.2 1.3 2.3 temp1HCs.sorted.txt temp2HCs.sorted.txt > temp_HCjoins.txt

wc -l temp1HCs.sorted.txt temp2HCs.sorted.txt temp_HCjoins.txt

LENGTH_MISMATCH=$(awk '{if($4>0) if($5>0) if(($4/$5)>0.0333) if(($4/$5)<30) if(length($2)!=length($3)) print}' temp_HCjoins.txt | wc -l)
RIGHTLENGTH_INEXACTMATCH=$(awk '{if($4>0) if($5>0) if(($4/$5)>0.0333) if(($4/$5)<30) if(length($2)==length($3)) if($2!=$3) print}' temp_HCjoins.txt | wc -l)
EXACT_MATCH=$(awk '{if($4>0) if($5>0) if(($4/$5)>0.0333) if(($4/$5)<30) if($2==$3)print}' temp_HCjoins.txt | wc -l)

echo "Reads of qualifying pairs must be within a factor of 30 of each other."

echo -e "Number exact matches:\n$EXACT_MATCH"
echo -e "Number mismatches:\n$LENGTH_MISMATCH"
echo -e "Number uncertain:\n$RIGHTLENGTH_INEXACTMATCH"
	
echo
echo -e "HAMMING DISTANCE CALCULATION ..."

awk '{if($4>0) if($5>0) if(($4/$5)>0.0333) if(($4/$5)<30) if(length($2)==length($3)) if($2!=$3) print $2 "\t" length($2) "\t" $3 "\t" length($3)}' temp_HCjoins.txt > uncertain.txt

while read line
do
	#Report SEQ1
	S1=$(echo "$line" | awk -F "\t" '{print $1}')
	#Report SEQ2
	S2=$(echo "$line" | awk -F "\t" '{print $3}')

	HAMMING=0

	for ((i=0; i<${#S1}; i++)); do
    	[ ${S1:i:1} == ${S2:i:1} ] || let "HAMMING++" 
	done

	echo "$HAMMING" >> results.txt


done < uncertain.txt

echo
	paste uncertain.txt results.txt > hamming_resultes.txt
	# the difference between each undetermined pair calculated by dividing the hamming distance over the length
 
	#if the difference <=0.2, the pairs are MATCH
	hamming_similar=$(cat hamming_resultes.txt  | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $5/$2}' | awk '{if($6<=0.2) print $0}' | wc -l)
	echo -e "Number of equal or great than 80% similar:\n$hamming_similar"
	#if the difference >0.2, the pairs are MISMATCH
	hamming_unsimilar=$(cat hamming_resultes.txt  | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $5/$2}' | awk '{if($6>0.2) print $0}' | wc -l)
	echo -e "Number of less than 80% similar:\n$hamming_unsimilar"

#Total correct 
sum1=$(( $EXACT_MATCH + $hamming_similar ))

#Total incorrect
sum2=$(( $LENGTH_MISMATCH + $hamming_unsimilar ))

#Total correct + total incorrect
sum3=$(( $sum1 + $sum2 ))

echo -e "$sum1 $sum3" > math_result.txt

#Divide total correct over total incorrect and take square root
square_root=$(cat math_result.txt | awk '{print sqrt ($1/$2)}')

echo -e "Total number of matched CDR-H3_CDR-L3:\n$sum1"
echo -e "Total number of mismatched CDR-H3_CDR-L3:\n$sum2"
#echo -e "Total number exact + total number incorrect matches:\n$sum3"
#echo -e "Total exact/Total inexact + Total incorrect:\n$divide"
echo -e "VH-VL pairing precision:\n$square_root"
echo
