#!/usr/bin/perl
use strict; use warnings;

my $gatk = "/home/dantakli/bin/gatk-4.0.5.1/gatk";

my $vcf = $ARGV[0];
my $ref = $ARGV[1];
my $chain = $ARGV[2];
my $odir = $ARGV[3];
my $mem  = $ARGV[4];

my $usage = "    perl liftover_vcf.pl <in.vcf.gz> <ref.fa> <chain.gz> [output dir] [memory in GB]";

if(! defined $vcf) { die "FATAL ERROR: VCF FILE MISSING\n$usage\n"; } 
if(! defined $ref) { die "FATAL ERROR: FASTA MISSING\n$usage\n";  }
if(! defined $chain) { die "FATAL ERROR: CHAIN FILE MISSING\n$usage\n"; } 


$mem = "8G" if(! defined $mem);
my @chain = split /\./, $chain;
my @build = split /To/, $chain[0]; 
my $end_build = lc($build[-1]);

undef my $ovcf; undef my $uvcf;
my $fh = $vcf;

if( defined $odir) {
	my @fh = split /\//, $vcf; 
	$fh = pop @fh;
	$odir = $odir."/" if($odir !~ /\/$/);
	$fh = $odir.$fh;
}

$ovcf = $fh;
$ovcf =~ s/\.gz//;
$ovcf =~ s/\.vcf/\.$end_build\.vcf/;
$uvcf = $fh;
$uvcf =~ s/\.gz//;
$uvcf =~ s/\.vcf/\.unmapped\.$end_build\.vcf/;

my $cmd = "$gatk LiftoverVcf --java-options \"-Xmx$mem\" -R $ref --CHAIN $chain --INPUT $vcf --OUTPUT $ovcf --REJECT $uvcf";

system($cmd); 
