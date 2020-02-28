#!/usr/bin/perl
use strict; use warnings;
my $p1 = $ARGV[0]; my $p2 = $ARGV[1];
my $ref = $ARGV[2];
my $threads = $ARGV[4]; 
my $opre = $ARGV[3];
$threads = 1 if(! defined $threads);

die "FATAL ERROR: missing input\n\n    star_splicing_aln.pl <P1.fq> <P2.fq> <REF_DIR> <OUTPUT_PREFIX> [THREADS]\n\n" if(! defined $p1 || ! defined $p2 || ! defined $ref || ! defined $opre); 

my @ref = split /\//, $ref;
my $rg = pop @ref; 
$rg =~ s/star_//;

my $zcat = "";
$zcat = "--readFilesCommand zcat" if($p1 =~ /\.gz$/);
my $fq = "--readFilesIn $p1  $p2";
my $gleopt = "--outFilterType BySJout --outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04";
$gleopt = $gleopt." --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --outSAMunmapped Within --outSAMattributes NH HI AS NM MD --quantMode GeneCounts TranscriptomeSAM";
$gleopt = $gleopt." --outSAMattrRGline ID:$rg SM:$rg PL:ILLUMINA LB:ILLUMINA";

$threads = "--runThreadN $threads";
my $cmd = "STAR $threads --genomeDir $ref --twopassMode Basic $fq $zcat $gleopt --outSAMstrandField intronMotif --outSAMtype BAM Unsorted --outFileNamePrefix $opre";

exec($cmd);
