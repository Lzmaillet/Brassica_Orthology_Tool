#! bin/bash

python3.7 script_concat_table.py -n $1 -r $2

mkdir -p mock
touch $3
