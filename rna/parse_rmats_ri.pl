#!/usr/bin/perl
use strict; use warnings;
open IN, "$ARGV[0]";
undef my %col;
chomp(my $h=<IN>);
my @h = split /\t/, $h;
for(my $i=0; $i<scalar(@h); $i++){
	$col{$h[$i]}=$i;
}
my @col = qw/chr
riExonStart_0base
riExonEnd
ID
GeneID
geneSymbol
strand
PValue
FDR
IncLevel1
IncLevel2
IncLevelDifference
/;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	undef my @o;
	for my $c (@col){
		push @o, $r[$col{$c}];
	}
	my $o = join "\t", @o;
	$o =~ s/\"//g;
	print "$o\n"; 
}close IN;
