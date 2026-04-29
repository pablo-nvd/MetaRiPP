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
# DEFAULT PROJECT HANDLING
# =========================
if [ -z "${PROJECT_DIR:-}" ]; then
    echo "No PROJECT_DIR provided → running in GLOBAL cross-project mode"
    BASE_DATA_DIR="$REPO_ROOT/data"
else
    echo "WARNING: PROJECT_DIR is set → ignoring and running GLOBAL analysis"
    BASE_DATA_DIR="$REPO_ROOT/data"
fi

echo "WARNING: Cross-project analysis will include ALL projects in $PROJECTS_DIR"
# =========================
# DEFAULTS
# =========================
CROSS_DIR="$BASE_DATA_DIR/cross_project"
INPUT_DIR="$CROSS_DIR/input_bgcs"
OUTPUT_DIR="$CROSS_DIR/output_bigscape"
METADATA_FILE="$CROSS_DIR/bgc_metadata.tsv"

BIGSCAPE_THREADS=${BIGSCAPE_THREADS:-8}
PFAM_DIR=${PFAM_DIR:-bins/bigscape}
USE_SYMLINKS=${USE_SYMLINKS:-true}

# =========================
# NORMALIZE PATHS
# =========================
PFAM_DIR="$REPO_ROOT/$PFAM_DIR"
LOG_DIR="$CROSS_DIR/logs"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR" "$LOG_DIR"

# =========================
# VALIDATIONS
# =========================
if [ ! -d "$PFAM_DIR" ]; then
    echo "ERROR: PFAM directory not found: $PFAM_DIR"
    exit 1
fi

# =========================
# CLEAN PREVIOUS RUN (OPTIONAL)
# =========================
if [ "$(ls -A "$INPUT_DIR" 2>/dev/null || true)" ]; then
    echo "WARNING: Existing input_bgcs detected"

    read -p "Do you want to clean previous cross-project input? [y/N]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        rm -rf "$INPUT_DIR"/*
        echo "Cleaned previous input"
    fi
fi

# =========================
# BUILD CROSS-PROJECT INPUT
# =========================
echo "Collecting BGCs from all projects..."

> "$METADATA_FILE"
echo -e "BGC_ID\tPROJECT" >> "$METADATA_FILE"

total_bgcs=0

for proj in "$BASE_DATA_DIR"/*; do
    [ -d "$proj" ] || continue

    project_name=$(basename "$proj")

    # evitar self-loop
    if [[ "$project_name" == "cross_project" ]]; then
        continue
    fi

    ANTISMASH_DIR="$proj/antismash"

    if [ ! -d "$ANTISMASH_DIR" ]; then
        echo "Skipping $project_name (no antismash output)"
        continue
    fi

    echo "Processing project: $project_name"

    found=false

    while IFS= read -r file; do
        base=$(basename "$file")
        new_name="${project_name}__${base}"
        dest="$INPUT_DIR/$new_name"

        if [ "$USE_SYMLINKS" = true ]; then
            ln -sf "$file" "$dest"
        else
            cp "$file" "$dest"
        fi

        echo -e "${new_name}\t${project_name}" >> "$METADATA_FILE"

        total_bgcs=$((total_bgcs + 1))
        found=true
    done < <(find "$ANTISMASH_DIR" -type f -name "*.gbk")

    if [ "$found" = false ]; then
        echo "WARNING: No BGCs found in $project_name"
    fi

done

# =========================
# FINAL VALIDATION
# =========================
if [ "$total_bgcs" -eq 0 ]; then
    echo "ERROR: No BGCs collected. Cannot run BiG-SCAPE."
    exit 1
fi

echo "Total BGCs collected: $total_bgcs"
echo "Metadata saved to: $METADATA_FILE"

# =========================
# RUN BIG-SCAPE
# =========================
echo "Running BiG-SCAPE (cross-project)..."

if ! bigscape \
    -i "$INPUT_DIR" \
    -o "$OUTPUT_DIR" \
    --pfam_dir "$PFAM_DIR" \
    -c "$BIGSCAPE_THREADS" \
    2>&1 | tee "$LOG_DIR/bigscape_cross_project.log"; then

    echo "ERROR: BiG-SCAPE failed"
    exit 1
fi

echo "BiG-SCAPE cross-project completed"

# =========================
# SUMMARY
# =========================
echo "======================================="
echo "Cross-project analysis completed"
echo "Input BGCs: $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo "Metadata: $METADATA_FILE"
echo "======================================="
