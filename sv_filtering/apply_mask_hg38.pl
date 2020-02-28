#!/usr/bin/perl
use strict; use warnings;
# PRINTS OUT SVS TO FILTER
my $exc = "/home/dantakli/resources/hg38.sv.mask.merged.parexcluded.bed";
my $bed = $ARGV[0];
die "FATAL ERROR: BED file required\n" if(! defined $bed);

undef my %ovr; 
open IN, "intersectBed -a $bed -b $exc -wao | ";
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $k = join "\t", @r[0 .. 2];
	my $o = pop @r;
	$ovr{$k}+=$o;
}close IN;

open IN, $bed;
while(<IN>){
	chomp;
	my @r  = split /\t/, $_;
	my ($c,$s,$e) = @r[0 .. 2];
	my $sz = $e-$s;
	my $k = join "\t", @r[ 0 .. 2];
	my $ovr = $ovr{$k}/$sz;
	print "$_\n" if($ovr < 2/3); 
} close IN;

