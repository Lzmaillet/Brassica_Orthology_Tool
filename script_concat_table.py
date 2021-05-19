"""
Script commencé le 11/05/2021
Par Loeiz Maillet
Fichier d'entrée: 
	- Les tableaux doivent être présents dans ./tables/. Pas de fichiers d'entree a proprement parler
Fichier de sortie:
	- Tableau avec tous les resultats de blasts
Permet de:
	- Concatener tous les dataframes
"""

import os
import sys
import argparse
import pandas as pd
import glob

# Recuperation des parametres d'entree fixes par l'utilisateur (ou par defaut)
#Definie des options et des valeurs par defaut
parser = argparse.ArgumentParser()
parser.add_argument('-n','--nom', action='store', type=str, default='forgot_to_name_the_output', required=False, help='Nom du fichier de sortie')
parser.add_argument('-r','--ref', action='store', type=str, default=False, required=True, help='Nom du genome ref. Requis')
args = parser.parse_args()

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Parsing des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
data = [pd.read_csv(f, sep = '\t') for f in glob.glob("./tables/*")]
df = pd.DataFrame(columns=[args.ref.split('/')[-1]])
for d in data:
    cols = [x for x in d.columns if x not in df.columns or x == args.ref.split('/')[-1]]
    df = pd.merge(df, d[cols], on=args.ref.split('/')[-1], how='outer', suffixes=['','']) 	
				
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Output des fichiers
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fichier = open(str(args.nom), "w+")			
fichier.write(df.to_csv(sep = '\t', index = False))