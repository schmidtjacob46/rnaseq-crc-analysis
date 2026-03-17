#!/usr/bin/env bash
set -euo pipefail

# Download full paired-end FASTQs for SRR accessions listed in data/sra/srr_list.txt
# Outputs: data/fastq/<SRR>_1.fastq.gz and data/fastq/<SRR>_2.fastq.gz
# Logs: logs/download_fastq.log

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRR_LIST="${PROJECT_ROOT}/data/sra/srr_list.txt"
OUTDIR="${PROJECT_ROOT}/data/fastq"
LOGDIR="${PROJECT_ROOT}/logs"
LOGFILE="${LOGDIR}/download_fastq.log"

mkdir -p "${OUTDIR}" "${LOGDIR}"

echo "[$(date)] Starting FASTQ download" | tee -a "${LOGFILE}"
echo "SRR list: ${SRR_LIST}" | tee -a "${LOGFILE}"
echo "Output dir: ${OUTDIR}" | tee -a "${LOGFILE}"

# Basic checks
command -v prefetch >/dev/null 2>&1 || { echo "ERROR: prefetch not found in PATH" | tee -a "${LOGFILE}"; exit 1; }
command -v fasterq-dump >/dev/null 2>&1 || { echo "ERROR: fasterq-dump not found in PATH" | tee -a "${LOGFILE}"; exit 1; }
command -v pigz >/dev/null 2>&1 || { echo "ERROR: pigz not found in PATH" | tee -a "${LOGFILE}"; exit 1; }
[[ -f "${SRR_LIST}" ]] || { echo "ERROR: SRR list not found: ${SRR_LIST}" | tee -a "${LOGFILE}"; exit 1; }

while read -r SRR; do
  [[ -z "${SRR}" ]] && continue
  echo "[$(date)] Downloading ${SRR}" | tee -a "${LOGFILE}"

  # Fetch SRA file locally (more reliable on clusters)
  prefetch "${SRR}" --max-size 100G 2>&1 | tee -a "${LOGFILE}"

  # Convert to FASTQ (paired-end => _1 and _2)
  fasterq-dump "${SRR}" \
    --split-files \
    --threads 8 \
    -O "${OUTDIR}" 2>&1 | tee -a "${LOGFILE}"

  # Compress FASTQs and remove uncompressed versions
  pigz -p 8 "${OUTDIR}/${SRR}"*.fastq

  echo "[$(date)] Finished ${SRR}" | tee -a "${LOGFILE}"
done < "${SRR_LIST}"

echo "[$(date)] All downloads complete" | tee -a "${LOGFILE}"
echo "FASTQ file count: $(ls -1 "${OUTDIR}"/*.fastq.gz 2>/dev/null | wc -l)" | tee -a "${LOGFILE}"
