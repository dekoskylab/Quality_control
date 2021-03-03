# Quality control scripts for AIRR-seq

This repository contains scripts and sample data for quality control of Adaptive Immune Receptor Repertoire (AIRR) sequencing (AIRR-seq).

# 1. Heavy and light chain pairing precision of in split-replicate B cell samples

`precision_calculator.sh` is a bash script used to compute the pairing precision of heavy and light chains observed in split-replicate B cell samples

Usage:  `bash precision_calculator.sh UNIQUE_FILE1 UNIQUE_FILE2`

file1 should contain the observed paired read counts, heavy chain nucleotide junction sequence, and light chain nucleotide junction sequence in a tab-separated file format for the first cell sample replicate. file2 should contain the same information for the second cell sample replicate.

NOTES:
* This script has been tested only on bash 4.2

# 2. Rapid QC analysis to check for lab-wide PCR contamination in collected adaptive immune receptor data

`PCR_QC_analysis.py` is a python script used to verify the absence of cross-contamination events in AIRR-seq runs collected by a research group or laboratory.

Usage: `python PCR_QC_analysis.py your_files your_metadata`

The script will process your_files, and calculate the level of shared CDR3 nt junction sequences. Next, it will merge the results with your_metadata, to help rapidly identify and isolate any possible PCR contamination events.
Sample data provided consists of modeled human CDR-H3 sequences using immuneSIM (https://immunesim.readthedocs.io/en/latest/). experiment_c* files were intentionally built from experiment_a* files as a positive control to simulate sample contamination.


NOTES: 
* This script has been tested on python 3.6, python 3.7 and pandas 0.25.
* To run the script from this repository use python contamination_analysis.py ./data_contamination/experiment ./data_contamination/modeled_metadata.txt
* CDR-H3 nucleotide sequence convergence is quite rare, and there should be very few repeated CDR-H3 sequences in individual files.  CDR-L3 sequences are less diverse and often shared among different individuals, and some overlap in CDR-L3 is expected.
* NGS samples sequenced on the same Illumina instrument run (or even occasionally, on a run directly following another sample) can show low levels of expected read overlap due to a variety of mechanisms; one important mechanisms is index hopping (https://www.illumina.com/techniques/sequencing/ngs-library-prep/multiplexing/index-hopping.html ). For NGS samples sequenced together on the same Illumina instrument, the level of CDR-H3 nucleotide sequence overlap should not exceed around 0.05% per sample, but can vary based on the prevalence of different samples within the run.

