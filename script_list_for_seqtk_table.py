"""
Script commencé le 11/05/2021
Par Loeiz Maillet
Fichier d'entrée: 
	- tableau de resultats de blasts
Fichier de sortie:
	- fichiers fasta
Permet de:
	- Extrait les sequences de chaque genes d'un groupe
"""

import os
import sys
import argparse
import pandas as pd
import glob


# Recuperation des parametres d'entree fixes par l'utilisateur (ou par defaut)
#Definie des options et des valeurs par defaut
parser = argparse.ArgumentParser()
parser.add_argument('-t','--table', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier de liste. Requis')
args = parser.parse_args()

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Parsing des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
df = pd.read_csv(args.table, sep = '\t')
#print(df)
#print(len(df.columns))
#print(df.loc[df.index[-1],  "group"])
#print(df.loc[df['group'] == 1])
#print(df.iloc[df["group"].values == 1, 0])

for i in range(1,int(df.loc[df.index[-1],"group"]),1):
	temp = []
	for j in [0] + list(range(2,len(df.columns))):
		for x in df.iloc[df["group"].values == i, j].tolist():
			try:
				for y in x.split(','):
					if y not in temp:
						temp.append(y)
			except:
				pass
	name = "group_" + str(i)
	fichier = open(name, "w+")
	for z in temp:
		fichier.write(z+"\n")
				