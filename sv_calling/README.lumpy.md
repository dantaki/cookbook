# LUMPY SV calling
------------------

1. Extract discordant paired-ends
  * `lumpy_get_discordant.sh $BAM`

2. Extract split-reads 
  * `lumpy_get_split.sh $BAM`

3. Call SVs with LUMPY
  * `lumpy_call_sv.sh $BAM $EXCLUDE-BED`
  * `/home/dantakli/bin/speedseq/bin/lumpyexpress`

4. Genotype SVs with svtyper
  * `svtyper_gt.sh`
  * `/home/dantakli/bin/speedseq/bin/svtyper`

-------------------

## Snakemake

When calling SVs with LUMPY in families, it's best to include
all the family members. 

For the BAM argument you would pass the files like
`-B mom.bam,dad.bam,kid.bam` 

Paths need to be comma separated. 

-------------------

## Notes on Running LUMPY & svtyper

* _PYTHON 2 IS REQUIRED FOR THIS STEP_

* Name the output VCF by familiy ID.

* Use a temporary directory, recommended location is OASIS scratch 
  `-T <tmpdir>`

* Exclude files are needed 
  * hg19 /home/dantakli/resources/hg19_lumpy_exclude_merged.bed.gz
  * hg38 /home/dantakli/resources/hg38_gaps_centromeres.bed

* Running LUMPY ask for 4 CPUs at minimum. If the job fails add more CPUs

* svtyper is pretty fast so you don't need as much memory

* test files will be in `lumpy_test/` 

