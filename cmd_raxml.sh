#! /bin/bash

mkdir -p genes_phylogenies
cd genes_phylogenies
for f in ../genes_align/align_*; do
	q=$(squeue -u $USER -n bash_raxml | wc -l)
	while [ $q -gt 11 ]; do
		sleep 5
		q=$(squeue -u $USER -n bash_raxml | wc -l)
	done
	sed -i 's/(//g' ${f}
	sed -i 's/)//g' ${f}
	SlurmEasy -t 5 -m 4000 --name bash_raxml "raxmlHPC -s ${f} -n ${f##*/} -d -m PROTGAMMAAUTO --auto-prot=bic --bootstop-perms=1000 -x 12345 -p 12345 -# autoMRE -f a"
done
	
sbatch --dependency=singleton --job-name=bash_raxml ../raxml_mock.sh $1

for f in $1*; do
	while [ ! -f ../mock/raxml_${f##*/}.mock ]; do sleep 1; done
done
