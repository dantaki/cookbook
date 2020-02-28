#!/bin/sh

vcf=$1
pre=$2
sex=$3

ref="/home/dantakli/ref/human_g1k_v37_decoy.fasta"
dup="/home/dantakli/res/dup.grch37.bed.gz"

bcftools view --no-version -h $vcf | sed 's/^\(##FORMAT=<ID=AD,Number=\)\./\1R/' | \
bcftools reheader -h /dev/stdin $vcf | \
bcftools filter --no-version -Ou -e "FMT/DP<10 | FMT/GQ<20" --set-GT . | \
bcftools annotate --no-version -Ou -x ID,QUAL,INFO,^FMT/GT,^FMT/AD | \
bcftools norm --no-version -Ou -m -any --keep-sum-AD | \
bcftools norm --no-version -Ob -o $pre.unphased.bcf -f $ref && \
bcftools index $pre.unphased.bcf

n=$(bcftools query -l $pre.unphased.bcf|wc -l); \
ns=$((n*98/100)); \
echo '##INFO=<ID=JK,Number=1,Type=Float,Description="Jukes Cantor">' | \
  bcftools annotate --no-version -Ou -a $dup -c CHROM,FROM,TO,JK -h /dev/stdin $pre.unphased.bcf | \
  bcftools +fill-tags --no-version -Ou -- -t NS,ExcHet | \
  bcftools +mochatools --no-version -Ou -- -x $sex -G | \
  bcftools annotate --no-version -Ob -o $pre.xcl.bcf \
    -i 'FILTER!="." && FILTER!="PASS" || JK<.02 || NS<'$ns' || ExcHet<1e-6 || AC_Sex_Test>6' \
    -x FILTER,^INFO/JK,^INFO/NS,^INFO/ExcHet,^INFO/AC_Sex_Test && \
  bcftools index -f $pre.xcl.bcf
