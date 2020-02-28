#!/usr/bin/perl
use strict; use warnings;
open IN, "less $ARGV[0] | ";
while(<IN>){
	chomp;
	next if($_ =~ /^#/);
	my @r = split /\t/, $_;
	my $c = $r[0];
	my $s = $r[1]-1;
	undef my $e; undef my $cl;
	my @info = split /\;/, $r[7];
	foreach my $i (@info) {
		$e = $i if($i =~ /^END=/);
		$cl = $i if($i =~ /^SVTYPE=/);
	}
	next if (! defined $e);
	next if(! defined $cl);
	$e =~ s/END=//;
	$cl =~ s/SVTYPE=//;
	print "$c\t$s\t$e\t$cl\n"; 
}close IN;
