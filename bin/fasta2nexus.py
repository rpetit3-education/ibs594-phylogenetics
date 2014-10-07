#! /usr/bin/env python
'''
'''
import sys
from Bio import AlignIO
from Bio.Alphabet import IUPAC, Gapped
 
input_handle = open(sys.argv[1], "rU")
output_handle = open(sys.argv[2], "w")
 
alignments = AlignIO.parse(input_handle, "fasta", alphabet=Gapped(IUPAC.unambiguous_dna))
AlignIO.write(alignments, output_handle, "nexus")
 
output_handle.close()
input_handle.close()
