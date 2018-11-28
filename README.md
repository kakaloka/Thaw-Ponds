# Thaw-Ponds

## Pipeline to get pfam annotations for bins using pfam annotation from HMMER 3.1b2 output file

## Require

Perl


### 1) get the significant sequencies for the general pfam files plus descriptions

grep -E 'contig|Description' thaw_ponds_contigs_all_paired_pfams3.txt | grep -E 'flag|Description' | grep -v ">>" | awk '{if ($1~ /^Description/ || $1 < 0.0000000001) print $0}' > significant_pfam2_10 

### 2) create a list of the contigs forming the bin and transform in the same ID name present in the significant pfam file

sed "s/>k101_/contig/" list_of_contigs > list_of_contigs_ready

### 3) Run the script to crate the bin file with pfam annotations


perl ../../get_pfam_anotation.pl ../../significant_pfam2_10 list_of_contigs_ready > bin_50_pfam2 ; perl ../../get_pfam_anotation.pl ../../significant_pfam1_10 list_of_contigs_ready > bin_50_pfam1







