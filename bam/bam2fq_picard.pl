#!/usr/bin/perl
use strict; use warnings;

if(! defined $ARGV[0] || ! defined $ARGV[1]) {
	die "FATAL ERROR: requires bam and output directory\n\n    perl bam2fq.pl <bam> <output directory> [Java memory]\n"; 
}
my $bam = $ARGV[0];
my $odir = $ARGV[1];
my $memory="8g";
$memory = $ARGV[2] if(defined $ARGV[2]);

#my $tmp = "/state/partition1/\$USER/\$PBS_JOBID/";
my $tmp = $odir; 
my @bam = split /\//, $bam;
my $opre = pop @bam; $opre =~ s/\.bam//;

my $r1 = "$opre\.R1.fq";
my $r2 = "$opre\.R2.fq";
my $unp = "$opre\.UNPAIRED.fq";
my $picard="/home/dantakli/bin/picard-2.20.0/picard.jar";
my $cmd = "java -Xmx${memory} -jar $picard SamToFastq I=$bam F=$tmp$r1 F2=$tmp$r2 FU=$tmp$unp VALIDATION_STRINGENCY=SILENT";
my @mv = (
"gzip -9 $tmp$r1",
"gzip -9 $tmp$r2",
);
#"mv $tmp$r1\.gz $odir",
#"mv $tmp$r2\.gz $odir", 
#"mv $tmp$unp $odir");

system($cmd);
#foreach my $mv (@mv) { system($mv); } 

