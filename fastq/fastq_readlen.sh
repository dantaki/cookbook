#!/bin/sh
FASTQ=$1
less $FASTQ | awk '{if(NR%4==2) print length($1)}' | sort -n | uniq -c 
