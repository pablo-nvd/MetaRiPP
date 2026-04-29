from Bio import SeqIO
import sys

# Leemos las secuencias fasta [1]
lista_secuencias = []

records  = list(SeqIO.parse(sys.argv[1], "fasta"))

for record in records:
    entry_dict = {
        "sequence": str(record.seq),
        "name": record.id
    }

    lista_secuencias.append(entry_dict)

#Importamos la listaxxx [2]
with open(sys.argv[2], 'r') as file:
    lista_only_RiPP = [line.strip() for line in file]

for i in lista_only_RiPP:
    for x in lista_secuencias:
        if i == x['name']:
            print(">"+x['name']+'\n'+x['sequence']+'\n')
