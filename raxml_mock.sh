#! /bin/bash

for f in ../fasta_pep/ref/*; do
	touch ../mock/raxml_${f##*/}.mock
done