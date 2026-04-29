# 🧬 MetaRiPP

                               
<img width="500" height="250" alt="logo" src="https://github.com/user-attachments/assets/3ee2b4b3-8a19-4a7a-be01-9a9949651639" />
                                                                                                                                
        Metagenomic RiPP Discovery & Network Analysis Pipeline


**MetaRiPP** is a modular pipeline for the detection, classification, and cross-project analysis of **ribosomally synthesized and post-translationally modified peptides (RiPPs)** from metagenomic data.

It integrates assembly, BGC detection, deep learning-based precursor prediction, and structural annotation, enabling downstream **sequence similarity network (SSN)** and **biosynthetic diversity analyses**.

---

# ⚙️ Pipeline Overview

The pipeline is organized into modular steps:

### 1. Data Acquisition & QC

* Download from GeoSeeq OR use local FASTQ files
* Quality control with `fastp`
* Contaminant removal with `bowtie2` (PhiX + human)

### 2. Co-assembly & Gene Prediction

* Assembly using `MEGAHIT`
* Gene calling with `Prodigal`

### 3. BGC Detection

* `antiSMASH`
* Optional: `BiG-SCAPE` clustering

### 4. DeepRiPP Prediction

* Deep learning classification of precursor peptides

### 5. RiPPMiner Annotation

* Structural and class prediction
* SMILES extraction

### 6. Cross-project BiG-SCAPE

* Global clustering of BGCs across datasets

### 7. Cross-project SSN

* Builds sequence similarity networks from predicted RiPP precursors

---

# 🧪 Installation (WIP)

> ⚠️ Under development

Will include:

* Conda environment
* Dependency versions
* Optional Docker image

> ⚠️ Databases

Some modules require precomputed databases. These paths are defined in `config/config.env`.

### Required databases

The pipeline uses:

- **Bowtie2 indices**
  - Human genome (GRCh38)
  - PhiX control genome

- **Pfam HMM profiles** (required by BiG-SCAPE)

---

### 📥 Option 1 — Download prebuilt databases (recommended)

Preconfigured databases will be available at:  
*(Zenodo link — coming soon)*

After downloading, extract them into the `dbs/` directory.

Expected structure:

```bash
MetaRiPP/
├── bins/
├── config/
├── dbs/
│ ├── bigscape/ # Pfam HMM profiles
│ ├── index_h38/ # Bowtie2 human index
│ └── index_phix/ # Bowtie2 PhiX index
```

---

### 🛠️ Option 2 — Build/download manually

#### Bowtie2 indices

You can build indices from FASTA files:

```bash
bowtie2-build human.fa index_h38/hg38
bowtie2-build phix.fa index_phix/phix
```

#### Pfam database (for BiG-SCAPE)

Download Pfam HMM profiles:

```bash
wget https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
gunzip Pfam-A.hmm.gz
```

Download Pfam HMM profiles:
dbs/bigscape/
---

If you generate or place databases manually, make sure to update the paths in:
```bash
config/config.env
```
```bash
PHIX_INDEX="dbs/index_phix/phix"
HG_INDEX="dbs/index_h38/hg38"
PFAM_DIR="dbs/bigscape"
```

# 🚀 Usage

## 🔹 1. Full workflow

```bash
bash workflow/run_pipeline.sh \
    --project my_project \
    --mode local \
    --input input/
```

Modes:

* `download` → GeoSeeq
* `local` → local FASTQ

---


# 🧩 Modules

## 🔹 Module 1: Download / Local QC

**Scripts:**

* `01_download_qc.sh`
* `01_local_qc.sh`

**Function:**

* Input: sample list OR local FASTQ directory
* Output: cleaned paired reads

**Key parameters:**

```bash
THREADS=8
PHIX_INDEX=dbs/index_phix/phix
HG_INDEX=dbs/index_h38/hg38
```

---

## 🔹 Module 2: Co-assembly

**Script:** `02_coassembly.sh`

**Function:**

* Merges reads across samples
* Runs MEGAHIT + Prodigal

**Output:**

* Contigs
* Predicted proteins (*.faa)

---

## 🔹 Module 3: BGC Detection

**Script:** `03_bgcs.sh`

**Tools:**

* antiSMASH
* BiG-SCAPE (optional)

**Key parameter:**

```bash
RUN_BIGSCAPE=false
```

---

## 🔹 Module 4: DeepRiPP

**Script:** `04_deepripp.sh`

**Function:**

* Predicts RiPP precursor peptides

**Outputs:**

* `deepripp_parsed.tsv`
* `precursor_peptides.fasta`

---

## 🔹 Module 5: RiPPMiner

**Script:** `05_rippminer.sh`

**Function:**

* Classifies peptides and predicts structures

**Outputs:**

* `rippminer_classes.tsv`
* SMILES files

---

## 🔹  Cross-project modules (BiG-SCAPE and SNN)

⚠️ Cross-project Analysis Disclaimer:
All cross-project modules (e.g. BiG-SCAPE and SSN) are not included on the general workflow and must be run manually before analysing other projects.
This modules automatically process all projects outputs located inside the data/ directory.
This means that any folder within data/ containing valid outputs will be included in the analysis.
🧹 How to exclude datasets: Move the project outside the data/ directory

## 🔹 Module 6: Cross-project BiG-SCAPE

**Script:** `06_bigscape_cross_project.sh`

**Function:**

* Aggregates BGCs across projects
* Runs global clustering

---

## 🔹 Module 7: Cross-project SSN

**Script:** `07_ssn_cross_project.sh`

**Function:**

* Filters peptides using:

  * DeepRiPP score
  * RiPPMiner classification
* Runs all-vs-all BLAST
* Builds SSN

**Key parameters:**

```bash
--deepripp_score 0.5
--evalue 1e-5
```

---

# ⚙️ Configuration

All parameters are controlled via:

```bash
config/config.env
```

Example:

```bash
THREADS=8
RUN_BIGSCAPE=false
```

---

## 🔹 2. Run individual modules

Example:

```bash
bash scripts/02_coassembly.sh
bash scripts/04_deepripp.sh
```

⚠️ Requires previous module outputs.

---

## 🔹 3. Cross-project analysis

### SSN:

```bash
bash scripts/07_ssn_cross_project.sh \
    --deepripp_score 0.5 \
    --evalue 1e-5
```

### BiG-SCAPE:

```bash
bash scripts/06_bigscape_cross_project.sh
```

---

# 📁 Project Structure

```
MetaRiPP/
├── scripts/
├── workflow/
├── config/
├── dbs/
├── data/
│   ├── <project_name>/
│   └── cross_project/
```

---

# 📌 Notes

* All outputs are stored per-project under `data/`
* Cross-project analyses are stored in `data/cross_project/`
* Pipeline is designed for scalability across multiple cities/datasets

---

# 🧠 Future Development

* Docker / Conda reproducibility
* SNN implementation
* Visualization modules
* Automated reporting

---

# 📄 License

(To be defined)

---

# 👨‍🔬 Author

Pablo Villanueva Diaz

Microbial Data Science Lab

Universidad Andrés Bello
