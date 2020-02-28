#!/bin/sh
bfile=$1

window_size=50
step=10
r=0.1

plink --bfile $bfile --indep-pairwise $window_size $step $r --out $bfile 
plink --bfile $bfile --extract $bfile\.prune.in --make-bed --out $bfile\.pruned
 
