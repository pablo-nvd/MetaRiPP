#!/bin/bash
set -euo pipefail

# =========================
# DETECT PATHS
# =========================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# =========================
# DEFAULTS
# =========================
MODE=""
INPUT=""
RUN_BIGSCAPE_OVERRIDE=""
PROJECT_NAME="default_project"

# =========================
# ARGUMENT PARSER
# =========================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --input)
            INPUT="$2"
            shift 2
            ;;
        --run-bigscape)
            RUN_BIGSCAPE_OVERRIDE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage:"
            echo "  --project [name]"
            echo "  --mode   [download|local]"
            echo "  --input  [samples.txt|fastq_dir]"
            echo "  --run-bigscape  [true|false] (default: false)"
            exit 0
            ;;
        *)
            echo "ERROR: Unknown argument $1"
            exit 1
            ;;
    esac
done


# =========================
# VALIDATION
# =========================
if [ -z "$MODE" ] || [ -z "$INPUT" ]; then
    echo "ERROR: --mode [download|local] and --input are required, use -h for help"
    exit 1
fi

# convertir input a absoluto
INPUT="$(realpath "$INPUT")"

# =========================
# LOAD CONFIG
# =========================
CONFIG_FILE=${CONFIG_FILE:-"$REPO_ROOT/config/config.env"}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: config.env not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# =========================
# Create data directory
# =========================
PROJECT_DIR="$REPO_ROOT/data/$PROJECT_NAME"

echo "Project directory: $PROJECT_DIR"

mkdir -p "$PROJECT_DIR"

export PROJECT_DIR 

# =========================
# EXPORT GLOBALS
# =========================
export REPO_ROOT
export CONFIG_FILE

# =========================
# RUN PIPELINE
# =========================
echo "Running pipeline in mode: $MODE"

if [ "$MODE" = "download" ]; then

    if [ ! -f "$INPUT" ]; then
        echo "ERROR: Input must be a sample list file"
        exit 1
    fi

    bash "$REPO_ROOT/scripts/01_download_qc.sh" "$INPUT"

elif [ "$MODE" = "local" ]; then

    if [ ! -d "$INPUT" ]; then
        echo "ERROR: Input must be a directory with FASTQ files"
        exit 1
    fi

    bash "$REPO_ROOT/scripts/01_local_qc.sh" "$INPUT"

else
    echo "ERROR: MODE must be 'download' or 'local'"
    exit 1
fi

# =========================
# CONTINUE PIPELINE
# =========================
echo "=== MODULE 2: COASSEMBLY ==="
bash "$REPO_ROOT/scripts/02_coassembly.sh"

echo "=== MODULE 3: BGC PREDICTION ==="
bash "$REPO_ROOT/scripts/03_bgcs.sh"

echo "=== MODULE 4: DEEPRIPP ==="
bash "$REPO_ROOT/scripts/04_deepripp.sh"

echo "=== MODULE 5: RIPPMINER ==="
bash "$REPO_ROOT/scripts/05_rippminer.sh"

echo "=== PIPELINE COMPLETED SUCCESSFULLY ==="
