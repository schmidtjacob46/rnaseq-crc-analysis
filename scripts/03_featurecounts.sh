#!/usr/bin/env bash
set -euo pipefail

source ~/miniconda3/etc/profile.d/conda.sh
conda activate rnaseq

THREADS=8
GTF="reference/gencode.v26.annotation.gtf"
OUT="counts/gene_counts.txt"

mkdir -p counts logs

echo "Running featureCounts..."

featureCounts \
  -T $THREADS \
  -a $GTF \
  -o $OUT \
  -g gene_id \
  -t exon \
  -p \
  -s 0 \
  align/star/*Aligned.sortedByCoord.out.bam \
  2>&1 | tee logs/featurecounts.log

echo "Done."
