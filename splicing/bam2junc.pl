#!/usr/bin/perl
use strict; use warnings;
my $bam = $ARGV[0];
my $junc = $bam; $junc =~ s/\.bam/\.junc/;
my $sh = "/home/dantakli/leafcutter/scripts/bam2junc.sh";
my $cmd = "$sh $bam $junc";

exec($cmd);
