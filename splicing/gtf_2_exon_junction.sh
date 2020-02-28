#!/bin/sh
GTF=$1
BED=${GTF/.gtf/.exons.bed}
MERGED=${BED/.exons/.merged_exons}
EXON_INTRON=${BED/.exons/.exons.introns}
JUNC=${EXON_INTRON/.introns/.introns.junctions}
PAD_BED=${JUNC/.junctions.bed/.junctions.pad}
PAD=25

less $GTF | awk '($3=="exon")' | gtf2bed - | cut -f1-6 >$BED

# convert transcripts to merged exons
awk -f /home/dantakli/recipe/splicing/transcripts2mergedExons.awk $BED >$MERGED

# make an exon intron list
awk -f /home/dantakli/recipe/splicing/mergedExons2exonIntronList.awk $MERGED >$EXON_INTRON

# convert these to junctions
awk -f /home/dantakli/recipe/splicing/exonIntronList2JunctionList.awk $EXON_INTRON >$JUNC

# pad them by 25nt around the junction
bedops --everything --range $PAD $JUNC >$PAD_BED$PAD\.bed

echo "exon junction bed output"
echo "    -> $PAD_BED$PAD.bed"
   
