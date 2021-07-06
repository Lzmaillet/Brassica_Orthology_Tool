#! /bin/bash

for f in genes_lists/*; do
	mkdir -p genes_sequences
	for g in $1*; do
			seqtk subseq $g $f | awk '/^>/{f=!d[$1];d[$1]=1}f' > genes_sequences/temp_${g##*/}_${f##*/}.fa
		done
	for h in $2*; do
			seqtk subseq $h $f | awk '/^>/{f=!d[$1];d[$1]=1}f' > genes_sequences/temp_${h##*/}_${f##*/}.fa
		done
	cat genes_sequences/temp_*_${f##*/}.fa > genes_sequences/sequence_${f##*/}.fa
	rm genes_sequences/temp_*
done
