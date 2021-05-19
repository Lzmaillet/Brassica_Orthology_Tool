#! /bin/bash

mkdir -p genes_align/
for f in ./genes_sequences/sequence_*;
	do
		SlurmEasy --name bash_mafft -t 5 -m 20000 "linsi --anysymbol --adjustdirectionaccurately $f > genes_align/align_${f##*/}"
	done
	
sbatch --dependency=singleton --job-name=bash_mafft mafft_mock.sh

for f in ./fasta_pep/ref/*; do
	while [ ! -f ./mock/mafft_${f##*/}.mock ]; do sleep 1; done
done