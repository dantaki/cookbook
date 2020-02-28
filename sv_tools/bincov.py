#Import libraries
import argparse
import sys
from subprocess import call
import pysam
import pybedtools
import gzip
import shutil
import os

#Function to return read or fragment intervals from pysam.AlignmentFile
def filter_mappings(Bam,region):
    for Aln in Bam.fetch(region=region):
        if Aln.is_duplicate or Aln.is_unmapped or Aln.is_secondary or Aln.is_supplementary: continue
        yield '\t'.join((Aln.reference_name,
                         str(Aln.reference_start),
                         str(Aln.reference_end)))+'\n'

#Function to evaluate nucleotide or physical coverage
def binCov(Bam,region, bin_size,exclude):
    bins=[]
    chrom,pos = region.split(':')
    start,end = pos.split('-')
    for i in range(int(start),int(end),bin_size):
        bins.append((chrom, i, i+bin_size))
    bins = pybedtools.BedTool(bins)

    #Remove bins that have at least 5% overlap with exclude by size
    overlap=0.05
    if exclude != None:
        blist = pybedtools.BedTool(exclude)
        bins_filtered = bins.intersect(blist, v=True, f=overlap)
    else:
        bins_filtered = bins

    #Filter bam
    mappings = filter_mappings(Bam,region)
    bambed = pybedtools.BedTool(mappings)

    coverage = bins_filtered.coverage(bambed,counts=True)
    return coverage


#Main function
def main():
    #Add arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', type=str,help='bam file',required=True)
    parser.add_argument('-r', help='region <chr:to-from> 1-base',required=True)
    parser.add_argument('-b', type=int, default=100,help='bin size [100]')
    parser.add_argument('-x', type=str, default=None,help='bed file of excluded regions')
    parser.add_argument('-o', type=str,default=None,help='output')
    args = parser.parse_args()
    bam, region, bin_size, exclude,outfile = args.i,args.r,args.b,args.x,args.o
    Bam = pysam.AlignmentFile(bam)

    if outfile == None: outfile = bam.split('/').pop().replace('.bam','.binnedcoverage.txt')
    #Get coverage & write out
    coverage = binCov(Bam, region, bin_size,exclude)

    coverage.saveas(outfile)
    call('sort -Vk1,1 -k2,2n -o ' + outfile + ' ' + outfile,
         shell=True)

#Main block
if __name__ == '__main__':
    main()

