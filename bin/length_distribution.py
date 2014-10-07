#! /usr/bin/env python
'''
    Output the length distribution of an input FASTA file.
'''
import sys
from collections import Counter
from Bio import SeqIO

print 'length\tcount'
lengths = Counter([len(seq) for seq in SeqIO.parse(sys.argv[1], "fasta")])
for k in sorted(list(lengths)):
    print '{0}\t{1}'.format(k, lengths[k])
    