#!/bin/sh

BAM=$1 
VCF=$2

OUT=${VCF/.vcf/.gt.vcf}

svtyper -B $BAM -i $VCF -o $OUT
