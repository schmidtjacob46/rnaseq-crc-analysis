# Bulk RNA-seq Differential Expression Pipeline in Colorectal Cancer

## Project Overview
This project implements an end-to-end bulk RNA-seq analysis workflow using matched colorectal tumor and normal samples from a public dataset. The pipeline starts from raw FASTQ files and proceeds through quality control, alignment, gene-level quantification, and differential expression analysis.

## Objective
Identify genes differentially expressed between colorectal tumor and matched normal tissue and demonstrate a reproducible RNA-seq workflow suitable for a bioinformatics portfolio.

## Dataset
Public colorectal cancer RNA-seq dataset with matched tumor and normal samples selected from SRA/GEO.

Samples used:
- P01_Normal
- P01_Tumor
- P02_Normal
- P02_Tumor
- P03_Normal
- P03_Tumor

## Workflow
1. Sample selection from RunInfo metadata
2. FASTQ download from SRA
3. Quality control with FastQC and MultiQC
4. Alignment to GRCh38 with STAR
5. Gene-level quantification with featureCounts
6. Differential expression analysis with DESeq2
7. Annotation of significant genes using GENCODE v26

## Tools Used
- Bash
- STAR
- featureCounts
- FastQC
- MultiQC
- R
- DESeq2

## Key Outputs
- `results/pca_plot.png`
- `results/volcano_plot.png`
- `results/deseq2_results_annotated.csv`
- `results/top_upregulated_genes.csv`
- `results/top_downregulated_genes.csv`

## Example Findings
Upregulated tumor-associated genes included:
- ETV4
- LGR5
- FOXQ1
- CEMIP

Downregulated genes included:
- SFRP1
- CLCA4
- TMIGD1
- BMP3
- SCNN1B

These findings are biologically plausible for colorectal tumor versus normal comparisons and support the validity of the workflow.

## Reproducibility
Scripts are provided for:
- FASTQ download
- alignment
- gene counting
- DESeq2 analysis

## Future Improvements
- Add heatmap visualization
- Add pathway enrichment analysis
- Expand sample size
- Convert scripts into a workflow manager such as Snakemake or Nextflow
