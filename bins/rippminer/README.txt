RiPPMiner Documentation
-----------------------------------------------------------------

This is the Standalone version of RiPPMiner which can be run from terminal on Linux system.

INSTALLATION

Prerequisites

Before running run_rippminer.pl, following dependecies must be installed.

Java must be installed on your system with version 1.8 or greater.
Perl version on your system must be v5.18 or greater.

Note: For the download and installation of all required dependencies, Following two scripts have been provided whose descriptions are provided below:

A. Script 'install_svm_and_weka' create a 'downloads' directory and downloads  weka-3-6-14 and svm_light programs in this directory which is then installed in the 'scripts' directory.

B. Script 'download_openbabel_and_blast' downloads openbabel-2.3.2 and Blast-2.6.0+. After download, user can install them by following the instructions provided by respective developers.

After installation, provide the path to bin directory of Openbabel and Blast in the respective variables defined in 'path' file.

User can either make use of these two above mentioned scripts or can follow the steps given below one by one for the same purpose.

1. Download and Install Weka

Download weka-3-6-14.zip from https://sourceforge.net/projects/weka/files/weka-3-6/3.6.14/,
extract the zip file into scripts directory using command

	unzip weka-3-6-14.zip

This will create a directory named weka-3-6-14 within scripts directory.

2. Download and Install SVM Light

Download svm_light_linux32.tar.gz from 'http://download.joachims.org/svm_light/current/svm_light_linux32.tar.gz' for 32-Bit System or from 'http://download.joachims.org/svm_light/current/svm_light_linux64.tar.gz' for 64-Bit System. Copy these tar files into scripts directory and extract them using command:

	tar xvf svm_light_linux32.tar.gz OR
	tar xvf svm_light_linux64.tar.gz

This will create binary files svm_learn and svm_classify within scripts directory.

3. Download SVM Multiclass

Download svm_multiclass.tar.gz from 'http://download.joachims.org/svm_multiclass/current/svm_multiclass_linux32.tar.gz' for 32-Bit System or from 'http://download.joachims.org/svm_multiclass/current/svm_multiclass_linux64.tar.gz' for 64-Bit System. Copy these tar files into scripts directory and extract using command:

	tar xvf svm_multiclass_linux32.tar.gz
	tar xvf svm_multiclass_linux64.tar.gz

This will create binary files svm_multiclass_learn  and  svm_multiclass_classify within scripts directory.

4. Install Openbabel

Download openbabel-2.3.2.tar.gz from 'https://sourceforge.net/projects/openbabel/files/openbabel/2.3.2/' and install it on your System. Provide the path of bin directory (after installation) to variable 'Openbabel' in the 'path' file.

5. Install BLAST

Download ncbi-blast-2.2.30+ from and install it on your system. Provide the path of bin directory (after installation) to variable 'Blast' in the 'path' file.

Note: Before Running RiPPMiner make sure that dependencies have been installed as instructed by the respective developers. 

USAGE

Running RiPPMiner:

Usage: perl run_rippminer.pl -i input_file

User can provide multiple fasta sequences in One file as Input.

Following arguments can be passed to the Program:

-i 	<input_fasta>		input peptide sequence file in Fasta format
-class  <class>			provide RiPP class (LanthipeptideA, LanthipeptideB, LanthipeptideC, LanthipeptideD, Lassopeptide, Cyanobactin, Lassopeptide, Thiopeptide) of the input Sequence.
                		(By deafault the program will predict the class)
-coreonly <Boolean>		1 if the input sequence contain only core sequence (0 is Default for complete sequence)
-classifier <classifier>	Chose SVM for Support Vector machine or RF for Random Forest for Lanthipeptide Crosslink prediction.(RF is default)
-predictclass  <Boolean> 	1 if only Class Prediction is required (default is 0)
-h help  <help>			Displays short information about various options that can be used with this script.

For Sequence Similarity Search:

Usage: perl sequence_similarity_search.pl -i protein_fasta_input_file

User can provide multiple fasta sequences in One file as Input.

This program will produce two output files:

1. File 'sequence_similarity.out' contains List of Top 50 Hits under the heads:

Subject
Identity
Alignment Length
Alignment Start
Alignment End
E-value

2. File 'all_alignment' contains Complete alignments of Top 50 Hits.

For Closest Structure Search

Usage: perl closest_structure_search.pl -i smiles_input_file

This program takes One Structure (SMILES format) as Input at a time.

Following arguments can be passed to the Program:

-i             	Provide Input file in smiles format.
-top NUM	Output NUM most similar Molecules. NUM should be an integer
-tanimoto NUM 	Output Molecules with Tanimoto score greater than NUM. NUM should be between 0 to 1.

The program generates output in two separate files:

1. File 'structure_search.out' contains Tab seperated list of Top matches along with their tanimoto score.
2. File 'all_smiles.out' contains SMILES data of Top matching hits.

User can also run the script 'run_all' where all the three scripts 'run_rippminer.pl', 'sequence_similarity_search.pl' and 'closest_structure_search.pl' can be run simultaneously. Here
same fasta file can be provided as input to programs 'run_rippminer.pl' and 'sequence_similarity_search.pl'.

EXAMPLE RESULTS

Example Results for two peptides of each RiPP Class has been saved to example directory.

Note: If only Core peptide is given as Input, One also need to provide the Class (-class parameter) as well because The class prediction by RiPPMiner may not be correct in case where only Core
Peptide is given.
------------------------------------------------------------------
Bioinformatics Centre
National Institute of Immunology, India
http://www.nii.ac.in/rippminer.html
