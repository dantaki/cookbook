#!/usr/bin/perl
use strict; use warnings;
use Time::localtime qw(localtime);

#----------------------------------------------------------------------------------#
my $usage = "perl plink_tdt.pl <in.vcf> <in.fam> [output directory] [id-delimiter]"; 
my $vcf = $ARGV[0];
my $fam = $ARGV[1];

die "FATAL ERROR: VCF NOT DEFINED\n    $usage\n" if(! defined $vcf);
die "FATAL ERROR: FAM FILE NOT DEFINED\n    $usage\n" if(! defined $fam);

my $odir = $ARGV[2];
if(! defined $odir) { 
	my @f = split /\//, $vcf;
	pop @f;
	$odir = join "/", @f;
}

my $delim = $ARGV[3];

$odir=$odir."/" if($odir !~ /\/$/);
system("mkdir -p $odir");
#----------------------------------------------------------------------------------#

############ CHANGE THESE PATHS IF NEEDED ############
my $plink1_9="/home/dantakli/bin/plink";
my $plink1_07="/home/dantakli/bin/plink-1.07 --noweb";
######################################################

# ---------------------------------------------------------------------------------#
my @f = split /\//, $vcf; my $pre = pop @f;
$pre =~ s/\.gz//; $pre =~ s/\.vcf//; 

my $upid = $odir.$pre.".update.ids";
my $uppar = $odir.$pre.".update.parents";
my $upsex = $odir.$pre.".update.sex";
my $cas = $odir.$pre.".case.pheno";
my $con = $odir.$pre.".control.pheno";

open UP, ">$upid";
open PA, ">$uppar";
open SX, ">$upsex";
open CA, ">$cas";
open CN, ">$con";

open IN, $fam;
while(<IN>){
	my @r = split /\t/, $_;
	@r = split / /, $_ if(scalar @r == 1);
	my ($fid,$iid,$pat,$mat,$sex,$phen) = @r[0 .. 5];
	
	print UP "$iid $iid $fid $iid\n";
	print PA "$fid $iid $pat $mat\n"; 
	print SX "$fid $iid $sex\n"; 
	print CA "$fid $iid $phen\n"; 
	my $rev_phen = 0;
	$rev_phen = 1 if($phen==2);
	$rev_phen = 2 if($phen==1); 
	print CN "$fid $iid $rev_phen\n"; 
}close IN; 
close UP; close PA; close SX; close CA; close CN; 

undef my @plink_cmds;
# 1. VCF - plink bfile
my $vcfbfile = "$plink1_9 --vcf $vcf --make-bed --double-id --out $odir$pre";
my $upid_cmd = "$plink1_9 --bfile $odir$pre --update-ids $upid --make-bed --out $odir$pre\.up";
my $uppar_sex_cmd = "$plink1_9 --bfile $odir$pre\.up --update-parents $uppar --update-sex $upsex --make-bed --out $odir$pre\.plink";

if(defined $delim){ 
	$delim = "\\".$delim if($delim =~ /[\|\(\)\#\$]/); 
	$vcfbfile = "$plink1_9 --vcf $vcf --make-bed --id-delim $delim --out $odir$pre\n";  
	$uppar_sex_cmd =~ s/--bfile $odir$pre\.up/--bfile $odir$pre/; 
	push @plink_cmds, ($vcfbfile,$uppar_sex_cmd); 	
} else { push @plink_cmds, ($vcfbfile,$upid_cmd,$uppar_sex_cmd) } 
 
# 2. TDT Commnads
my $cas_tdt = $odir.$pre.".cas";
my $con_tdt = $odir.$pre.".con";
my $cas_tdt_cmd = "$plink1_07 --bfile $odir$pre\.plink --tdt --poo --pheno $cas --out $cas_tdt";
my $con_tdt_cmd = "$plink1_07 --bfile $odir$pre\.plink --tdt --poo --pheno $con --out $con_tdt"; 

push @plink_cmds, ($cas_tdt_cmd,$con_tdt_cmd); 

foreach my $cmd (@plink_cmds){ system($cmd); } 
# 3. tabulate results
undef my %tdt;
open IN, "$cas_tdt\.tdt.poo";
<IN>;
while(<IN>){
	chomp;
	my $r = tokenize_plink($_);
	my $id = $$r[1];
	my ($pt,$pn) = split /:/, $$r[3];
	my ($mt,$mn) = split /:/, $$r[6];
	$tdt{$id}{2}{"pt"}+= $pt;
	$tdt{$id}{2}{"pn"}+= $pn;
	$tdt{$id}{2}{"mt"}+= $mt;
	$tdt{$id}{2}{"mn"}+= $mn;
}close IN;

open IN, "$con_tdt\.tdt.poo"; 
<IN>;
while(<IN>){
	chomp;
	my $r = tokenize_plink($_); 
	my $id = $$r[1];
	my ($pt,$pn) = split /:/, $$r[3];
        my ($mt,$mn) = split /:/, $$r[6];
        $tdt{$id}{1}{"pt"}+= $pt;
        $tdt{$id}{1}{"pn"}+= $pn;
        $tdt{$id}{1}{"mt"}+= $mt;
        $tdt{$id}{1}{"mn"}+= $mn;
}close IN;
my $out = timestamp();
$out = $odir.$pre.".tdt.table.".$out.".txt";

open OUT, ">$out";
print OUT "id\taff_pt\taff_pn\taff_mt\taff_mn\tcon_pt\tcon_pn\tcon_mt\tcon_mn\n";
foreach my $id (sort keys %tdt){
                  #pt pn mt mn pt pn mt mn
	my @tdt = (0, 0, 0, 0, 0, 0, 0, 0);
	$tdt[0] = $tdt{$id}{2}{"pt"} if(exists $tdt{$id}{2}{"pt"});
	$tdt[1] = $tdt{$id}{2}{"pn"} if(exists $tdt{$id}{2}{"pn"});
	$tdt[2] = $tdt{$id}{2}{"mt"} if(exists $tdt{$id}{2}{"mt"});
	$tdt[3] = $tdt{$id}{2}{"mn"} if(exists $tdt{$id}{2}{"mn"});

	$tdt[4] = $tdt{$id}{1}{"pt"} if(exists $tdt{$id}{1}{"pt"});
	$tdt[5] = $tdt{$id}{1}{"pn"} if(exists $tdt{$id}{1}{"pn"});
	$tdt[6] = $tdt{$id}{1}{"mt"} if(exists $tdt{$id}{1}{"mt"});
	$tdt[7] = $tdt{$id}{1}{"mn"} if(exists $tdt{$id}{1}{"mn"});

	my $o = join "\t", @tdt;
	print OUT "$id\t$o\n";
} close OUT; 

warn "-" x 80, "\n  output ---> $out\n", "-" x 80, "\n"; 

#########
sub tokenize_plink {
	my $l = shift @_;
	my @r = split / /, $_;
	undef my @t;
	foreach(@r) { if ($_ ne "" && $_ ne " "){ push @t, $_;} }
	return \@t;
}

sub timestamp {
  my $t = localtime;
  return sprintf( "%02d%02d%04d",
                  $t->mday, $t->mon+1, $t->year + 1900);
}

