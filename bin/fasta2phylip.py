#! /usr/bin/env python
'''
'''
import sys
from Bio import AlignIO
 
input_handle = open(sys.argv[1], "rU")
output_handle = open(sys.argv[2], "w")
 
alignments = AlignIO.parse(input_handle, "fasta")
AlignIO.write(alignments, output_handle, "phylip")
 
output_handle.close()
input_handle.close()
