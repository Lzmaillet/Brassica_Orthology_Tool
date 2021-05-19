#! /bin/bash

for f in ../fasta_pep/ref/*; do
	touch mock/mafft_${f##*/}.mock
done
