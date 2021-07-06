#! /bin/bash

mkdir -p genes_align/
for f in ./genes_sequences/sequence_*; do
	q=$(squeue -u $USER -n bash_mafft | wc -l)
	while [ $q -gt 11 ]; do
        sleep 5
        q=$(squeue -u $USER -n bash_mafft | wc -l)
    done
	SlurmEasy --name bash_mafft -t 5 -m 4G "linsi --anysymbol --adjustdirectionaccurately $f > genes_align/align_${f##*/}"
done
	
sbatch --dependency=singleton --job-name=bash_mafft mafft_mock.sh $1

for f in $1*; do
	while [ ! -f ./mock/mafft_${f##*/}.mock ]; do sleep 1; done
done
