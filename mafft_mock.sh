#! /bin/bash

for f in $1*; do
	touch mock/mafft_${f##*/}.mock
done
