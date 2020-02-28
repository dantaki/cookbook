#!/usr/bin/perl
use strict; use warnings;
#########################
# This script requires
#   ---  bcftools  --- 
# in your environemnt 
#########################

my $constr = constraint();

### FUNCTIONAL CATEGORIES ###
my @lof = qw/
transcript_ablation
splice_acceptor_variant
splice_donor_variant
stop_gained
frameshift_variant
stop_lost
start_lost
/;

my @mis = qw/
inframe_insertion
inframe_deletion
missense_variant
protein_altering_variant
/;

my @syn = qw/
start_retained_variant
stop_retained_variant
synonymous_variant
/;

undef my %lof; foreach (@lof){$lof{$_}++;}
undef my %mis; foreach (@mis){$mis{$_}++;}
undef my %syn; foreach (@syn){$syn{$_}++;}
##########################################
# KEYWORDS FOR CSQ #
my @kw = qw/
Consequence
SYMBOL
Gene
ALLELE_NUM
CANONICAL
gnomAD_AF
/;
############################################
# 1. parse the CSQ header. { csq header } -> index
undef my %csq;
my $vcf = $ARGV[0];
die "VCF not defined.\nUsage:    perl vep_vcf2bed.pl <in.vcf.gz>\n" if(! defined $vcf);
open IN, "bcftools view -h $vcf |";
while(<IN>){
	chomp;
	next unless($_ =~ /\#\#INFO=<ID=CSQ/);
	my @csq = split /Description="/, $_;
	my @fom = split /Format: /, $csq[1];
	my $format = $fom[1];
	$format =~ s/\">$//;
	my @col = split /\|/, $format;
	for(my $i=0; $i<scalar(@col); $i++){ 
		$csq{$col[$i]}=$i;
	} 
}close IN;

print "#chrom\tstart\tend\tref;alt;consequence;symbol;gene;lof;mis;syn;gnomadaf;exacpli;exacpli_tier;gnomadpli;gnomadpli_tier;gnomadloeuf;gnomadloeuf_tier\n";

# 2. print out annotations in bed format
open IN, "bcftools query -f'%CHROM;%POS0;%END;%REF;%ALT;%INFO/CSQ\\n' $vcf |";
while(<IN>){
	chomp;
	my @r=split /\;/, $_;
	my @vep = split /\,/, $r[-1];
	# foreach annotation
	foreach my $vep (@vep){
		# split the annotation
		my @csq = split /\|/, $vep;
		# split consequence by &
		my @funcs = split /\&/, $csq[$csq{"Consequence"}];
		
		my $lof=0; my $mis=0; my $syn=0;
		# foreach consequence
		foreach my $f (@funcs){
			$lof=1 if(exists $lof{$f});
			$mis=1 if(exists $mis{$f});
			$syn=1 if(exists $syn{$f});
		}
		# SKIP ANNOTATION THAT ARE NOT EXONIC
		next if($lof+$mis+$syn==0);
		# SKIP IF NOT CANONICAL
		next if (! defined $csq[$csq{"CANONICAL"}]);
		next if($csq[$csq{"CANONICAL"}] ne "YES");
		# get the correct alt allele
		next if(! defined $csq[$csq{"ALLELE_NUM"}]);
		my @alt = split /,/, $r[4];
		my $alt = $alt[$csq[$csq{"ALLELE_NUM"}]-1];
		# get constraint information
		my $exac = "nan;4";
		my $gpli = "nan;4";
		my $louf = "nan;4";
		my $gene = $csq[$csq{"SYMBOL"}];
		$exac = $$constr{$gene}{"exac"} if(exists $$constr{$gene}{"exac"});
		$gpli = $$constr{$gene}{"gpli"} if(exists $$constr{$gene}{"gpli"});
		$louf = $$constr{$gene}{"louf"} if(exists $$constr{$gene}{"louf"});
		# format the output
		# chrom start0 end ref;alt;consequence;symbol;gene;lof;mis;syn;gnomad
		my $gnom=0;
		$gnom = $csq[$csq{"gnomAD_AF"}] if(defined $csq[$csq{"gnomAD_AF"}]);
		$gnom=0 if($gnom eq "");
		my $info = join ";", 
			$csq[$csq{"Consequence"}],
			$gene,$csq[$csq{"Gene"}],
			$lof,
			$mis,
			$syn,
			$gnom,
			$exac,
			$gpli,
			$louf;
		my $o = join "\t", @r[0 .. 3],$alt,$info;

		print "$o\n"; 
	}
}close IN;


##################
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
