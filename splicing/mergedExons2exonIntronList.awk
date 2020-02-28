BEGIN {
    FS="\t";
    old_chr = "chrN";
    old_start = -1;
    old_stop = -1;
    old_id = "*";
    old_score = "*";
    old_strand = "*";
}
{
    new_chr = $1;
    new_start = $2;
    new_stop = $3;
    new_id = $4;
    new_score = $5;
    new_strand = $6;

    if (old_id != new_id) {
        new_score = 1; # exon                                                                                                                                                                                                                                                     
        print new_chr"\t"new_start"\t"new_stop"\t"new_id"\t"new_score"\t"new_strand;
        old_id = new_id;
    }
    else {
        # we construct and print an intron, then print the exon                                                                                                                                                                                                                   
        old_score = 0;
        print old_chr"\t"old_stop"\t"new_start"\t"old_id"\t"old_score"\t"old_strand;
        new_score = 1; # exon                                                                                                                                                                                                                                                     
        print new_chr"\t"new_start"\t"new_stop"\t"new_id"\t"new_score"\t"new_strand;
    }

    old_chr = new_chr;
    old_start = new_start;
    old_stop = new_stop;
    old_id = new_id;
    old_score = new_score;
    old_strand = new_strand;
}
END {
}