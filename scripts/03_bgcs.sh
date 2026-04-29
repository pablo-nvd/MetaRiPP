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
# DEFAULTS
# =========================
ANTISMASH_DIR=${ANTISMASH_DIR:-antismash}
BIGSCAPE_DIR=${BIGSCAPE_DIR:-bigscape}
PFAM_DIR=${PFAM_DIR:-dbs/bigscape}
ANTISMASH_THREADS=${ANTISMASH_THREADS:-8}
BIGSCAPE_THREADS=${BIGSCAPE_THREADS:-8}
ANTISMASH_BIN=${ANTISMASH_BIN:-antismash}

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
# NORMALIZE PATHS (PROJECT)
# =========================
ASSEMBLY_DIR="$PROJECT_DIR/assembly"
ANTISMASH_DIR="$PROJECT_DIR/$ANTISMASH_DIR"
BIGSCAPE_DIR="$PROJECT_DIR/$BIGSCAPE_DIR"
LOG_DIR="$PROJECT_DIR/logs"

# PFAM
PFAM_DIR="$REPO_ROOT/$PFAM_DIR"

mkdir -p "$ANTISMASH_DIR" "$BIGSCAPE_DIR" "$LOG_DIR"

# =========================
# VALIDATE INPUT
# =========================
CONTIGS="$ASSEMBLY_DIR/final.contigs.fa"

if [ ! -f "$CONTIGS" ]; then
    echo "ERROR: Contigs file not found: $CONTIGS"
    exit 1
fi

# =========================
# RUN ANTISMASH
# =========================
echo "Running antiSMASH..."

SAMPLE_NAME="coassembly"

OUTDIR="$ANTISMASH_DIR/$SAMPLE_NAME"

if [ -d "$OUTDIR" ]; then
    echo "WARNING: antiSMASH output already exists: $OUTDIR"

    read -p "Do you want to remove it and continue? [y/N]: " choice

    case "$choice" in
        y|Y )
            echo "Removing existing directory..."
            rm -rf "$OUTDIR"
            ;;
        * )
            echo "Aborting to avoid overwrite"
            exit 1
            ;;
    esac
fi

if ! $ANTISMASH_BIN \
    "$CONTIGS" \
    --output-dir "$OUTDIR" \
    --genefinding-tool prodigal \
    --cpus "$ANTISMASH_THREADS" \
    2>&1 | tee "$LOG_DIR/antismash.log"; then

    echo "ERROR: antiSMASH failed"
    exit 1
fi

echo "antiSMASH completed"

# =========================
# RUN BIG-SCAPE (OPTIONAL)
# =========================
if [ "$RUN_BIGSCAPE" = true ]; then
    echo "Running BiG-SCAPE..."

    if ! bigscape \
        -i "$ANTISMASH_DIR" \
        -o "$BIGSCAPE_DIR/output" \
        --pfam_dir "$PFAM_DIR" \
        -c "$BIGSCAPE_THREADS" \
        2>&1 | tee "$LOG_DIR/bigscape.log"; then

        echo "ERROR: BiG-SCAPE failed (Check installation or pfam_dir)"
        exit 1
    fi

    echo "BiG-SCAPE completed"

else
    echo "Skipping BiG-SCAPE (RUN_BIGSCAPE=false)"
fi

echo "Module 3 finished successfully"
