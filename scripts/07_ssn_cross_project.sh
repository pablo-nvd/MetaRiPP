#!/bin/bash
set -euo pipefail

# =========================
# PARSE ARGS
# =========================
PROJECTS_DIR="data"
DEEPRIPP_SCORE=0.0
EVALUE="100"

while [[ $# -gt 0 ]]; do
    case $1 in
        --projects_dir) PROJECTS_DIR="$2"; shift 2 ;;
        --deepripp_score) DEEPRIPP_SCORE="$2"; shift 2 ;;
        --evalue) EVALUE="$2"; shift 2 ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
done


# =========================
# DETECT ROOT
# =========================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

PROJECTS_DIR="$REPO_ROOT/$PROJECTS_DIR"

echo "WARNING: Cross-project analysis will include ALL projects in $PROJECTS_DIR"

OUT_DIR="$REPO_ROOT/data/cross_project/ssn"
mkdir -p "$OUT_DIR"

FASTA_ALL="$OUT_DIR/all_precursors.fasta"
METADATA="$OUT_DIR/metadata.tsv"

> "$FASTA_ALL"
echo -e "id\tproject\tclass\tscore" > "$METADATA"

echo "Using DeepRiPP score cutoff: $DEEPRIPP_SCORE"
echo "Using e-value cutoff: $EVALUE"

# =========================
# COLLECT + FILTER
# =========================
for proj in "$PROJECTS_DIR"/*; do
    [ -d "$proj" ] || continue

    pname=$(basename "$proj")

    # evitar carpeta cross_project
    if [ "$pname" = "cross_project" ]; then
        echo "Skipping $pname (system folder)"
        continue
    fi

    FASTA="$proj/deepripp/precursor_peptides.fasta"
    DEEP="$proj/deepripp/deepripp_parsed.tsv"
    MINER="$proj/rippminer/rippminer_classes.tsv"

    if [ ! -s "$FASTA" ] || [ ! -s "$DEEP" ] || [ ! -s "$MINER" ]; then
        echo "Skipping $pname (missing files)"
        continue
    fi

    echo "Processing $pname..."

    TMP_IDS="$OUT_DIR/tmp_${pname}_ids.txt"
    PROJECT_FASTA="$OUT_DIR/${pname}_filtered.fasta"

    # =========================
    # BUILD FILTERED ID LIST
    # =========================
    python <<EOF > "$TMP_IDS"
deep = {}
miner = set()

# DeepRiPP filter
with open("$DEEP") as f:
    for line in f:
        parts = line.strip().split("\t")
        if len(parts) < 3:
            continue
        cds, cls, score = parts
        try:
            score = float(score)
        except:
            continue
        if score >= $DEEPRIPP_SCORE:
            deep[cds] = (cls, score)

# RiPPMiner filter
with open("$MINER") as f:
    for line in f:
        parts = line.strip().split("\t")
        if len(parts) < 2:
            continue
        cds, cls = parts
        miner.add(cds)

# intersection
for k in deep:
    if k in miner:
        print(k, deep[k][0], deep[k][1], sep="\t")
EOF

    # validar IDs
    if [ ! -s "$TMP_IDS" ]; then
        echo "WARNING: No valid RiPPs after filtering for $pname"
        continue
    fi

    # =========================
    # FILTER FASTA
    # =========================
    python <<EOF > "$PROJECT_FASTA"
ids = {}

with open("$TMP_IDS") as f:
    for line in f:
        cds, cls, score = line.strip().split("\t")
        ids[cds] = (cls, score)

seq = ""
name = None

for line in open("$FASTA"):
    if line.startswith(">"):
        if name is not None and name in ids:
            print(f">${pname}|{name}")
            print(seq)
        name = line.strip().replace(">", "").split()[0]
        seq = ""
    else:
        seq += line.strip()

# last entry
if name is not None and name in ids:
    print(f">${pname}|{name}")
    print(seq)
EOF

    # validar FASTA
    if [ ! -s "$PROJECT_FASTA" ]; then
        echo "WARNING: No sequences extracted for $pname"
        continue
    fi

    # agregar al global
    cat "$PROJECT_FASTA" >> "$FASTA_ALL"

    # =========================
    # METADATA
    # =========================
    awk -v p="$pname" '
    {
        print p"|"$1"\t"p"\t"$2"\t"$3
    }
    ' "$TMP_IDS" >> "$METADATA"

done

# limpiar temporales
rm -f "$OUT_DIR"/tmp_*_ids.txt

# =========================
# VALIDATE GLOBAL FASTA
# =========================
if [ ! -s "$FASTA_ALL" ]; then
    echo "ERROR: No sequences found after filtering across projects"
    echo "Check:"
    echo " - DeepRiPP cutoff"
    echo " - RiPPMiner overlap"
    exit 1
fi

# =========================
# BLAST
# =========================
echo "Running BLAST..."

makeblastdb -in "$FASTA_ALL" -dbtype prot -out "$OUT_DIR/db"

blastp \
    -query "$FASTA_ALL" \
    -db "$OUT_DIR/db" \
    -out "$OUT_DIR/all_vs_all.tsv" \
    -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
    -num_threads ${THREADS:-4}

# =========================
# CLEAN + FILTER EDGES
# =========================
echo "Filtering edges..."

python <<EOF > "$OUT_DIR/edges.tsv"
seen = set()

with open("$OUT_DIR/all_vs_all.tsv") as f:
    for line in f:
        fields = line.strip().split()
        if len(fields) < 12:
            continue

        q = fields[0]
        s = fields[1]
        evalue = float(fields[10])

        if q == s:
            continue

        pair = tuple(sorted([q, s]))
        if pair in seen:
            continue

        seen.add(pair)

        if evalue <= float("$EVALUE"):
            print(f"{q}\t{s}\t{evalue}")
EOF

# =========================
# NODES
# =========================
cp "$METADATA" "$OUT_DIR/nodes.tsv"

# =========================
# DONE
# =========================
echo "SSN completed successfully"
echo "Nodes: $OUT_DIR/nodes.tsv"
echo "Edges: $OUT_DIR/edges.tsv"