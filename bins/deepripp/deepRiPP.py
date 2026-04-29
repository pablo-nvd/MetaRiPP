#!/usr/bin/env python3

from nlpprecursor.classification.data import DatasetGenerator as CDG
from nlpprecursor.annotation.data import DatasetGenerator as ADG
from pathlib import Path
import nlpprecursor
import sys
import json
import argparse
from Bio import SeqIO

parser = argparse.ArgumentParser(description='Predicts RiPP and Class')


parser.add_argument("--input", type=str, help="Input fasta", required=True)
parser.add_argument("--output", type=str, help="output prefix", required=True)
parser.add_argument("--models", type=str, required=True, help="Model folder")

args = parser.parse_args()

input_fasta = args.input
output_files = args.output
models_dir = Path(args.models)

# This allows for backwards compatibility of the pickled models.
sys.modules["protai"] = nlpprecursor

# Definimos las carpetas con los modelos
class_model_dir = models_dir / "classification"
class_model_path = class_model_dir / "model.p"
class_vocab_path = class_model_dir / "vocab.pkl"
annot_model_dir = models_dir / "annotation"
annot_model_path = annot_model_dir / "model.p"
annot_vocab_path = annot_model_dir / "vocab.pkl"

# Leemos las secuencias fasta
lista_secuencias = []

records  = list(SeqIO.parse(input_fasta, "fasta"))

for record in records:
    entry_dict = {
        "sequence": str(record.seq),
        "name": record.id
    }

    lista_secuencias.append(entry_dict)

class_predictions = CDG.predict(class_model_path, class_vocab_path, lista_secuencias)
cleavage_predictions = ADG.predict(annot_model_path, annot_vocab_path, lista_secuencias)

print("Class predictions")
print(json.dumps(class_predictions, indent=4))

print("Cleavage predictions")
print(json.dumps(cleavage_predictions, indent=4))









