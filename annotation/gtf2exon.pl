#!/usr/bin/perl
use strict; use warnings;
undef my %pli; undef my %id; 
open IN, "/home/dantakli/resources/exac_nonpsych_z_pli.txt";
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $id = $r[0];
	my $pli = $r[19];
	$id{$id}=$r[1];
	$pli{$id}=$pli; 	
}close IN;
 
undef my %annot;
$annot{"exon"}++;
$annot{"start_codon"}++;
$annot{"stop_codon"}++; 
open IN, "less $ARGV[0] |";
while(<IN>){
	next if($_ =~ /^\#/);
	chomp;
	my @r = split /\t/, $_;
	my $annot = $r[2]; 
	next unless(exists $annot{$annot});
	undef my %info;
	my @info = split /\;/, $r[8];
	foreach (@info){
		my $i = $_; 
		$i =~ s/^ //;
		$i =~ s/\"//g;  
		my ($k,$v) = split / /, $i;
		$info{$k}=$v;
	}
	my $pli = "nan"; 
	my $trx = "na";
	my $gen = "na"; 
	if(exists $info{"transcript_id"}) {
		$trx = $info{"transcript_id"};
		$pli = $pli{$trx} if(exists $pli{$trx}); 
		$gen = $id{$trx} if(exists $id{$trx}); 
	}
	if ($gen eq "na" && exists $info{"gene_name"}) { $gen = $info{"gene_name"}; } 
	
	my $s = $r[3]; $s--;
	my $e = $r[4];

	next unless($pli ne "nan");
	next unless($pli >= 0.9);
	
	print "$r[0]\t$s\t$e\t$gen;$trx;$annot;$pli\n"; 
}close IN;
