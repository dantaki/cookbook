BEGIN {
    FS="\t";
    old_chr = "chrN";
    old_start = -1;
    old_stop = -1;
    old_id = "*";
    old_score = "*";
    old_strand = "*";
    new_element_flag = 0;
}
{
    new_chr = $1;
    new_start = $2;
    new_stop = $3;
    new_id = $4;
    new_score = $5;
    new_strand = $6;

    if (old_id != new_id) {
        if (old_id != "*") {
            old_score = 1; # exon                                                                                                                                                                                                                                                 
            print old_chr"\t"old_start"\t"old_stop"\t"old_id"\t"old_score"\t"old_strand;
        }
        new_score = 1; # exon                                                                                                                                                                                                                                                     
        print new_chr"\t"new_start"\t"new_stop"\t"new_id"\t"new_score"\t"new_strand;
        old_id = new_id;
        new_element_flag = 1;
    }
    else {
        # find genomic difference between new and old elements                                                                                                                                                                                                                    
        diff_start = new_start - old_stop;
        if (diff_start > 0) {
            # we have an intron between new and old elements                                                                                                                                                                                                                      
            if (new_element_flag == 0) {
                # print the current old element                                                                                                                                                                                                                                   
                old_score = 1; # we know it is an exon                                                                                                                                                                                                                            
                print old_chr"\t"old_start"\t"old_stop"\t"old_id"\t"old_score"\t"old_strand;
            }
            else {
                # we are no longer at the start of a new element                                                                                                                                                                                                                  
                new_element_flag = 0;
            }
        }
        else {
            # alternate splice? some other transcript of the same exon?                                                                                                                                                                                                           
            # preserve the old start coordinate                                                                                                                                                                                                                                   
            if (old_start != -1) {
                new_start = old_start;
            }
            if (new_stop < old_stop) {
                new_stop = old_stop;
            }
        }
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