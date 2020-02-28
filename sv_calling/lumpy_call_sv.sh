#!/bin/sh

BAM=$1 # first argv

# bed file of excluded regions
EXCLUDE=$2

DISC=${BAM/.bam/.disc.bam}
SPLIT=${BAM/.bam/.split.bam}

lumpyexpress -B $BAM -D $DISC -S $SPLIT -o blah -v -x $EXCLUDE -T tmpdir

