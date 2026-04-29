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
DEEPRIPP_DIR=${DEEPRIPP_DIR:-deepripp}
RIPPMINER_DIR=${RIPPMINER_DIR:-rippminer}
RIPPMINER_BIN=${RIPPMINER_BIN:-bins/rippminer/RiPPMiner.py}

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
DEEPRIPP_DIR="$PROJECT_DIR/$DEEPRIPP_DIR"
RIPPMINER_DIR="$PROJECT_DIR/$RIPPMINER_DIR"
LOG_DIR="$PROJECT_DIR/logs"

# BIN 
RIPPMINER_BIN="$REPO_ROOT/$RIPPMINER_BIN"

mkdir -p "$RIPPMINER_DIR" "$LOG_DIR"

# =========================
# INPUT
# =========================
FASTA="$DEEPRIPP_DIR/precursor_peptides.fasta"

if [ ! -s "$FASTA" ]; then
    echo "ERROR: precursor_peptides.fasta not found or empty"
    exit 1
fi

echo "Input FASTA: $FASTA"

# =========================
# RUN RIPPMINER
# =========================
RAW_OUT="$RIPPMINER_DIR/rippminer_raw.txt"

echo "Running RiPPMiner..."

if ! perl "$RIPPMINER_BIN" \
    -i "$FASTA" \
    -o "$RAW_OUT" \
    2>&1 | tee "$LOG_DIR/rippminer.log"; then

    echo "ERROR: RiPPMiner failed"
    exit 1
fi

echo "RiPPMiner completed"

# =========================
# STEP 1: FILTER CHUNKS
# =========================
FILTERED1="$RIPPMINER_DIR/rippminer_filtered.txt"

echo "Filtering chunks (removing NONE/not)..."

python <<EOF > "$FILTERED1"
words_to_exclude = ["NONE","not"]

current_chunk = []
filtered_chunks = []

with open("$RAW_OUT") as file:
    for line in file:
        line = line.strip()

        if line.startswith("#INPUT"):
            chunk_text = '\n'.join(current_chunk)
            if all(word not in chunk_text for word in words_to_exclude):
                filtered_chunks.append(chunk_text)
            current_chunk = [line]
        else:
            current_chunk.append(line)

for chunk in filtered_chunks:
    print(chunk)
EOF

# =========================
# STEP 2: EXTRACT RiPP CLASSES
# =========================
CLASSES_OUT="$RIPPMINER_DIR/rippminer_classes.tsv"

echo "Extracting RiPP classes..."

python <<EOF > "$CLASSES_OUT"
words_to_exclude = ["not"]

current_id = None

with open("$FILTERED1") as file:
    for line in file:
        line = line.strip()

        # detectar ID
        if line.startswith("#INPUT"):
            words = line.split()
            if len(words) >= 3:
                current_id = words[2]
            else:
                current_id = None

        # detectar clase
        elif line.startswith("Predicted RiPP") and current_id:
            if not any(w in line for w in words_to_exclude):
                words = line.split()
                if len(words) >= 4:
                    predicted_class = words[3]
                    print(f"{current_id}\t{predicted_class}")
EOF

echo "RiPP classes extracted to $CLASSES_OUT"

# =========================
# STEP 3: EXTRACT SMILES
# =========================
echo "Extracting SMILES..."

python <<EOF
import os

output_dir = "$RIPPMINER_DIR/smiles"
os.makedirs(output_dir, exist_ok=True)

current_id = None
smiles_list = []

with open("$FILTERED1") as file:
    for line in file:
        line = line.strip()

        # detectar nuevo bloque
        if line.startswith("#INPUT"):
            # guardar anterior si existe
            if current_id and smiles_list:
                for i, sm in enumerate(smiles_list):
                    suffix = f"_MODEL{i+1}" if len(smiles_list) > 1 else ""
                    with open(f"{output_dir}/{current_id}{suffix}.smiles", "w") as f:
                        f.write(sm)

            # reset
            parts = line.split()
            current_id = parts[2] if len(parts) >= 3 else None
            smiles_list = []

        # capturar SMILES
        elif line.startswith("SMILES"):
            parts = line.split()
            if len(parts) >= 2:
                smiles_list.append(parts[1])

# guardar último bloque
if current_id and smiles_list:
    for i, sm in enumerate(smiles_list):
        suffix = f"_MODEL{i+1}" if len(smiles_list) > 1 else ""
        with open(f"{output_dir}/{current_id}{suffix}.smiles", "w") as f:
            f.write(sm)

print("SMILES extraction completed")
EOF