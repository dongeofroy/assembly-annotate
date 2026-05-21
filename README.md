Nextflow Pipeline/FASTQ Processing, Assembly & Annotation

1- Description
Ce projet implémente un pipeline Nextflow (DSL2) pour l’analyse complète de données de séquençage paired-end d'un génome bactérien à partir de fichiers FASTQ.
Le workflow automatise les étapes suivantes :
Contrôle qualité des reads bruts (FastQC)
Nettoyage des reads (Trim Galore)
Contrôle qualité après trimming (FastQC)
Assemblage du génome (SPAdes)
Évaluation de l’assemblage (QUAST)
Annotation du génome (Prokka)

2- Structure des entrées
Le pipeline attend des fichiers FASTQ compressés au format :
*_R1.fastq.gz
*_R2.fastq.gz
Exemple:
sample1_R1.fastq.gz
sample1_R2.fastq.gz

3- Créer l'envirronement:
conda env create -f environment.yml
conda activate nextflow

4- Lancement du pipeline
nextflow run script.nf

5- Paramètres
Les principaux paramètres sont définis dans le script :
params.fastq
params.qc_report
params.trim_report
params.assembly
params.quast_report
params.prokka_report
Vous pouvez les modifier directement dans le fichier ou via CLI :
Exemple:
nextflow run script.nf --fastq "/path/to/data/*_{R1,R2}.fastq.gz"

5- Gestion des environnements
Assure-toi d’avoir activé :
conda config --add channels bioconda
conda config --add channels conda-forge

6- Auteur:
Projet réalisé par Géofroy KINHOEGBE dans un contexte de bioinformatique appliquée à l’analyse de données de séquençage.
