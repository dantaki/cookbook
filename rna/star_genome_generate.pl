#!/usr/bin/perl
use strict; use warnings;

my $ref = $ARGV[0];
my $gtf = $ARGV[1];
my $overhang = $ARGV[2];
my $name = $ARGV[3];
my $thread = $ARGV[4];
$name="ref" if(! defined $name); 
$overhang=100 if(! defined $overhang);
$thread = 1 if(! defined $thread);

die "FATAL ERROR: Invalid input\n\n    star_genome_generate <IN.FASTA> <IN.GTF> [OVERHANG NAME THREADS]\n\n" if(! defined $ref || ! defined $gtf);

my @f = split /\//, $ref;
pop @f; my $odir = join "/", @f;
my $tmpdir = $odir; $tmpdir = $tmpdir."/star_tmp\_$name/";
$odir = $odir."/star_$name/";

system("mkdir -p $odir");

# RUN STAR
exec("STAR --runThreadN $thread --runMode genomeGenerate --genomeDir $odir --genomeFastaFiles $ref --sjdbGTFfile $gtf --sjdbOverhang $overhang --outTmpDir $tmpdir");


