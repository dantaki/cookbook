#!/usr/bin/perl
use strict; use warnings;
undef my %sig;
my $sig_fh = $ARGV[0];
my $eff_fh = $sig_fh; 
$eff_fh =~ s/cluster_significance/effect_sizes/;

open IN, "$sig_fh";
<IN>;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $k = $r[0];
	my $p = $r[4];
	next if($p eq "NA");
	my $v = "$p\t$r[6]";
	$sig{$k}=$p;
}close IN;

open IN, $eff_fh;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	
}close IN;

