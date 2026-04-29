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
PRODIGAL_DIR=${PRODIGAL_DIR:-prodigal}
DEEPRIPP_DIR=${DEEPRIPP_DIR:-deepripp}
DEEPRIPP_BIN=${DEEPRIPP_BIN:-bins/deepripp/deepRiPP.py}
DEEPRIPP_MODELS=${DEEPRIPP_MODELS:-bins/deepripp/models}

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
PRODIGAL_DIR="$PROJECT_DIR/$PRODIGAL_DIR"
DEEPRIPP_DIR="$PROJECT_DIR/$DEEPRIPP_DIR"
LOG_DIR="$PROJECT_DIR/logs"

# BIN y MODELS 
DEEPRIPP_BIN="$REPO_ROOT/$DEEPRIPP_BIN"
DEEPRIPP_MODELS="$REPO_ROOT/$DEEPRIPP_MODELS"

mkdir -p "$DEEPRIPP_DIR" "$LOG_DIR"

# =========================
# VALIDATE BINARIES
# =========================
if [ ! -f "$DEEPRIPP_BIN" ]; then
    echo "ERROR: DeepRiPP script not found: $DEEPRIPP_BIN"
    exit 1
fi

if [ ! -d "$DEEPRIPP_MODELS" ]; then
    echo "ERROR: DeepRiPP models directory not found: $DEEPRIPP_MODELS"
    exit 1
fi

# =========================
# VALIDATE INPUT
# =========================
FAA_FILES=("$PRODIGAL_DIR"/*.faa)

if [ ! -e "${FAA_FILES[0]}" ]; then
    echo "ERROR: No Prodigal protein files (*.faa) found in $PRODIGAL_DIR"
    exit 1
fi

echo "Found ${#FAA_FILES[@]} protein files"

# =========================
# MERGE + CLEAN FASTA
# =========================
MERGED_FAA="$DEEPRIPP_DIR/all_proteins.faa"
CLEAN_FAA="$DEEPRIPP_DIR/all_proteins.clean.faa"

echo "Merging protein files..."
cat "${FAA_FILES[@]}" > "$MERGED_FAA"

echo "Cleaning protein sequences (removing '*')..."
awk '
/^>/ {print; next}
{
    gsub(/\*/, "", $0)
    print
}
' "$MERGED_FAA" > "$CLEAN_FAA"

# =========================
# RUN DEEPRIPP
# =========================
echo "Running DeepRiPP..."

JSON_RAW="$DEEPRIPP_DIR/deepripp_raw.json"

if ! python "$DEEPRIPP_BIN" \
    --input "$CLEAN_FAA" \
    --output dummy \
    --models "$DEEPRIPP_MODELS" \
    2> >(tee "$LOG_DIR/deepripp.log" >&2) \
    | tee "$JSON_RAW"; then

    echo "ERROR: DeepRiPP failed"
    exit 1
fi

echo "DeepRiPP completed"

# =========================
# EXTRACT CLASS JSON
# =========================
JSON_CLEAN="$DEEPRIPP_DIR/deepripp_clean.json"

echo "Extracting CLASS predictions JSON..."

python <<EOF
import json

with open("$JSON_RAW") as f:
    content = f.read()

start = content.find('[')
if start == -1:
    raise ValueError("No JSON start found")

bracket_count = 0
end = None

for i in range(start, len(content)):
    if content[i] == '[':
        bracket_count += 1
    elif content[i] == ']':
        bracket_count -= 1
        if bracket_count == 0:
            end = i + 1
            break

if end is None:
    raise ValueError("No valid JSON end found")

clean_json = content[start:end]
json.loads(clean_json)

with open("$JSON_CLEAN", "w") as out:
    out.write(clean_json)

print("Class JSON extracted successfully")
EOF

# =========================
# EXTRACT CLEAVAGE JSON
# =========================
JSON_CLEAVAGE="$DEEPRIPP_DIR/deepripp_cleavage.json"

echo "Extracting CLEAVAGE predictions JSON..."

python <<EOF
import json

with open("$JSON_RAW") as f:
    content = f.read()

parts = content.split("Cleavage predictions")

if len(parts) < 2:
    raise ValueError("Cleavage predictions block not found")

second_part = parts[1]

start = second_part.find('[')
if start == -1:
    raise ValueError("No JSON start in cleavage block")

bracket_count = 0
end = None

for i in range(start, len(second_part)):
    if second_part[i] == '[':
        bracket_count += 1
    elif second_part[i] == ']':
        bracket_count -= 1
        if bracket_count == 0:
            end = i + 1
            break

if end is None:
    raise ValueError("No valid JSON end in cleavage block")

clean_json = second_part[start:end]
json.loads(clean_json)

with open("$JSON_CLEAVAGE", "w") as out:
    out.write(clean_json)

print("Cleavage JSON extracted successfully")
EOF

# =========================
# PARSE CLASS RESULTS
# =========================
PARSED_OUT="$DEEPRIPP_DIR/deepripp_parsed.tsv"

echo "Parsing DeepRiPP classification..."

python <<EOF > "$PARSED_OUT"
import json

with open("$JSON_CLEAN") as f:
    data = json.load(f)

for i in data:
    for x in i.get("class_predictions", []):
        if x.get("class") != "NONRIPP":
            print(f"{i.get('name')}\t{x.get('class')}\t{x.get('score')}")
EOF

# =========================
# GENERATE FASTA
# =========================
PEPTIDES_FASTA="$DEEPRIPP_DIR/precursor_peptides.fasta"

echo "Generating precursor peptides FASTA..."

python <<EOF > "$PEPTIDES_FASTA"
import json

with open("$JSON_CLEAVAGE") as f:
    data = json.load(f)

for i in data:
    cp = i.get("cleavage_prediction")
    if cp and cp.get("status") == "success":
        print(f">{cp['name']}")
        print(cp["sequence"])
EOF

echo "Module 4 (DeepRiPP) completed successfully"