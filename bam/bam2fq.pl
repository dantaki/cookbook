#!/usr/bin/perl
if(! defined $ARGV[0] || ! defined $ARGV[1]) {
	die "FATAL ERROR: requires bam and output directory\n\n    perl bam2fq.pl <bam> <output directory> [threads]\n"; 
}
my $bam = $ARGV[0];
my $odir = $ARGV[1];
my $threads=1;
$threads = $ARGV[2] if(defined $ARGV[2]);

my $tmp = "/state/partition1/\$USER/\$PBS_JOBID/";
my @bam = split /\//, $bam;
my $opre = pop @bam; $opre =~ s/\.bam//;

my $r1 = "$opre\.R1.fq";
my $r2 = "$opre\.R2.fq";
my $oth = "$opre\.OTHER.fq";
my $singleton = "$opre\.SINGLETON.fq"; 

my $cmd = "samtools bam2fq -@ $threads -1 $tmp$r1 -2 $tmp$r2 -0 $tmp$oth -s $tmp$singleton $bam";
my @mv = ("mv $tmp$r1 $odir","mv $tmp$r2 $odir", "mv $tmp$oth $odir", "mv $tmp$singleton $odir");

system($cmd);
foreach my $mv (@mv) { system($mv); } 


