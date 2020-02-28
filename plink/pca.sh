#!/bin/sh
bfile=$1
plink --bfile $bfile --pca --out $bfile\.pca

less $bfile\.pca.eigenval | tabbit >$bfile\.tmp 
mv $bfile\.tmp $bfile\.pca.eigenval

less $bfile\.pca.eigenvec | tabbit >$bfile\.tmp
mv $bfile\.tmp $bfile\.pca.eigenvec

