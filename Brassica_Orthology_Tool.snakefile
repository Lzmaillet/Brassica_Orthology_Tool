proteomesX, = glob_wildcards("fasta_pep/query/{genome}")
proteomesRef, = glob_wildcards("fasta_pep/ref/{genome}")
genes_of_interest, = glob_wildcards("fasta_pep/genes_of_interest/{genes}")

ruleorder: blastp_self > blastp_reci > selfblast_groupes_homologues > recup_genes_blast
     
rule all:
    input:
        expand("fasta_pep/blast_q{proteomeRef}_s{proteomeX}_blastp.txt", proteomeRef=proteomesRef, proteomeX=proteomesX),
        expand("fasta_pep/blast_q{proteomeX}_s{proteomeRef}_blastp.txt", proteomeRef=proteomesRef, proteomeX=proteomesX),
        expand("fasta_pep/blast_q{proteomeRef}_s{proteomeRef}_blastp.txt", proteomeRef=proteomesRef),
        expand("groupes_homologues_{proteomeRef}.txt", proteomeRef=proteomesRef),
       # expand("tables/Tableau_recap_blast_q{proteomeRef}_s{proteomeX}_blast.tsv", proteomeRef=proteomesRef, proteomeX=proteomesX),
       # expand("mock/concat_{proteomeRef}.mock", proteomeRef=proteomesRef),
       # expand("mock/list_for_seqtk_{proteomeRef}.mock", proteomeRef=proteomesRef),
       # expand("mock/seqtk_{proteomeRef}.mock", proteomeRef=proteomesRef),
       # expand("mock/mafft_{proteomeRef}.mock", proteomeRef=proteomesRef),
       # expand("mock/raxml_{proteomeRef}.mock", proteomeRef=proteomesRef)
        

rule blastp_reci:
    input:
        fastaX="fasta_pep/query/{proteomeX}",
        fastaRef="fasta_pep/ref/{proteomeRef}"
    output:
        "fasta_pep/blast_q{proteomeRef}_s{proteomeX}_blastp.txt",
        "fasta_pep/blast_q{proteomeX}_s{proteomeRef}_blastp.txt"
    params:
        prefix1="fasta_pep/blast_q{proteomeX}_s{proteomeRef}_blastp.txt",
        prefix2="fasta_pep/blast_q{proteomeRef}_s{proteomeX}_blastp.txt",
        job_name="blasp_reci",
        threads = 5,
        memory = 6144
    conda:
        "envs/blast"
    shell:
        "blastp -query {input.fastaX} -subject {input.fastaRef} -evalue 1e-20 -outfmt '6 std qlen' -out '{params.prefix1}';"
        "blastp -query {input.fastaRef} -subject {input.fastaX} -evalue 1e-20 -outfmt '6 std qlen' -out '{params.prefix2}';"

rule blastp_self:
    input:
        fastaRef="fasta_pep/ref/{proteomeRef}"
    output:
        "fasta_pep/blast_q{proteomeRef}_s{proteomeRef}_blastp.txt"
    params:
        prefix="fasta_pep/blast_q{proteomeRef}_s{proteomeRef}_blastp.txt",
        job_name="blasp_self",
        threads = 5,
        memory = 6144
    conda:
        "envs/blast"
    shell:
        "blastp -query {input.fastaRef} -subject {input.fastaRef} -evalue 1e-20 -outfmt '6 std qlen' -out '{params.prefix}';"
        
        
rule selfblast_groupes_homologues:
    input:
        selfblast="fasta_pep/blast_q{proteomeRef}_s{proteomeRef}_blastp.txt"
    output:
        "groupes_homologues_{proteomeRef}.txt"
    params:
        prefix="groupes_homologues_{proteomeRef}.txt",
        gene_list=genes_of_interest,
        job_name="selfblast_groupes_homologues",
        threads = 5,
        memory = 6144
    shell:
        "python3.7 script_selfblast_homologroups_table.py  -s {input.selfblast} -n {params.prefix} -g fasta_pep/genes_of_interest/{params.gene_list} -i 80 -l 80"     

rule recup_genes_blast:
    input:
        blastRefX="fasta_pep/blast_q{proteomeRef}_s{proteomeX}_blastp.txt",
        blastXRef="fasta_pep/blast_q{proteomeX}_s{proteomeRef}_blastp.txt"
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
        job_name="seqtk",
        threads = 5,
        memory = 6144
    shell:
        "bash cmd_automated_seqtk.sh;"
        "touch mock/seqtk_{wildcards.proteomeRef}.mock"

rule mafft:
    input:
        "mock/seqtk_{proteomeRef}.mock"
    output:
        temp("mock/mafft_{proteomeRef}.mock")
    params:
        job_name="mafft",
        threads = 5,
        memory = 20480
    shell:
        "bash cmd_mafft.sh;"

rule raxml:
    input:
        "mock/mafft_{proteomeRef}.mock"
    output:
        temp("mock/raxml_{proteomeRef}.mock")
    params:
        job_name="raxml",
        threads = 5,
        memory = 20480
    shell:
        "bash cmd_raxml.sh;"
