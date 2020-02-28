#!/usr/bin/perl
use strict; use warnings;
open IN, $ARGV[0];
<IN>;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $k = join ":", @r[0 .. 2];
	$k =~ s/\"//g;

	my $strand = $r[4];
	if($strand eq "+"){
		my $lee = $r[6];
		my $fes = $r[9];
		my $see = $r[8];
		$fes++; 
		$lee--; $see--;
		print "$r[3]\t$lee\t$fes\t$k\t.\t$strand\n";
		print "$r[3]\t$see\t$fes\t$k\t.\t$strand\n"; 
	} 
	if($strand eq "-"){
		my $les = $r[5];
		my $fee = $r[10];
		my $ses = $r[7];
		$fee--;
		$les++; $ses++;
		print "$r[3]\t$fee\t$les\t$k\t.\t$strand\n"; 
		print "$r[3]\t$fee\t$ses\t$k\t.\t$strand\n"; 
	}
	
}close IN;
