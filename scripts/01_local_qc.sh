#!/bin/bash
set -euo pipefail

# =========================
# DETECT REPO ROOT
# =========================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# =========================
# LOAD CONFIG
# =========================
CONFIG_FILE=${CONFIG_FILE:-"$REPO_ROOT/config/config.env"}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# =========================
# PROJECT DIR (CRÍTICO)
# =========================
PROJECT_NAME=${PROJECT_NAME:-default_project}

if [ -n "${PROJECT_DIR:-}" ]; then
    # viene desde run_pipeline.sh
    echo "Using provided PROJECT_DIR: $PROJECT_DIR"
else
    # modo standalone
    PROJECT_DIR="$REPO_ROOT/data/$PROJECT_NAME"
    echo "No PROJECT_DIR provided, using default: $PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"

# =========================
# INPUT
# =========================
LOCAL_RAW_DIR=${1:-}

if [ -z "$LOCAL_RAW_DIR" ]; then
    echo "Usage: bash 01_local_qc.sh <path_to_raw_fastq_dir>"
    exit 1
fi

LOCAL_RAW_DIR="$(realpath "$LOCAL_RAW_DIR")"

if [ ! -d "$LOCAL_RAW_DIR" ]; then
    echo "ERROR: Directory not found: $LOCAL_RAW_DIR"
    exit 1
fi

echo "Using local data from: $LOCAL_RAW_DIR"

# =========================
# NORMALIZE PATHS (PROJECT-AWARE)
# =========================
#RAW_DIR="$REPO_ROOT/$RAW_DIR"
#QC_DIR="$REPO_ROOT/$QC_DIR"
#CLEAN_DIR="$REPO_ROOT/$CLEAN_DIR"
#LOG_DIR="$REPO_ROOT/$LOG_DIR"

DATA_DIR="$PROJECT_DIR"
RAW_DIR="$DATA_DIR/raw"
QC_DIR="$DATA_DIR/filtered_reads"
CLEAN_DIR="$DATA_DIR/clean_reads"
LOG_DIR="$DATA_DIR/logs"
DBS_DIR="$REPO_ROOT/$DBS_DIR"
PHIX_INDEX="$REPO_ROOT/$PHIX_INDEX"
HG_INDEX="$REPO_ROOT/$HG_INDEX"

mkdir -p "$RAW_DIR" "$QC_DIR" "$CLEAN_DIR" "$LOG_DIR"

# =========================
# STEP 1: VALIDATE & LINK FILES
# =========================
echo "Validating FASTQ pairs..."

> "$RAW_DIR/samples.tmp"

for r1 in "$LOCAL_RAW_DIR"/*_R1*.fastq.gz "$LOCAL_RAW_DIR"/*_1.fastq.gz; do
    [ -e "$r1" ] || continue

    base=$(basename "$r1")

    # infer sample ID
    sample=$(echo "$base" | sed -E 's/_R?1.*//')

    # detectar R2
    r2="${r1/_R1/_R2}"
    r2="${r2/_1.fastq.gz/_2.fastq.gz}"

    if [ ! -f "$r2" ]; then
        echo "WARNING: Missing pair for $r1 — skipping"
        continue
    fi

    echo "Sample detected: $sample"

    # linkear (no copiar → más eficiente)
    ln -sf "$r1" "$RAW_DIR/${sample}_read_1.fastq.gz"
    ln -sf "$r2" "$RAW_DIR/${sample}_read_2.fastq.gz"

    echo "$sample" >> "$RAW_DIR/samples.tmp"

done

# validar que haya muestras
if [ ! -s "$RAW_DIR/samples.tmp" ]; then
    echo "ERROR: No valid paired FASTQ files found"
    exit 1
fi

echo "Samples ready:"
cat "$RAW_DIR/samples.tmp"

# =========================
# STEP 2: FASTQ INTEGRITY
# =========================
echo "Checking FASTQ integrity..."

for f in "$RAW_DIR"/*.fastq.gz; do
    if ! gzip -t "$f"; then
        echo "ERROR: Corrupted file: $f"
        exit 1
    fi
done

echo "Integrity check passed"

# =========================
# STEP 3: FASTP
# =========================
echo "Running fastp..."

while read -r S; do
    echo "Processing sample: $S"

    fastp \
        -i "${RAW_DIR}/${S}_read_1.fastq.gz" \
        -I "${RAW_DIR}/${S}_read_2.fastq.gz" \
        -o "${QC_DIR}/${S}_filtered_1.fastq.gz" \
        -O "${QC_DIR}/${S}_filtered_2.fastq.gz" \
        --thread "$THREADS" \
        --qualified_quality_phred=20 \
        --length_required=75 \
        --json "${LOG_DIR}/${S}.json" \
        --html "${LOG_DIR}/${S}.html"

done < "$RAW_DIR/samples.tmp"

echo "QC completed"

# =========================
# STEP 4: CONTAMINATION REMOVAL
# =========================
echo "Removing contaminants..."

if [ ! -f "${PHIX_INDEX}.1.bt2" ]; then
    echo "ERROR: PHIX index not found"
    exit 1
fi

if [ ! -f "${HG_INDEX}.1.bt2" ]; then
    echo "ERROR: HG index not found"
    exit 1
fi

while read -r S; do
    echo "Cleaning $S (PhiX)"

    bowtie2 -x "$PHIX_INDEX" \
        -1 "${QC_DIR}/${S}_filtered_1.fastq.gz" \
        -2 "${QC_DIR}/${S}_filtered_2.fastq.gz" \
        --un-conc "${CLEAN_DIR}/${S}_phix_unm.fastq" \
        -p "$THREADS" \
        -S /dev/null

    echo "Cleaning $S (Human)"

    bowtie2 -x "$HG_INDEX" \
        -1 "${CLEAN_DIR}/${S}_phix_unm.1.fastq" \
        -2 "${CLEAN_DIR}/${S}_phix_unm.2.fastq" \
        --un-conc "${CLEAN_DIR}/${S}_clean.fastq" \
        -p "$THREADS" \
        -S /dev/null

done < "$RAW_DIR/samples.tmp"

rm "$RAW_DIR/samples.tmp"

echo "Module 1 (LOCAL MODE) completed successfully"
