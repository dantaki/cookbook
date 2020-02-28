#!/usr/bin/env python
from argparse import RawTextHelpFormatter
import argparse

parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter)
parser.add_argument('-i',type=str, required=True,default=None,help='vcf')
parser.add_argument('-o',type=str, required=True,help='output prefix')
args = parser.parse_args()

vcf = args.i
out = args.o

cmd = 'bcftools view -i\'TYPE=="SNP" && N_ALT==1\' {} | bcftools annotate -Oz -o {}.reid.vcf.gz -x ID -I +\'%CHROM:%POS:%REF:%ALT\''.format(vcf,out)
print(cmd)
