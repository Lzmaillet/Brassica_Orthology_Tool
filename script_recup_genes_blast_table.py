"""
Script commencé le 11/05/2020
Par Loeiz Maillet
Fichier d'entrée: 
	- fichier de sortie de blast Ref/Query en 1er argument et Query/Ref en second argument
	- liste de nom de genes
Fichier de sortie:
	- Liste de noms de gènes
Permet de:
	-Recuperer le nom des genes qui donnent un resultat
"""

import os
import sys
import argparse
import pandas as pd
#import time 
#tmps1=time.time()

# Recuperation des parametres d'entree fixes par l'utilisateur (ou par defaut)
#Definie des options et des valeurs par defaut
parser = argparse.ArgumentParser()
parser.add_argument('-a','--blastRefQuery', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier du blast AT/DARV5. Requis.')
parser.add_argument('-b','--blastQueryRef', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier du blast DarV5/AT. Requis')
parser.add_argument('-t','--table', action='store', type=argparse.FileType('r'), default=False, required=True, help='Nom du fichier de liste. Requis')
parser.add_argument('-q','--query', action='store', type=str, default=False, required=True, help='Nom du genome query. Requis')
parser.add_argument('-r','--ref', action='store', type=str, default=False, required=True, help='Nom du genome ref. Requis')
parser.add_argument('-i','--identity', action='store', type=int, default=60, required=False, help="Seuil d'identite. 60% par defaut")
parser.add_argument('-l','--length', action='store', type=int, default=60, required=False, help="Seuil de longueur. 60% par defaut")
parser.add_argument('-n','--nom', action='store', type=str, default='forgot_to_name_the_output', required=False, help='Suffixe du nom du fichier de sortie')
args = parser.parse_args()

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Parsing des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

liste = []
with args.table as file:
	for x in file:
		liste.append(x.replace('\n','').split('\t'))
		
df_table = pd.DataFrame(liste, columns=[args.ref.split('/')[-1],'group'])

blastRefQuery = []
with args.blastRefQuery as file:
	for x in file:
		x = x.replace('\n','').split('\t')
		if float(x[2]) >= args.identity:
			if float(x[3]) * 100 / float(x[-1]) >= args.length:
				blastRefQuery.append(x[:2])
				
df1 = pd.DataFrame(blastRefQuery, columns=[args.ref.split('/')[-1],args.query.split('/')[-1]])


blastQueryRef = []
with args.blastQueryRef as file:
	for x in file:
		x = x.replace('\n','').split('\t')
		if float(x[2]) >= args.identity:
			if float(x[3]) * 100 / float(x[-1]) >= args.length:
				blastQueryRef.append(x[:2])
				
df2 = pd.DataFrame(blastQueryRef, columns=[args.query.split('/')[-1],args.ref.split('/')[-1]])				

frames = [df1, df2]
ddf = pd.concat(frames)
df = ddf.drop_duplicates().reset_index(drop = True)

df_blast = df.groupby(args.ref.split('/')[-1])[args.query.split('/')[-1]].apply(','.join).reset_index()

df_final = df_table.merge(df_blast, on=args.ref.split('/')[-1], how='left')

					
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Output des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fichier = open(str(args.nom), "w+")			
fichier.write(df_final.to_csv(sep = '\t', index = False))

#print((time.time()-tmps1)/60)
