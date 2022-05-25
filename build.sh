# Assemble and link all files apart from linux.s and ref.s
#!/bin/bash

OBJ_FILES=""

if [ $# -ne 0 ] ; then
	BIN=$1	
else
	BIN="bin.out"
fi

for f in `ls | grep "\.s$"` 
do
	OBJ=`echo $f | cut -d'.' -f 1`.o
	
	if [ $OBJ != "linux.o" ] && [ $OBJ != "ref.o" ] ; then
		OBJ_FILES="$OBJ_FILES $OBJ"
		as $f -o $OBJ
		echo "Assembling $f --> $OBJ"
	fi
done

echo "linking $OBJ_FILES --> $BIN"
ld $OBJ_FILES -o $BIN

echo  "Cleaning .o files: $OBJ_FILES"
for f in $OBJ_FILES
do
	rm $f
done
