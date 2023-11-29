#!/bin/bash
# $1 is a folder to analyze
# outputfiles are tmpout123 , structuralcolouralignments.txt structuralcolourpredictionmatrix.txt, structuralcolourvotes.txt
# obviously this is only for internal use. Slightly embarrassing bash code

cd $1 # never ever ever remove this line. ever. just don't
cd .. #also keep this intact
echo "Still running. Please bookmark and come back in 2 minutes and press refresh" > index.html

cd $1
prodigal -a proteins.faa -i upload.fasta
cd ..

echo > structuralcolouralignments.txt
echo "Name" |tr "\n" "," > structuralcolourpredictionmatrix.txt
cat /mnt/data/structuralcolourweb/models |tr "\n" "," |sed 's/,$//' >>structuralcolourpredictionmatrix.txt
echo >> structuralcolourpredictionmatrix.txt

ls $1/*.faa |while read faa ; do 
    rm tmpout123
    hmmsearch -E 1E-30 --cpu 16 --notextw --tblout tmpout123 /mnt/data/structuralcolourweb/structuralcolour.hmm $faa >> structuralcolouralignments.txt
    echo $faa |tr "\n" ","
    cat /mnt/data/structuralcolourweb/models |while read model ; do 
	hit=`cat tmpout123 |grep $model` 
	if [ -z "$hit" ] ; then 
	    hit="0"
	else 
	    hit="1"
	fi
	echo $model $hit
    done | cut -f 2 -d " " |tr "\n" "," |sed 's/,$//'
    echo
done >> structuralcolourpredictionmatrix.txt

R --vanilla < /mnt/data/structuralcolourweb/classification.R

mkdir $2
mv *.txt $2/
mv tmpout123 $2/
echo "Below you will find the name of our file and two numbers. the first number is the fraction of randomForest trees that voted for non-iridescence. The second number is the fraction of votes that voted for iridescence." > results.txt
tail -n 1 $2/structuralcolourvotes.txt >> results.txt
rm index.html


echo
echo "Done!"
echo "outputfiles are structuralcolouralignments.txt, structuralcolourpredictionmatrix.txt and structuralcolourvotes.txt in the folder output"
