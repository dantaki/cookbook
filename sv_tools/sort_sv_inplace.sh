#!/bin/sh
bed=$1
sort -k1,1 -k2,2n -k3,3n $bed >${bed}.tmp
mv ${bed}.tmp $bed

