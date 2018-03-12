#!/bin/bash
#-------------------------------------------------------------------------------
# Fixes all non-space characters from source files in current directory
# and replaces them with space
#-------------------------------------------------------------------------------

FILES=($(find ./ -not -path "./extern/*" -iname '*.cpp' -o -not -path "./extern/*" -iname '*.hpp'))
for i in "${FILES[@]}"
do
	perl -CSDA -plE 's/\s/ /g' $i > $i.tmp
	cmp --silent $i $i.tmp || echo "Converted $i"
	mv $i.tmp $i
	rm -f $i.tmp
done
echo "DONE."
