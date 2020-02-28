#!/usr/bin/perl
use strict; use warnings;
my $STR = "/home/dantakli/resources/hg19_str_merged.bed.gz";
my $tmp = "str_tmp/";
system("mkdir -p $tmp");
my $bed = $ARGV[0];
open IN, $bed;
my $str = $tmp."str.bed";
my $end = $tmp."end.bed";
open STR, ">$str"; open END, ">$end";
while(<IN>){
        chomp;
        my @r = split /\t/, $_;
        print STR "$r[0]\t$r[1]\t",$r[1]+1,"\n";
        print END "$r[0]\t",$r[2]-1,"\t$r[2]\n";
}close IN; close STR; close END;
undef my %str;
open IN, "intersectBed -a $str -b $STR -wa -u |";
while(<IN>){
        chomp; 
	my $k = get_1base_pos($_);
	$str{$k}++;       
}close IN;
open IN, "intersectBed -a $end -b $STR -wa -u |";
while(<IN>){
	chomp;
	my $k = get_1base_pos($_);
	$str{$k}++;
}close IN;
system("rm -rf str_tmp/");
open IN, $bed;
while(<IN>){
	chomp;
	my @r = split /\t/, $_;
	my $s = $r[1]+1;
	my $k = join "\t", @r[ 0 .. 2];
	print "$_\n" if(exists $str{"$r[0]\t$s"} || exists $str{"$r[0]\t$r[2]"});
}close IN;
###################
sub get_1base_pos {
	my $l = shift @_;
	my @r = split /\t/, $l;
	my $pos = $r[1]+1;
	return "$r[0]\t$pos";
}
