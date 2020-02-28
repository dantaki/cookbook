#!/usr/bin/perl
use strict; use warnings;
open IN, $ARGV[0];
<IN>;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $k = join ":", @r[0 .. 2];
	$k =~ s/\"//g;

	my $usee = $r[10];
	my $es1 = $r[5];
	my $ee1 = $r[6];
	my $es2 = $r[7];
	my $ee2 = $r[8];
	my $dses = $r[11];

	$usee--; # end to 0-base start
	$es1++; $ee1--;
	$dses++;
	$es2++; $ee2--;
	my $strand = $r[4];
	print "$r[3]\t$usee\t$es1\t$k\t.\t$strand\n";
	print "$r[3]\t$ee1\t$dses\t$k\t.\t$strand\n";
	print "$r[3]\t$usee\t$es2\t$k\t.\t$strand\n";
	print "$r[3]\t$ee2\t$dses\t$k\t.\t$strand\n"; 
	
}close IN;
