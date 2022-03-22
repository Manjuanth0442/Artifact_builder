#!/bin/bash
set -x

file=$(cat list.txt | awk '{print $3}')
file=($file)

count=0

for num in ${file[@]};do
	count=$(( $count + $num ))
done

echo $count
