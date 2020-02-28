#!/usr/bin/perl
use strict; use warnings;

sub constraint 
{
undef my %constr;
my $exac = "/home/dantakli/resources/exac_nonpsych_z_pli.txt";
my $gnom = "/home/dantakli/resources/gnomad/gnomad.v2.1.1.lof_metrics.by_gene.txt";
open IN, $exac;
<IN>;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $gene = $r[1];
	my $pli = $r[19];
	my $t=1;
	$t=2 if($pli <0.9908471442483491);
	$t=3 if($pli <=0.0599837815190294);

	$constr{$gene}{"exac"}="$pli;$t";

}close IN;

open IN, $gnom;
<IN>;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $gene = $r[0];
	my $pli = $r[20];
	my $oe = $r[29];
	next if($pli eq "NA");
	my $pt=1;
	$pt=2 if($pli <0.9917299999999999);
	$pt=3 if($pli <=0.0023642);
	my $ot=1;
	next if($oe eq "NA");
	$ot=2 if($oe >0.268);
	$ot=3 if($oe >=0.911);
	
	$constr{$gene}{"gpli"}="$pli;$pt";
	$constr{$gene}{"louf"}="$oe;$ot";  
}close IN;

return \%constr; 

}

