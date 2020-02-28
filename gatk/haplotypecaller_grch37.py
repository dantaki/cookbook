#!/usr/bin/env python
from argparse import RawTextHelpFormatter
import argparse

# input file variables
ref = "/home/dantakli/ref/human_g1k_v37_decoy.fasta"
dbsnp = "/projects/ps-gleesonlab5/resources/gatk_grch37/dbsnp_138.b37.vcf"

parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter)
parser.add_argument('-i',type=str, required=True,default=None,action='append', nargs='+',help='bam')
parser.add_argument('-L',type=str, required=False,default=None,help='region')
parser.add_argument('-t',type=int,required=False,default=1,help='threads')
parser.add_argument('-m',type=int,required=False,default=16,help='memory in GB')
parser.add_argument('-o',type=str, required=True,help='output prefix')
args = parser.parse_args()

bams = '-I '+' -I '.join(map(str,[x[0] for x in args.i]))
out_pfx = args.o

region = args.L
if region==None:
	out_pfx = out_pfx+'.hpcaller.vcf'
else:
	out_pfx = out_pfx+'.{}.hpcaller.vcf'.format(region.replace(':','.').replace('-','.'))
	region = ' -L '+region

threads = args.t
mem = args.m

java = "/home/dantakli/java/jre1.8.0_73/bin/java"
gatk = '/home/dantakli/bin/GenomeAnalysisTK-3.8-1/GenomeAnalysisTK.jar'

cmd = [
	java,
	' -Xmx{}g'.format(mem),
	' -jar ',
	gatk,
	' -T HaplotypeCaller -R {}'.format(ref),
	' -nct {}'.format(threads),
	' {}'.format(bams),
	' -D {}'.format(dbsnp),
	region,
	' -o {}'.format(out_pfx)
]

print(''.join(cmd))

