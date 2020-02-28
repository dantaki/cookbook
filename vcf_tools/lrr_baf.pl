#!/usr/bin/perl
use strict; use warnings;
my $vcf = $ARGV[0];
my $sm = $ARGV[1];
my $r = $ARGV[2];

my $cmd = "bcftools query -i'type=\"snp\"' -s $sm -r $r -f'[%CHROM\\t%POS\\t%REF\\t%ALT\\t%GT\\t%DP\\t%AD\\n]' $vcf";

open IN, "$cmd |"; 
undef my %mean;
while(<IN>) {
	chomp;
	my ($c,$p,$r,$a,$gt,$dp,$ad) = split /\t/, $_;
	next if($dp eq ".");
	next if($a =~ /,/);
	$mean{$dp}++; 
}close IN;

my $top=0; my $sum=0; 
foreach my $k (keys %mean){ 
	$top+=$k*$mean{$k};
	$sum+=$mean{$k};
}
my $mean = $top/$sum;
warn "mean $r :: $mean\n"; 
 
print "#chrom\tpos\tref\talt\tgt\tlrr\tbaf\n"; 
open IN, "$cmd |"; 
while(<IN>){
	chomp;
	my ($c,$p,$ref,$alt,$gt,$dp,$ad) = split /\t/, $_;
	next if($alt =~ /,/);
	my ($a,$b) = split /,/, $ad;
	next if($a eq "." || $b eq ".");
	next if($a+$b==0);
	my $baf = $b/($a+$b);
	my $lrr = log2($dp/$mean);	
	my $s = $p-1;
	print "$c\t$s\t$p\t$ref\t$alt\t$gt\t$lrr\t$baf\n"; 
}close IN;  


sub log2 {
            my $n = shift;
            return log($n)/log(2);
}

