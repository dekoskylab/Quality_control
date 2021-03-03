#!/usr/bin/env python

# -*- coding: utf-8 -*-

''' This script selects a set of BCR or TCR annotated files, and merges them by cdr3 sequence to assess the f
raction of shared sequences. The obtained value can be used as a proxy for cross-contamination among samples. 

The output information is then merged with file metadata to track possible sources of contamination.

The folder containing this script should contain a list of files with a common naming convention that allows
the capture of files using glob.glob. Note that in it's current form, the files matched have a .txt extension.

Example usage

python contamination_analysis.py your_files your_metadata

In the output file, the first column is the query file, the second column in the file being matched with the
query file. The
'''

import os
import glob
import argparse
import pandas as pd
import itertools
from datetime import datetime


###Timing script
startTime = datetime.now()

###Useful functions
def subset_pd(df,col, name): ###Subsets df based on name in col
    subs = df.loc[df[col] == name]
    return(subs)

def div_zero(n, d):
    return n / d if d else 0

###Parse command line arguments
parser = argparse.ArgumentParser(description='finds shared CDRH3 nt sequences between unique_final files, and retrieves a formarted xls file')
parser.add_argument('file_pattern', type=str, help='Character expansion pattern to match files to query')
parser.add_argument('metadata', type = str, help = 'NGS metadata information')

args = parser.parse_args()
myfiles = str(args.file_pattern)
metadata = args.metadata

###Select files using glob
file_list = glob.glob("*" + myfiles + "*")
###Column names to load
colnames = ['sequence_id', 'cdr3', 'c_call']

###Column names to output. The number of matches between file_id_1 and file_id_2 are divided by the number of lines in file_id_1
labels = ["file_id_1", "file_id_2","total", "IGG", "IGA", "IGM"]

###Matching loop for all pairwise combinations
output_list = [] 
for i in itertools.product(file_list,repeat=2):
    df1 = pd.read_csv(i[0], sep ="\t", names = colnames)
    df2 = pd.read_csv(i[1], sep ="\t", names = colnames)
    reads1 = df1.shape[0]
    
    df1['cdr3'] = df1['cdr3'].str.upper()
    df2['cdr3'] = df2['cdr3'].str.upper()
    
    ###Match files by cdr3 and divide number of matches by number of files in left file
    CDRH3nt_match = df1.merge(df2, on="cdr3", suffixes = ["_left", "_right"])
    total = div_zero(CDRH3nt_match.shape[0],reads1)
    
    ###Bin by isotype and repeat
    IGG = div_zero(subset_pd(CDRH3nt_match, "c_call_left", "IgG").shape[0],subset_pd(df1, "c_call", "IgG").shape[0])
    IGA = div_zero(subset_pd(CDRH3nt_match, "c_call_left", "IgA").shape[0],subset_pd(df1, "c_call", "IgA").shape[0])
    IGM = div_zero(subset_pd(CDRH3nt_match, "c_call_left", "IgM").shape[0],subset_pd(df1, "c_call", "IgM").shape[0])

    ###Prepare to output    
    output = [i[0], i[1],total, IGG, IGA, IGM]
    
    output_list.append(output)

output_df=pd.DataFrame(output_list,columns=labels)
meta_df = pd.read_csv(metadata, sep = "\t")

###Merges output file with metadata
final_df = output_df.merge(meta_df, left_on = "file_id_1", right_on = "file")
###File name plus current time
output_name = "./contamination_analysis_" + datetime.now().strftime("%Y-%m-%d-%H:%M:%S").replace(":","")

###Saves to csv
final_df.to_csv(output_name, sep = "\t")

print("Analysis completed in " + str(datetime.now() - startTime))
