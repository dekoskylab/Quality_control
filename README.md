# Quality control scripts for AIRR-seq

This repository contains two scripts and sample data for quality control of Adaptive Immune Receptor Repertoire (AIRR) sequencing (AIRR-seq).

# 1. Pairing precision of VH-VL in two Technical split-replicates

`precision_hamming_calculator.sh` is a bash script used to compute pairing precision of VH-VL in two Technical split-replicates

Usage:  `bash precision_hamming_calculator.sh UNIQUE_FILE1 UNIQUE_FILE2`

It calculates precision from file1 and file2. file1 should be unique_pairs, as should file2

NOTES:
* This script has been tested only on bash 4.2

# 2. Rapid analysis to check for PCR contamination in adaptive immune receptor data

`contamination_analysis.py` is a python script used to detect cross-contamination events between AIRR-seq runs.

Usage:
`python contamination_analysis.py your_files your_metadata`

The script will `your_files` sharing a common name, and calculate the level of shared CDR3 nt sequences. Next, it will merge that information with `your_metadata`, to help track contamination events. 

The sample data provided consists on modeled human CDR H3 sequences using immuneSIM (https://immunesim.readthedocs.io/en/latest/). experiment_c* files were intentionally build from experiment_a* files to simulate sample contamination. 

NOTES: 
* This script was tested on python 3.6 and pandas 0.25.
* To run the script from this repository use `python contamination_analysis.py ./data_contamination/experiment ./data_contamination/modeled_metadata.txt`
* There should be no repeated CDR3 sequences in individual files.
