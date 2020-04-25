#!/bin/bash
#-k1,1 -u
cat $1 | sort | uniq > temp.txt
echo "Sorting"
cp temp.txt $1
echo "Redirect output"
rm temp.txt
echo "Done"
