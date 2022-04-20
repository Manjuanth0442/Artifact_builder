#!/bin/bash

read -p "please enter name to reverse " p

echo $p

len=$(echo $p | awk '{print length}')

echo $len

for ((i = $len - 1; i >= 0; i--));
do
	reverse="$reverse${p:$i:1}" 
done

echo $reverse
