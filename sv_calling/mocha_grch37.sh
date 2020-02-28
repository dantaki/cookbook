#!/bin/sh
# INPUT 
in_vcf=$1
exclude_vcf=$2
output_prefix=$3
threads=$4
## VARIABLES
ref=/home/dantakli/ref/human_g1k_v37_decoy.fasta
map=/home/dantakli/res/genetic_map_hg19_withX.txt.gz
kgp_pfx=/projects/ps-gleesonlab5/reference_panels/1kgp/ALL.chr
kgp_sfx=.phase3_integrated.20130502.genotypes
rule=GRCh37
cnp=/home/dantakli/resources/1kgp/ALL.wgs.mergedSV.v8.20130502.svs.GRCh37.common.cnp.bed
dup=/home/dantakli/res/dup.grch37.bed.gz
cyto=/home/dantakli/res/cytoBand.hg19.txt.gz
##########
