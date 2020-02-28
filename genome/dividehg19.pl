#!/usr/bin/perl
use strict; use warnings;
my $step = 10000000;
$step = $ARGV[0] if(defined $ARGV[0]);

open IN, "/home/dantakli/resources/hg19.genome";
while(<IN>){
        chomp;
        my ($chrom, $len) = split /\t/, $_;
        for  (my $i=1; $i<=$len; $i+=$step){
                my $end = $i+$step-1;
                $end = $len if($i+$step-1 > $len);
                print "$chrom:$i-$end\n";
                last if($i+$step-1 > $len);

        }
}close IN;

