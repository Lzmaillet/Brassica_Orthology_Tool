"""
Script commencé le 12/03/2021
Par Loeiz Maillet
Fichier d'entrée: 
	- fichier de sortie de selfblast
Fichier de sortie:
	- Fichier de groupes de genes homologues
Permet de:
	- Creer des groupes de genes homologues
"""

import os
import sys
import argparse

# Recuperation des parametres d'entree fixes par l'utilisateur (ou par defaut)
#Definie des options et des valeurs par defaut
parser = argparse.ArgumentParser()
parser.add_argument('-s','--selfblast', action='store', type=argparse.FileType('r'), default=False, required=True, help="Nom du selfblast. Requis.")
parser.add_argument('-g','--genes', action='store', type=argparse.FileType('r'), default=False, required=False, help="Nom de la liste de genes d'interets. Si non fourni, le script sera applique sur tout le genome")
parser.add_argument('-i','--identity', action='store', type=int, default=80, required=False, help="Seuil d'identite. 80% par defaut")
parser.add_argument('-l','--length', action='store', type=int, default=80, required=False, help="Seuil de longueur. 80% par defaut")
parser.add_argument('-n','--nom', action='store', type=str, default=False, required=True, help='Nom du fichier de sortie. Requis.')
args = parser.parse_args()
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Parsing du fichier tabule, filtre 60% ident, 60% longueur, on ne garde que les noms
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
liste = []
if args.genes != False:
	with args.genes as file:
		for x in file:
			liste.append(x.replace('\n',''))
			
selfblast = []
dico_genes = {}
with args.selfblast as file:
	for x in file:
		x = x.replace('\n','').split("\t")
		if (float(x[2]) >= args.identity and 100 * float(x[3]) / float(x[-1]) >= args.length) and (x[0] in liste or x[1] in liste):
			selfblast.append(x[:2])
			if x[0] not in dico_genes:
				dico_genes[x[0]] = []
			if x[1] not in dico_genes:
				dico_genes[x[1]] = []
							
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Creation des groupes
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#Pour chaque gene, trouver tous les matchs
for name in dico_genes.keys():
	for line in selfblast:
		for gene in line:
			if name == gene:
				for part in line:
					if part not in dico_genes[name]:
						dico_genes[name] = dico_genes[name]+[part]

#Pour chaque match d'un gene, ajouter les match du match
for x,y in dico_genes.items():
	a = 0
	#ok = 0
	while a < len(dico_genes[x]):
		for z in dico_genes[dico_genes[x][a]]:
			if z not in dico_genes[x]:
				dico_genes[x] = dico_genes[x] + [z]
				a = 0
		a += 1

#Supprimer la redondance	
out = []
for x in dico_genes.values():
	if set(x) not in out:
		out.append(set(x))
		
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Creation du fichier de sortie homologie
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
name = args.nom	
fichier = open(name, "w+")
group = 0
for i in out:
	group += 1
	for j in i:
		fichier.write(str(j) + '\t' + str(group) + '\n')
