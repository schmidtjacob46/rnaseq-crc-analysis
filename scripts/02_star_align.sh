#!/usr/bin/env bash
set -euo pipefail

THREADS=16
INDEX_DIR="reference/star_index"
FASTQ_DIR="data/fastq"
OUT_DIR="align/star"
LOG_DIR="logs/star"

mkdir -p "$OUT_DIR" "$LOG_DIR"

# This file maps sample_id -> SRR
SHEET="data/sra/sample_sheet.csv"

# Extract sample_id and Run columns (skip header)
tail -n +2 "$SHEET" | while IFS=',' read -r sample_id run condition pair_id age tissue source tumor_stage bytes avgspot layout; do
  SRR="$run"
  R1="${FASTQ_DIR}/${SRR}_1.fastq.gz"
  R2="${FASTQ_DIR}/${SRR}_2.fastq.gz"

  echo "[$(date)] Aligning ${sample_id} (${SRR})" | tee -a "${LOG_DIR}/run.log"

  STAR \
    --runThreadN "$THREADS" \
    --genomeDir "$INDEX_DIR" \
    --readFilesIn "$R1" "$R2" \
    --readFilesCommand zcat \
    --outFileNamePrefix "${OUT_DIR}/${sample_id}_" \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMattributes NH HI AS nM XS \
    --quantMode GeneCounts \
    --twopassMode Basic \
    2>&1 | tee "${LOG_DIR}/${sample_id}.STAR.log"

done
