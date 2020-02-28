#!/usr/bin/perl
use strict; use warnings;
# author:<Danny Antaki>
# contact:<dantaki@ucsd.edu>
# this script takes a directory with BAM files, path to GATK, FASTA reference, list of FIDs, Optional: threads, dbSNP VCF, region <chr:start-end>, list of chromosomes
# this script prints out GATK HaplotypeCallercommands. 
my $vqsr_snp = "-resource:hapmap,known=false,training=true,truth=true,prior=15.0 /oasis/scratch/comet/mgujral/temp_project/broad_bundles/2.8/b37/hapmap_3.3.b37.vcf -resource:omni,known=false,training=true,truth=true,prior=12.0 /oasis/scratch/comet/mgujral/temp_project/broad_bundles/2.8/b37/1000G_omni2.5.b37.vcf -resource:1000G,known=false,training=true,truth=false,prior=10.0 /oasis/scratch/comet/mgujral/temp_project/broad_bundles/2.8/b37/1000G_phase1.snps.high_confidence.b37.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /oasis/scratch/comet/mgujral/temp_project/broad_bundles/2.8/b37/dbsnp_138.b37.vcf -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP -an MQ -mode SNP";
my $vqsr_indel = "--maxGaussians 4 -resource:mills,known=false,training=true,truth=true,prior=12.0 /oasis/scratch/comet/mgujral/temp_project/broad_bundles/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /oasis/scratch/comet/mgujral/temp_project/broad_bundles/2.8/b37/dbsnp_138.b37.vcf -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP -an MQ -mode INDEL";
my $fasta = "/home/dantakli/ref/human_g1k_v37.fasta"; 
my $gatk = "/home/dantakli/bin/GenomeAnalysisTK.jar";
my $thread = $ARGV[0];
my $dbSNP = "/oasis/projects/nsf/ddp195/dantakli/reference/hg19/dbsnp/All_20170403.vcf"; 
undef my %bam; undef my %dad;
foreach my $f (glob("/oasis/projects/nsf/ddp195/dantakli/sperm/2_1_18_alns/completed/F*.bam")){
	my ($fid,$iid) = parse_fid($f);
	push @{$bam{$fid}}, $f;
	$dad{$iid}++;
}
foreach my $f (glob("/oasis/projects/nsf/ddp195/dantakli/sperm/bqsr/F*.bam")){
	my ($fid,$iid) = parse_fid($f);
	push @{$bam{$fid}},$f unless(exists $dad{$iid});
}
undef my %pass;
open IN, "/home/dantakli/sperm/hp_fid"; while(<IN>){ chomp; $pass{$_}++; } close IN;
undef my @chrom;
for (my $i=1; $i<=24; $i++) { 
	my $ii=$i;
	$ii =~ s/23/X/; $ii =~ s/24/Y/;
	push @chrom, $ii;
}
        #print "java -jar $gatk -T HaplotypeCaller -R $fasta -nct $thread -I $fBam $dbSNP $L -o $fam.raw.snps.indels.vcf\n";
open SH, ">batch/hp_f0270_cmd";
open VQ, ">batch/vqsr_cmd";
foreach my $fid (sort keys %pass){
	my @b = sort { lc($a) cmp lc($b) } @{$bam{$fid}};
	my $bam = join " -I ", @b;
	$bam = "-I ".$bam;
	undef my @vcf;
	foreach my $c (@chrom){
		my $ofh = "/home/dantakli/sperm/batch/hp/$fid\.$c\.sh";
		next if($fid ne "F0270");
		#next if(-e $ofh);
		open OUT, ">$ofh";
		my $o = "/oasis/projects/nsf/ddp195/dantakli/sperm/haplotypecaller/200x/$fid\.$c\.hpcaller.vcf";
		print OUT "#!/bin/sh\n";
		print OUT "java -Xmx16g -jar $gatk -T HaplotypeCaller -R $fasta -nct $thread $bam -D $dbSNP -L $c -o $o\n"; 
		print OUT "bgzip $o\n";
		print OUT "tabix $o\.gz\n";
		push @vcf, "$o\.gz";
		close OUT;
		print SH "bash $ofh\n";
	}
	my $ofh = "/home/dantakli/sperm/batch/vqsr/$fid\.sh";
	open OUT, ">$ofh";
	my $o = "/oasis/projects/nsf/ddp195/dantakli/sperm/haplotypecaller/200x/$fid\.hpcaller.vcf";
	my $vcfs = join " ",@vcf;
	print OUT "#!/bin/sh\n";
	print OUT "bcftools concat -Oz $vcfs -o $o\.gz\n";
	print OUT "bcftools view -Ov $o\.gz -i'TYPE=\"snp\"' >$o\.snp.vcf\n";
	print OUT "bcftools view -Ov $o\.gz -i'TYPE=\"indel\"' >$o\.indel.vcf\n";
	print OUT "java -Xmx16g -jar $gatk -l INFO -R $fasta -nct $thread -T VariantRecalibrator -input $o\.snp\.vcf $vqsr_snp -recalFile $o\.snp\.vqsr.recal -tranchesFile $o\.snp\.vqsr.tranches -rscriptFile $o\.snp\.vqsr\.plots.R\n";
	print OUT "java -Xmx8g -jar $gatk -l INFO -R $fasta -T ApplyRecalibration -input $o\.snp\.vcf -tranchesFile $o\.snp\.vqsr\.tranches -recalFile $o\.snp\.vqsr\.recal -o $o\.snp\.vqsr\.vcf --ts_filter_level 99.5 -mode SNP\n";
	print OUT "java -Xmx16g -jar $gatk -l INFO -R $fasta -nct $thread -T VariantRecalibrator -input $o\.indel\.vcf $vqsr_indel -recalFile $o\.indel\.vqsr.recal -tranchesFile $o\.indel\.vqsr.tranches -rscriptFile $o\.indel.vqsr.plots.R\n";
	print OUT "java -Xmx8g -jar $gatk -l INFO -R $fasta -T ApplyRecalibration -input $o\.indel.vcf -recalFile $o\.indel\.vqsr.recal -tranchesFile $o\.indel\.vqsr.tranches -o $o\.indel\.vqsr.vcf --ts_filter_level 99.0 -mode INDEL\n";
	print OUT "bgzip $o\.snp.vqsr.vcf\n";
	print OUT "bgzip $o\.indel.vqsr.vcf\n";
	print OUT "tabix $o\.snp.vqsr.vcf.gz\n";
	print OUT "tabix $o\.indel.vqsr.vcf.gz\n";
	close OUT;
	print VQ "bash $ofh\n";
}	
close SH; close VQ;
###############
sub parse_fid {
	my $a = shift @_;
	my @a = split /\//, $a;
	my @aa = split /_/, pop @a;
	return $aa[0],$aa[1];
}
