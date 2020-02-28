#!/usr/bin/perl
use strict; use warnings;
my $annot = "/home/dantakli/resources/utr_tss_fetalbrain_promoter_exon.hg19.bed";
my $oe = "/home/dantakli/resources/gnomad/gnomad.v2.1.1.lof_metrics.by_gene.txt";
undef my %oe;
open IN, "$oe";
<IN>;
while(<IN>){
	chomp; my @r= split /\t/, $_;
	next if($r[29] eq "NA");
	$oe{$r[0]}=$r[29];
}close IN;

my $bed = $ARGV[0];

undef my %sv;

my $cmd = "intersectBed -a $bed -b $annot -wa -wb | grep \"exon\" | ";
open IN, "$cmd";
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $k = join "\t", @r[0 .. 2];
	my $g = $r[-1];
	
	push @{$sv{$k}}, $g;	
}close IN; 

foreach my $k (sort keys %sv){
	my $min_oe = 1e6; # large dummy value
	my $min_g = "nan";
	foreach my $g (@{$sv{$k}}){
		if(exists $oe{$g} && $oe{$g} < $min_oe) {
			$min_oe = $oe{$g};
			$min_g = $g;
		}
	
	}
	next if($min_g eq "nan"); # skip if not annotated for functional constraint
	print "$k\t$min_g\t$min_oe\n"; 
}
