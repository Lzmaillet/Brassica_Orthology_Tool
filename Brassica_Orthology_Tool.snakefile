include: 'config.py'

proteomeX=[]
for x in config['QUERY']:
    tmp = x.split('/')[-1]
    proteomeX.append(tmp) 

proteomeRef=[]
for x in config['REF']:
    tmp = x.split('/')[-1]
    proteomeRef.append(tmp)
    
genes_of_interest = config['GENES_OF_INTEREST'].split('/')[-1]
working_dir = config['WORKING_DIR']
query_dir = config['QUERY_DIR']
ref_dir = config['REF_DIR']
blast_type = config['BLAST_TYPE']
goi_dir = config['GOI_DIR']

ruleorder: blastp_self > blastp_reci > selfblast_groupes_homologues > recup_genes_blast
     
rule all:
    input:
        expand("blast/blast_q{proteomeRef}_s{proteomeX}_" + str(blast_type) + ".txt", proteomeRef=proteomeRef, proteomeX=proteomeX),
        expand("blast/blast_q{proteomeX}_s{proteomeRef}_" + str(blast_type) + ".txt", proteomeRef=proteomeRef, proteomeX=proteomeX),
        expand("blast/blast_q{proteomeRef}_s{proteomeRef}_" + str(blast_type) + ".txt", proteomeRef=proteomeRef),
        expand("groupes_homologues_{proteomeRef}.txt", proteomeRef=proteomeRef),
        expand("tables/Tableau_recap_blast_q{proteomeRef}_s{proteomeX}_blast.tsv", proteomeRef=proteomeRef, proteomeX=proteomeX),
        expand("mock/concat_{proteomeRef}.mock", proteomeRef=proteomeRef),
        expand("mock/list_for_seqtk_{proteomeRef}.mock", proteomeRef=proteomeRef),
        expand("mock/seqtk_{proteomeRef}.mock", proteomeRef=proteomeRef),
        expand("mock/mafft_{proteomeRef}.mock", proteomeRef=proteomeRef),
        expand("mock/raxml_{proteomeRef}.mock", proteomeRef=proteomeRef)
        

rule blastp_reci:
    input:
        fastaX=str(query_dir) + "{proteomeX}",
        fastaRef=str(ref_dir) + "{proteomeRef}"
    output:
        RefX = "blast/blast_q{proteomeRef}_s{proteomeX}_" + str(blast_type) + ".txt",
        XRef = "blast/blast_q{proteomeX}_s{proteomeRef}_" + str(blast_type) + ".txt"
    params:
        type = blast_type,
        job_name="blast_reci",
        threads = 5,
        memory = 6144
    shell:
        "{params.type} -query {input.fastaX} -subject {input.fastaRef} -evalue 1e-20 -outfmt '6 std qlen' -out '{output.XRef}';"
        "{params.type} -query {input.fastaRef} -subject {input.fastaX} -evalue 1e-20 -outfmt '6 std qlen' -out '{output.RefX}';"

rule blastp_self:
    input:
        fastaRef=str(ref_dir) + "{proteomeRef}"
    output:
        "blast/blast_q{proteomeRef}_s{proteomeRef}_" + str(blast_type) + ".txt"
    params:
        prefix="blast/blast_q{proteomeRef}_s{proteomeRef}_" + str(blast_type) + ".txt",
        job_name="blast_self",
        threads = 5,
        memory = 6144
    shell:
        "blastp -query {input.fastaRef} -subject {input.fastaRef} -evalue 1e-20 -outfmt '6 std qlen' -out '{params.prefix}';"
        
        
rule selfblast_groupes_homologues:
    input:
        selfblast="blast/blast_q{proteomeRef}_s{proteomeRef}_" + str(blast_type) + ".txt"
    output:
        "groupes_homologues_{proteomeRef}.txt"
    params:
        prefix="groupes_homologues_{proteomeRef}.txt",
        gene_list=genes_of_interest,
        goidir = goi_dir,
        job_name="selfblast_groupes_homologues",
        threads = 5,
        memory = 6144
    shell:
        "python3.7 script_selfblast_homologroups_table.py  -s {input.selfblast} -n {params.prefix} -g {params.goidir}{params.gene_list} -i 80 -l 80"     

rule recup_genes_blast:
    input:
        blastRefX="blast/blast_q{proteomeRef}_s{proteomeX}_" + str(blast_type) + ".txt",
        blastXRef="blast/blast_q{proteomeX}_s{proteomeRef}_" + str(blast_type) + ".txt"
    output:
        "tables/Tableau_recap_blast_q{proteomeRef}_s{proteomeX}_blast.tsv"
    params:
        liste="groupes_homologues_{proteomeRef}.txt",
        out="Tableau_recap_blast_q{proteomeRef}_s{proteomeX}_blast.tsv",
        job_name="recup_genes_blast",
        threads = 5,
        memory = 6144
    shell:
        "mkdir -p tables/;"
        "cd tables/;"
        "python3.7 ../script_recup_genes_blast_table.py -a ../{input.blastRefX} -b ../{input.blastXRef} -t ../{params.liste} -q {wildcards.proteomeX} -r {wildcards.proteomeRef} -i 60 -l 60 -n {params.out}"

rule concat_table:
    #input:
    #    "tables/Tableau_recap_blast_q{proteomeRef}_s{proteomeX}_blast.tsv"
    output:
        temp("mock/concat_{proteomeRef}.mock")
    params:
        ref="{proteomeRef}",
        out="Tableau_recap_blasts.tsv",
        mock="mock/concat_{proteomeRef}.mock",
        job_name="concat_table",
        threads = 5,
        memory = 6144
    shell:
        "python3.7 script_concat_table.py -n {params.out} -r {params.ref};"
        "touch {params.mock}"

rule list_for_seqtk_table:
    input:
        "mock/concat_{proteomeRef}.mock"
    output:
        temp("mock/list_for_seqtk_{proteomeRef}.mock")
    params:
        table = "Tableau_recap_blasts.tsv",
        job_name="list_for_seqtk_table",
        threads = 5,
        memory = 6144
    shell:
        "mkdir -p genes_lists/;"
        "cd genes_lists/;"
        "python3.7 ../script_list_for_seqtk_table.py -t ../{params.table};"
        "touch ../{output}"
        
rule seqtk:
    input:
        "mock/list_for_seqtk_{proteomeRef}.mock"
    output:
        temp("mock/seqtk_{proteomeRef}.mock")
    params:
        qdir = "query_dir",
        rdir = "ref_dir",
        job_name="seqtk",
        threads = 5,
        memory = 6144
    shell:
        "bash cmd_automated_seqtk.sh {params.query_dir} {params.rdir};"
        "touch mock/seqtk_{wildcards.proteomeRef}.mock"

rule mafft:
    input:
        "mock/seqtk_{proteomeRef}.mock"
    output:
        temp("mock/mafft_{proteomeRef}.mock")
    params:
        rdir = "ref_dir",
        job_name="mafft",
        threads = 1,
        memory = 1000
    shell:
        "bash cmd_mafft.sh {params.rdir};"

rule raxml:
    input:
        "mock/mafft_{proteomeRef}.mock"
    output:
        temp("mock/raxml_{proteomeRef}.mock")
    params:
        rdir = "ref_dir",
        job_name="raxml",
        threads = 1,
        memory = 1000
    shell:
        "bash cmd_raxml.sh {params.rdir};"
