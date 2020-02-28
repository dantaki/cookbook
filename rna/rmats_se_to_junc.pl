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
	$usee--; #convert end position to 0-base start
	my $es = $r[5]; 
	$es++; #convert start position to half-open end
	my $ee = $r[6];
	$ee--; #convert end position to 0-base start
	my $ds = $r[9]; 
	$ds++; # convert start to half-open end
	my $strand = $r[4];

	print "$r[3]\t$usee\t$es\t$k\t.\t$strand\n";
	print "$r[3]\t$ee\t$ds\t$k\t.\t$strand\n";
	print "$r[3]\t$usee\t$ds\t$k\t.\t$strand\n";
	
}close IN;
