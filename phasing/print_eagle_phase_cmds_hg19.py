#!/usr/bin/env python
from argparse import RawTextHelpFormatter
import argparse

# input file variables
ref = "/home/dantakli/ref/human_g1k_v37_decoy.fasta"
map = "/home/dantakli/res/genetic_map_hg19_withX.txt.gz"
kgp_pfx = "/projects/ps-gleesonlab5/reference_panels/1kgp/ALL.chr"
kgp_sfx = ".phase3_integrated.20130502.genotypes"
rule = "GRCh37"
cnp = "/home/dantakli/resources/1kgp/ALL.wgs.mergedSV.v8.20130502.svs.GRCh37.common.cnp.bed"
dup = "/home/dantakli/res/dup.grch37.bed.gz"
cyto = "/home/dantakli/res/cytoBand.hg19.txt.gz"


parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter)
parser.add_argument('-i',type=str, required=True,default=None,help='bcf target')
parser.add_argument('-x',type=str, required=True,default=None,help='bcf exclude')
parser.add_argument('-t',type=int,required=False,default=1,help='threads')
parser.add_argument('-o',type=str, required=True,help='output prefix')
args = parser.parse_args()

# edit so that it does NOT iterate through all the chromosomes.
# probably easiest to either parse the chromosome name from the file that 
# you input. OR make a new argument `-c` 



chroms = list(range(1,23))+['X','Y']
for chr in chroms:
	chr = str(chr)
	eagle_cmd = 'eagle --geneticMapFile '+map+' --outPrefix '+args.o+'.'+chr+' --numThreads '\
		+str(args.t)+' --vcfRef '+kgp_pfx+chr+kgp_sfx+'.bcf --vcfTarget '+args.i+' --vcfOutFormat b --noImpMissing --outputUnphased --vcfExclude '\
		+args.x+' --chrom '+chr+' --pbwtIters 3'
	print(eagle_cmd)
