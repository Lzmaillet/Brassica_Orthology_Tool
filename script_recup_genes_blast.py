"""
Script commencé le 25/08/2020
Par Loeiz Maillet
Fichier d'entrée: 
	- fichier de sortie de blast AT/DarV5 en 1er argument et DarV5/AT en second argument
	- liste de nom de genes
Fichier de sortie:
	- Liste de noms de gènes
Permet de:
	-Recuperer le nom des genes qui donnent un resultat pour 7 genes d'AT
"""

import os
import sys
import argparse
import time 
tmps1=time.time()

# Recuperation des parametres d'entree fixes par l'utilisateur (ou par defaut)
#Definie des options et des valeurs par defaut
parser = argparse.ArgumentParser()
parser.add_argument('-a','--blastATDar5', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier du blast AT/DARV5. Requis.')
parser.add_argument('-b','--blastDar5AT', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier du blast DarV5/AT. Requis')
parser.add_argument('-l','--liste', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier de liste. Requis')
parser.add_argument('-n','--nom', action='store', type=str, default='_specie_epi', required=False, help='Suffixe du nom du fichier de sortie')
args = parser.parse_args()

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Parsing des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

dico_liste = {}
with args.liste as file:
	for x in file:
		x = x.replace('\n','')
		dico_liste[x] = x.split('\t')[:-1]
		
blastATDar5 = []
with args.blastATDar5 as file:
	for x in file:
		x = x.replace('\n','').split('\t')
		blastATDar5.append(x)
		
blastDar5AT = []
with args.blastDar5AT as file:
	for x in file:
		x = x.replace('\n','').split('\t')
		blastDar5AT.append(x)
		
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Filtre 60% ident 60% longueur
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

for x,y in dico_liste.items():
	for z in y:
		for w in blastATDar5:
			if z == w[0]:
				if float(w[2]) >= 60:
					if float(w[3]) * 100 / float(w[-1]) >= 60:
						if w[1] not in dico_liste[x]:
							dico_liste[x].append(w[1])
		for v in blastDar5AT:
			if z == v[1]:
				if float(v[2]) >= 60:
					if float(v[3]) * 100 / float(v[-1]) >= 60:
						if v[1] not in dico_liste[x]:
							dico_liste[x].append(v[1])
					
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Output des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
for x,y in dico_liste.items():
	fichier = open(str(x.replace('\t','_'))[:200]+str(args.nom), "w+")
	for z in y:
		fichier.write(str(z)+'\n')
		
