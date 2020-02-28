#!/bin/sh

BAM=$1 # first argv
OUT=$2 # secord argv
THREAD=$3 # third argv
THREAD=${THREAD:=1} # if not defined set to 1

samtools view -bh -@ $THREAD -F 1294 $BAM >$OUT
