#! /bin/bash

for f in $1*; do
	touch ./mock/raxml_${f##*/}.mock
done