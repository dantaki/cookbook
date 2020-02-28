#!/bin/sh

BAM=$1 # first argv
THREAD=$2 # second argv
THREAD=${THREAD:=1} # if not defined set to 1

OUT=${BAM/.bam/.split.bam}

samtools view -h -@ $THREAD $BAM | /home/dantakli/bin/extractSplitReads_BwaMem -i stdin | samtools view -hb -@ $THREAD >$OUT


#samtools view -h -@ $THREAD $BAM | /home/dantakli/bin/extractSplitReads_BwaMem -i stdin | samtools view -hb -@ $THREAD | samtools sort -@ $THREAD -O BAM -o $OUT
#samtools index -@ $THREAD $OUT

