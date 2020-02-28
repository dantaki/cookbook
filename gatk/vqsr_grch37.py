#!/usr/bin/env python
from argparse import RawTextHelpFormatter
import argparse

# input file variables
ref = "/home/dantakli/ref/human_g1k_v37_decoy.fasta"
dbsnp = "/projects/ps-gleesonlab5/resources/gatk_grch37/dbsnp_138.b37.vcf"
hapmap = "/projects/ps-gleesonlab5/resources/gatk_grch37/hapmap_3.3.b37.sites.vcf"
omni = "/projects/ps-gleesonlab5/resources/gatk_grch37/1000G_omni2.5.b37.sites.vcf"
snp_1kgp = "/projects/ps-gleesonlab5/resources/gatk_grch37/1000G_phase1.snps.high_confidence.b37.sites.vcf"
indel_1kgp = "/projects/ps-gleesonlab5/resources/gatk_grch37/1000G_phase1.indels.b37.vcf"
indel_mills = "/projects/ps-gleesonlab5/resources/gatk_grch37/Mills_and_1000G_gold_standard.indels.b37.sites.vcf"


parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter)
parser.add_argument('-snp',type=str, required=True,default=None,help='snp vcf')
parser.add_argument('-indel',type=str, required=True,default=None,help='indel vcf')
parser.add_argument('-L',type=str, required=False,default=None,help='region')
parser.add_argument('-t',type=int,required=False,default=1,help='threads')
parser.add_argument('-m',type=int,required=False,default=16,help='memory in GB')
parser.add_argument('-o',type=str, required=True,help='output prefix')
args = parser.parse_args()

snp_input = args.snp
indel_input = args.indel

out_pfx = args.o

region = args.L
if region==None:
	out_pfx = out_pfx
	region= ' '
else:
	out_pfx = out_pfx+'.{}'.format(region.replace(':','.').replace('-','.'))
	region = ' -L '+region

threads = args.t
mem = args.m

java = "/home/dantakli/java/jre1.8.0_73/bin/java"
gatk = '/home/dantakli/bin/GenomeAnalysisTK-3.8-1/GenomeAnalysisTK.jar'


snp_cmd = [
	java,
	' -Xmx{}G'.format(mem),
	' -jar ',
	gatk,
	' -T VariantRecalibrator -R {}'.format(ref),
	' -nt {}'.format(threads),
	' -input {}'.format(snp_input),
	region,
	" -resource:hapmap,known=false,training=true,truth=true,prior=15.0 {}".format(hapmap),
	" -resource:omni,known=false,training=true,truth=true,prior=12.0 {}".format(omni),
	" -resource:1000G,known=false,training=true,truth=false,prior=10.0 {}".format(snp_1kgp),
	" -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 {}".format(dbsnp),
	" -an QD",
	" -an FS",
	" -an SOR",
	" -an MQ",
	" -an MQRankSum",
	" -an ReadPosRankSum",
	" -mode SNP",
	" -tranche 100.0",
	" -tranche 99.9",
	" -tranche 99.5",
	" -tranche 99.0",
	" -tranche 90.0",
	" -recalFile {}.snv.recal".format(out_pfx),
	" -tranchesFile {}.snv.tranches".format(out_pfx),
	" -rscriptFile {}.snv.rscript".format(out_pfx),
]

snp_apply = [
	java,
	' -Xmx{}G'.format(mem),
	' -jar ',
	gatk,
	' -T ApplyRecalibration -R {}'.format(ref),
	' -input {}'.format(snp_input),
	region,
	" -ts_filter_level 99.5",
	" -tranchesFile {}.snv.tranches".format(out_pfx),
	" -recalFile {}.snv.recal".format(out_pfx),
	" -mode SNP",
	" -nt {}".format(threads),
	" -o {}.snv.vqsr.vcf".format(out_pfx),
]

indel_cmd = [
	java,
	' -Xmx{}G'.format(mem),
	' -jar ',
	gatk,
	' -T VariantRecalibrator -R {}'.format(ref),
	' -nt {}'.format(threads),
	' -input {}'.format(indel_input),
	region,
	" -resource:mills,known=true,training=true,truth=true,prior=12.0 {}".format(indel_mills),
	" -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 {}".format(dbsnp),
	" -an QD",
	" -an FS",
	" -an SOR",
	" -an MQRankSum",
	" -an ReadPosRankSum",
	" --maxGaussians 4",
	" -mode INDEL",
	" -tranche 100.0",
	" -tranche 99.9",
	" -tranche 99.5",
	" -tranche 99.0",
	" -tranche 90.0",
	" -recalFile {}.indel.recal".format(out_pfx),
	" -tranchesFile {}.indel.tranches".format(out_pfx),
	" -rscriptFile {}.indel.rscript".format(out_pfx),
]

indel_apply = [
	java,
	' -Xmx{}G'.format(mem),
	' -jar ',
	gatk,
	' -T ApplyRecalibration -R {}'.format(ref),
	' -input {}'.format(indel_input),
	region,
	" -ts_filter_level 99.0",
	" -tranchesFile {}.indel.tranches".format(out_pfx),
	" -recalFile {}.indel.recal".format(out_pfx),
	" -mode INDEL",
	" -nt {}".format(threads),
	" -o {}.indel.vqsr.vcf".format(out_pfx),
]



print(''.join(snp_cmd))
print(''.join(snp_apply))
print(''.join(indel_cmd))
print(''.join(indel_apply))

