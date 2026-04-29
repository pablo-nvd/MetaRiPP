#!/bin/bash
set -e
set -o pipefail

# =========================
# LOAD CONFIG
# =========================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

CONFIG_FILE=${CONFIG_FILE:-"$REPO_ROOT/config/config.env"}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found at $CONFIG_FILE"
    echo "Hint: create config/config.env or specify CONFIG_FILE=/path/to/config.env"
    exit 1
fi

source "$CONFIG_FILE"

# Normalize paths

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

DATA_DIR="$PROJECT_DIR"
RAW_DIR="$DATA_DIR/raw"
QC_DIR="$DATA_DIR/filtered_reads"
CLEAN_DIR="$DATA_DIR/clean_reads"
LOG_DIR="$DATA_DIR/logs"
DBS_DIR="$REPO_ROOT/$DBS_DIR"
PHIX_INDEX="$REPO_ROOT/$PHIX_INDEX"
HG_INDEX="$REPO_ROOT/$HG_INDEX"

# =========================
# INPUT VALIDATION
# =========================
SAMPLE_LIST=$1

if [ -z "$SAMPLE_LIST" ]; then
    echo "ERROR: No input file provided"
    echo "Usage: bash 01_download_qc.sh <samples.txt>"
    exit 1
fi

if [ ! -f "$SAMPLE_LIST" ]; then
    echo "ERROR: Input file '$SAMPLE_LIST' not found"
    exit 1
fi

# Verificar formato (1 columna, no vacío)
if [ ! -s "$SAMPLE_LIST" ]; then
    echo "ERROR: Input file is empty"
    exit 1
fi

# Chequeo básico de formato
if awk 'NF > 1 {exit 1}' "$SAMPLE_LIST"; then
    echo "Sample list format OK (single column)"
else
    echo "ERROR: Input file must contain ONE column (sample IDs, one per line)"
    exit 1
fi

# =========================
# DIRECTORIES
# =========================
mkdir -p "$RAW_DIR" "$QC_DIR" "$CLEAN_DIR" "$LOG_DIR"

echo "Directories ready"

# =========================
# STEP 1: DOWNLOAD, FILTER AND RENAME FILES.
# =========================
echo "Starting download from GeoSeeq..."

successful_samples=0

while read -r SAMPLE; do
    echo "Downloading sample: $SAMPLE"

    TMP_DIR="$RAW_DIR/tmp_${SAMPLE}_$$"
    mkdir -p "$TMP_DIR"

    # =========================
    # DOWNLOAD
    # =========================
    if ! geoseeq download files 'MetaSUB Consortium/Cell Paper' "$SAMPLE" \
        --target-dir "$TMP_DIR" \
        --folder-type 'sample' \
        --extension 'fastq.gz' <<< "y"; then

        echo "WARNING: Download issues detected for $SAMPLE (likely non-essential files)"
    fi

    # =========================
    # FILTER RAW FILES
    # =========================
    echo "Filtering RAW files for $SAMPLE"

    found_raw=false

    for file in "$TMP_DIR"/*raw__raw_reads*; do
        [ -e "$file" ] || continue

        sl=$(echo "$file" | grep -oP 'SL\d+' | head -n 1)
        read_id=$(echo "$file" | grep -oP 'read_\d' | head -n 1)

        # limpiar posibles saltos de línea
        sl=$(echo "$sl" | tr -d '\n\r')
        read_id=$(echo "$read_id" | tr -d '\n\r')

        if [[ -n "$sl" && -n "$read_id" ]]; then
            mv "$file" "$RAW_DIR/${sl}_${read_id}.fastq.gz"
            found_raw=true
        fi
    done

    # =========================
    # CLEAN TEMP
    # =========================
    rm -rf "$TMP_DIR"

    # =========================
    # VALIDATE PER SAMPLE
    # =========================
    if [ "$found_raw" = false ]; then
        echo "WARNING: No RAW files found for $SAMPLE — skipping"
        continue
    fi

    echo "Sample $SAMPLE processed successfully"
    successful_samples=$((successful_samples + 1))

done < "$SAMPLE_LIST"

# =========================
# FINAL VALIDATION
# =========================
echo "Download completed"

if [ "$successful_samples" -eq 0 ]; then
    echo "ERROR: No samples were successfully processed"
    exit 1
fi

echo "Successfully processed $successful_samples samples"

echo "Final RAW files:"
ls "$RAW_DIR"

# =========================
# FASTQ INTEGRITY CHECK
# =========================
echo "Validating FASTQ integrity..."

for f in "$RAW_DIR"/*.fastq.gz; do
    if ! gzip -t "$f"; then
        echo "ERROR: Corrupted file detected: $f"
        exit 1
    fi
done

echo "All FASTQ files passed integrity check"

# =========================
# STEP 2: QC (fastp)
# =========================
echo "Detecting samples..."

ls "$RAW_DIR"/*.fastq.gz 2>/dev/null | \
    xargs -n1 basename | \
    cut -d '_' -f1 | \
    sort | uniq > "$RAW_DIR/samples.tmp"

echo "Running fastp..."

while read -r S; do
    echo "Processing sample: $S"

    R1="${RAW_DIR}/${S}_read_1.fastq.gz"
    R2="${RAW_DIR}/${S}_read_2.fastq.gz"

    if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
    echo "WARNING: Missing FASTQ pair for $S — skipping"
    continue
    fi

    if ! fastp \
    -i "$R1" \
    -I "$R2" \
    -o "${QC_DIR}/${S}_filtered_1.fastq.gz" \
    -O "${QC_DIR}/${S}_filtered_2.fastq.gz" \
    --thread "$THREADS" \
    --qualified_quality_phred=20 \
    --length_required=75 \
    --json "${LOG_DIR}/${S}.json" \
    --html "${LOG_DIR}/${S}.html"; then

    echo "WARNING: fastp failed for $S — skipping sample"
    continue
    fi

done < "$RAW_DIR/samples.tmp"

echo "QC completed"

# =========================
# STEP 3: CONTAMINATION REMOVAL
# =========================
echo "Removing contaminants with Bowtie2..."

# Validar índices
if [ ! -f "${PHIX_INDEX}.1.bt2" ]; then
    echo "ERROR: PHIX index not found at $PHIX_INDEX"
    exit 1
fi

if [ ! -f "${HG_INDEX}.1.bt2" ]; then
    echo "ERROR: Human genome index not found at $HG_INDEX"
    exit 1
fi

while read -r S; do
    echo "Cleaning sample: $S (PhiX)"

    # PhiX removal
    bowtie2 -x "$PHIX_INDEX" \
        -1 "${QC_DIR}/${S}_filtered_1.fastq.gz" \
        -2 "${QC_DIR}/${S}_filtered_2.fastq.gz" \
        --un-conc "${CLEAN_DIR}/${S}_phix_unm.fastq" \
        -p "$THREADS" \
        -S /dev/null
    echo "Cleaning sample: $S (PhiX) Done"
    echo "Cleaning sample: $S (Human)"
    # Human removal
    bowtie2 -x "$HG_INDEX" \
        -1 "${CLEAN_DIR}/${S}_phix_unm.1.fastq" \
        -2 "${CLEAN_DIR}/${S}_phix_unm.2.fastq" \
        --un-conc "${CLEAN_DIR}/${S}_clean.fastq" \
        -p "$THREADS" \
        -S /dev/null

    echo "Cleaning sample: $S (Human) Done"
done < "$RAW_DIR/samples.tmp"

rm "$RAW_DIR/samples.tmp"

echo "Contamination removal completed"
echo "Module 1 finished successfully"
