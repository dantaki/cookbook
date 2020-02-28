#!/usr/bin/perl
use strict; use warnings;
open IN, "$ARGV[0]";
undef my %col;
chomp(my $h=<IN>);
my @h = split /\t/, $h;
for(my $i=0; $i<scalar(@h); $i++){
	$col{$h[$i]}=$i;
}
my @col = 
qw/ID
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
	my $str = $r[$col{"strand"}];
	undef my @p;
	if($str eq "+"){
		push @p, $r[$col{"longExonEnd"}];
		push @p, $r[$col{"shortEE"}];
	}
	if($str eq "-"){
		push @p, $r[$col{"longExonStart_0base"}];
		push @p, $r[$col{"shortES"}];
	}
	next if(scalar(@p) != 2);
	my @sort = sort {$a<=>$b} @p;
	for my $c (@col){
		push @o, $r[$col{$c}];
	}
	my $o = join "\t", $r[$col{"chr"}],@sort,@o;
	$o =~ s/\"//g;
	print "$o\n"; 
}close IN;
