#!/usr/bin/perl
use strict; use warnings;
my $r1 = $ARGV[0];
my $r2 = $ARGV[1];
my $ref = $ARGV[2];
my $sm = $ARGV[3];
my $lb = $ARGV[4];
my $odir = $ARGV[5];
my $threads = $ARGV[6];
$threads=4 if(! defined $threads);
my $usage = "\n    perl bwa_mem_pe.pl [R1.fq] [R2.fq] [REF.fa] [SM] [LB] [OUTPUT DIR] <THREADS>\n";


die "\nFATAL ERROR: R1.fq NOT DEFINED\n$usage\n" if(! defined $r1);
die "\nFATAL ERROR: R2.fq NOT DEFINED\n$usage\n" if(! defined $r2);
die "\nFATAL ERROR: REF.fa NOT DEFINED\n$usage\n" if(! defined $ref);
die "\nFATAL ERROR: SAMPLE NOT DEFINED\n$usage\n" if(! defined $sm);
die "\nFATAL ERROR: LIBRARY  NOT DEFINED\n$usage\n" if(! defined $lb);
die "\nFATAL ERROR: OUTPUT DIRECTORY NOT DEFINED\n$usage\n" if(! defined $odir);

my $tmp = "/state/partition1/\$USER/\$PBS_JOBID/";
my @r = split /\//, $r1;
my $id = pop @r; 
$id =~ s/\.gz$//; $id =~ s/\.fq$//; $id =~ s/\.fastq$//; 
$id =~ s/R[1-2]$//;  $id =~ s/\.$//;
$id =~ s/_$//; 

my $bwa = "/home/dantakli/bin/bwa-0.7.17/bwa mem";
my $opt = "-K 100000000 -Y -t $threads -R \'\@RG\\tID:$id\\tSM:$sm\\tLB:$lb\\tPL:ILLUMINA\'";

my $cmd = "$bwa $opt $ref $r1 $r2 | samtools view -bh -\@ $threads >$tmp$id\.bam";
my $mv = "mv $tmp$id\.bam $odir";

system($cmd);
#print "$cmd\n";
system($mv); 



