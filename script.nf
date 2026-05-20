nextflow.enable.dsl=2

params.fastq = "/mnt/d/bioinfo_tools/nextflow/FASTQC/fastq/*_{R1,R2}.fastq.gz"
params.qc_report = "/mnt/d/bioinfo_tools/nextflow/FASTQC/fastqc_report"
params.trim_report = "/mnt/d/bioinfo_tools/nextflow/FASTQC/trim_report"
params.assembly = "/mnt/d/bioinfo_tools/nextflow/FASTQC/assembly"
params.quast_report = "/mnt/d/bioinfo_tools/nextflow/FASTQC/quast"
params.prokka_report = "/mnt/d/bioinfo_tools/nextflow/FASTQC/prokka"


process QC_RAW {

    publishDir("${params.qc_report}/raw", mode: 'copy')

    input:
    tuple val(id), path(r1), path(r2)

    output:
    path "*"

    script:
    """
    fastqc ${r1} ${r2}
    """
}

process TRIMMING {

    publishDir("${params.trim_report}", mode: 'copy')

    conda "bioconda::trim-galore=0.6.10"

    input:
    tuple val(id), path(r1), path(r2)

    output:
    tuple val(id),
          path("*_val_1.fq.gz"),
          path("*_val_2.fq.gz")

    script:
    """
    trim_galore --paired --gzip \
        --quality 20 \
        --length 30 \
        --basename ${id} \
        ${r1} ${r2}
    """
}

process QC_TRIMMED {

    publishDir("${params.qc_report}/trimmed", mode: 'copy')

    input:
    tuple val(id), path(r1), path(r2)

    output:
    path "*"

    script:
    """
    fastqc ${r1} ${r2}
    """
}

process SPADES {

    publishDir("${params.assembly}", mode: 'copy')

    input:
    tuple val(id), path(r1), path(r2)

    output:
    tuple val(id),
          path("${id}/contigs.fasta")

    script:
    """
    spades.py \
        -1 ${r1} \
        -2 ${r2} \
        -o ${id} \
        --careful \
        -t 8 \
        -m 16
    """
}

process QUAST {

    publishDir("${params.quast_report}", mode: 'copy')

    input:
    tuple val(id), path(contigs)

    output:
    path "${id}"

    script:
    """
    quast.py \
        ${contigs} \
        -o ${id} \
        -t 4
    """
}

process PROKKA {

    publishDir("${params.prokka_report}", mode: 'copy')

    input:
    tuple val(id), path(contigs)

    output:
    tuple val(id),
          path("${id}_prokka")

    script:
    """
    prokka \
        --outdir ${id}_prokka \
        --prefix ${id} \
        --cpus 4 \
        ${contigs}
    """
}

workflow {

    fastq_ch = Channel.fromFilePairs(params.fastq, flat: true)

    QC_RAW(fastq_ch)

    trimmed_ch = TRIMMING(fastq_ch)

    QC_TRIMMED(trimmed_ch)
    
    spades_ch = SPADES(trimmed_ch)

    QUAST(spades_ch)

    PROKKA(spades_ch)
}