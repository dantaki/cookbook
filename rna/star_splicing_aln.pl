#!/usr/bin/perl
use strict; use warnings;
my $p1 = $ARGV[0]; my $p2 = $ARGV[1];
my $ref = $ARGV[2];
my $threads = $ARGV[4]; 
my $opre = $ARGV[3];
$threads = 1 if(! defined $threads);

die "FATAL ERROR: missing input\n\n    star_splicing_aln.pl <P1.fq> <P2.fq> <REF_DIR> <OUTPUT_PREFIX> [THREADS]\n\n" if(! defined $p1 || ! defined $p2 || ! defined $ref || ! defined $opre); 

my $zcat = "";
$zcat = "--readFilesCommand zcat" if($p1 =~ /\.gz$/);

$threads = "--runThreadN $threads";
my $cmd = "STAR $threads --genomeDir $ref --twopassMode Basic --outSAMstrandField intronMotif --outSAMtype BAM Unsorted --outFileNamePrefix $opre $zcat $p1 $p2 ";

exec($cmd);
