#!/usr/bin/perl
use strict; use warnings;
open IN, $ARGV[0];
<IN>;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $k = join ":", @r[0 .. 2];
	$k =~ s/\"//g;
	my $usee = $r[8];
	my $dses = $r[9];
	$usee++; $dses--;
	my $strand= $r[4];
	print "$r[3]\t$usee\t$dses\t$k\t.\t$strand\n"; 
	
}close IN;
