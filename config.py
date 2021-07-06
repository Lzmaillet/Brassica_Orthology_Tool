import glob

#Parametres a modifier par l'utilisateur

# Ecrire entre guillemets le chemin absolu du dossier qui contient les echantillons. Veiller a terminer par un '/'.
config['QUERY_DIR'] = "/scratch/lomaillet/RLM/fasta_pep/query/"
config['REF_DIR'] = "/scratch/lomaillet/RLM/fasta_pep/ref/"
# Ecrire entre guillemets le chemin absolu du dossier qui contient le snakefile. Veiller a terminer par un '/'.
config['WORKING_DIR'] = "/scratch/lomaillet/RLM/"
# Ecrire entre guillemets le chemin absolu de la liste de genes d'interet
config['GENES_OF_INTEREST'] = "/scratch/lomaillet/RLM/fasta_pep/genes_of_interest/Bnigra_C2.v1.B04_genes_of_interest.txt"
# Ecrire entre guillemets le type de blast demande (blastn ou blastp)
config['BLAST_TYPE'] = "blastp"



# NE PAS TOUCHER !!
config['QUERY'] = glob.glob(config['QUERY_DIR']+"*")
config['REF'] = glob.glob(config['REF_DIR']+"*")
config['GOI_DIR'] = '/'.join(config['GENES_OF_INTEREST'].split('/')[:-1]) + "/"