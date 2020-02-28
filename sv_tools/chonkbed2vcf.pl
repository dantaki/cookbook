#!/usr/bin/perl
use strict; use warnings;
my $head = '##fileformat=VCFv4.2
##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
##INFO=<ID=SVLEN,Number=.,Type=Integer,Description="Difference in length between REF and ALT alleles">
##INFO=<ID=END,Number=1,Type=Integer,Description="End position of the variant described in this record">
##INFO=<ID=CIPOS,Number=2,Type=Integer,Description="Confidence interval around POS">
##INFO=<ID=CIEND,Number=2,Type=Integer,Description="Confidence interval around END">
##ALT=<ID=DEL,Description="Deletion">
##ALT=<ID=DUP,Description="Duplication">
##ALT=<ID=INV,Description="Inversion">
#';
undef my %chrom;
for(my $i=1; $i<23; $i++) { $chrom{$i}++; } 
$chrom{"X"}++; $chrom{"Y"}++; 

print "$head#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n"; 
open IN, $ARGV[0];
<IN>;
my $id=1;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $p = $r[1]+1; 
	my $len = $r[2]-$r[1];
	next if($len < 50);
	next if($len > 10000000);
	next unless(exists $chrom{$r[0]}); 
	$len = $r[1]-$r[2] if($r[3] =~ /DEL/); 
	print "$r[0]\t$p\tCHONK:${id}\tN\t<$r[3]>\t.\t.\tEND=$r[2];SVTYPE=$r[3];SVLEN=$len;CIPOS=0,0;CIEND=0,0\n";
	$id++;
}close IN;
