#! /bin/bash

mkdir -p genes_phylogenies
cd genes_phylogenies
for f in ../genes_align/align_*;
	do
		#echo ${f##*/}
		sed -i 's/(//g' ${f}
		sed -i 's/)//g' ${f}
		SlurmEasy -t 5 -m 20000 --name bash_raxml "raxmlHPC -s ${f} -n ${f##*/} -d -m PROTGAMMAAUTO --auto-prot=bic --bootstop-perms=1000 -x 12345 -p 12345 -# autoMRE -f a"
	done
	
sbatch --dependency=singleton --job-name=bash_raxml ../raxml_mock.sh

for f in ../fasta_pep/ref/*; do
	while [ ! -f ../mock/raxml_${f##*/}.mock ]; do sleep 1; done
done
