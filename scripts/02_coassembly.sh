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
# PROJECT HANDLING
# =========================
PROJECT_NAME=${PROJECT_NAME:-default_project}

if [ -n "${PROJECT_DIR:-}" ]; then
    echo "Using provided PROJECT_DIR: $PROJECT_DIR"
else
    PROJECT_DIR="$REPO_ROOT/data/$PROJECT_NAME"
    echo "No PROJECT_DIR provided, using default: $PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"

# =========================
# NORMALIZE PATHS (PROJECT-AWARE)
# =========================
CLEAN_DIR="$PROJECT_DIR/clean_reads"
ASSEMBLY_DIR="$PROJECT_DIR/assembly"
PRODIGAL_DIR="$PROJECT_DIR/prodigal"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$PRODIGAL_DIR" "$LOG_DIR"

# =========================
# VALIDATE INPUT
# =========================
echo "Checking clean reads..."

if ! ls "$CLEAN_DIR"/*_clean.1.fastq 1> /dev/null 2>&1; then
    echo "ERROR: No clean reads found in $CLEAN_DIR"
    exit 1
fi

# =========================
# DETECT SAMPLES
# =========================
echo "Detecting samples..."

ls "$CLEAN_DIR"/*_clean.1.fastq | \
    xargs -n1 basename | \
    sed 's/_clean.1.fastq//' > "$CLEAN_DIR/samples.tmp"

echo "Samples:"
cat "$CLEAN_DIR/samples.tmp"

# =========================
# BUILD READ LISTS
# =========================
echo "Preparing read lists..."

R1_LIST=""
R2_LIST=""

while read -r S; do
    R1="$CLEAN_DIR/${S}_clean.1.fastq"
    R2="$CLEAN_DIR/${S}_clean.2.fastq"

    if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
        echo "ERROR: Missing pair for $S"
        exit 1
    fi

    R1_LIST="${R1_LIST},${R1}"
    R2_LIST="${R2_LIST},${R2}"

done < "$CLEAN_DIR/samples.tmp"

# quitar coma inicial
R1_LIST=${R1_LIST#,}
R2_LIST=${R2_LIST#,}

if [ -d "$ASSEMBLY_DIR" ]; then
    echo "ERROR: Assembly directory already exists: $ASSEMBLY_DIR"
    echo "Remove it manually"
    exit 1
fi

# =========================
# RUN MEGAHIT
# =========================
echo "Running MEGAHIT coassembly..."

megahit \
    -1 "$R1_LIST" \
    -2 "$R2_LIST" \
    -o "$ASSEMBLY_DIR" \
    -t "$MEGAHIT_THREADS" \
    --memory "$MEGAHIT_MEMORY" \
    --min-contig-len "$MEGAHIT_LEN" \
    2> "$LOG_DIR/megahit.log"
echo "MEGAHIT completed"

# =========================
# CHECK OUTPUT
# =========================
CONTIGS="$ASSEMBLY_DIR/final.contigs.fa"

if [ ! -f "$CONTIGS" ]; then
    echo "ERROR: Assembly failed, contigs not found"
    exit 1
fi

# =========================
# RUN PRODIGAL
# =========================
echo "Running Prodigal..."

prodigal \
    -i "$CONTIGS" \
    -a "$PRODIGAL_DIR/proteins.faa" \
    -d "$PRODIGAL_DIR/genes.fna" \
    -p meta \
    2> "$LOG_DIR/prodigal.log"

echo "Prodigal completed"
echo "Module 2 finished successfully"
