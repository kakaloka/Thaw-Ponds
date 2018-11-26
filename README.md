# Thaw-Ponds

## Bin refining pipeline

## Requiere 

R and perl 

## First in R

Extracted from [Genome Bin Decontamination, Connor Skennerton - Oct 3rd, 2015 - posted in bioinformatics](http://ctskennerton.github.io/blog/2015/10/03/Bin-Decontamination/)
In our analysis we adapted the R pipeline previous described by Connor Skennerton, here I have copied the original description and code and you can find our modifications in the file [history_bin_decontamination.Rhistory](history_bin_decontamination.Rhistory)


## Background

In the below analysis I’m going to try to improve bin_41.

## Analysis
Creating the input files
For starters I want the .depth.txt file created by metabat, which I copied and renamed 3730_coverage.tsv. Next I created a mapping file for which contigs belonged to which bins. I have the fasta files of all of the bins in a separate directory. To get the mapping of the fasta files I ran the following:


grep -oP '(?<=^\>)\S+' *fa | awk 'BEGIN{FS=":";OFS="\t"}{print $2,$1}' > 3730_bin_mapping.tsv
And finally I wanted to know where all of the multi-copy markers were so I created a file based on the CheckM output, with a bit of reformatting in awk:


checkm qa -o 6 ckm_results/lineage.ms ckm_results | awk 'BEGIN{FS="\t";OFS=","}{n = split($3,a,",");for(i = 1; i <= n; ++i){print $1,$2,a[i]}}' > 3730_multiple_markers.csv


Exploratory analysis in R
library(readr)
duplicated_markers = read_csv("3730_multiple_markers.csv")
coverage = read_tsv("3730_coverage.tsv")
#no header in the file, so give the columns names
bin_mapping = read_tsv("3730_bin_mapping.tsv", col_names = c("contigName", "bin"))
Clean up the dataframes to make the column names consistent and remove a bit of unneeded text. Note that these commands are specific to how files were named on my system, you may not need to do this or change this section to meet your own needs.

bin_mapping$bin = gsub("metabat_binned/final.contigs.fa.metabat_", "", bin_mapping$bin)
bin_mapping$bin = gsub("\\.fa$", "", bin_mapping$bin)
duplicated_markers$`Bin Id` = gsub("final.contigs.fa.metabat_", "", duplicated_markers$`Bin Id`)
duplicated_markers$`Gene Ids` = gsub("_\\d+$", "", duplicated_markers$`Gene Ids`, perl=TRUE)
colnames(duplicated_markers) <- c("bin", "marker", "contigName")
Create a smaller dataframe of just the binned contigs

binned_contigs = merge(bin_mapping, coverage, by="contigName")
We are interested in Bin 41, lets get just the data for it.

bin_41 = binned_contigs[binned_contigs$bin == "bins_41",]
Since we have three samples we can look at the coverage of the contigs in each sample as a matrix of 2D

pairs(~final.contigs.3730.bam+final.contigs.5133.bam+final.contigs.5579.bam, data=bin_41, main = "Comparison of contig coverage between samples", labels = c("3730", "5133", "5579"))
plot of chunk bin-decontamination-paired-coverage The majority of the contigs are found in sample 3730 between 10-15x and with very low coverage in sample 5133. Some of the contigs also have some coverage in sample 5579, but most don’t. It’s tempting to remove all of the contigs that don’t fit into the band of coverage, but from this we can’t be certain if the duplicated markers are in these outlier contigs.

Since the coverage of sample 5133 doesn’t really factor into things lets look at a single 2D plot of the 3730 coverage and the 5579 coverage. As a coarse approach lets take a look at where all of the contigs with duplicated markers are in this plot. For starters make a new column in the bin_41 dataframe that tells us if the contig contains any duplicated marker.

bin_41_duplicated_markers = subset(duplicated_markers, bin == "bins_41")
bin_41$containsDuplicateMarker <- bin_41$contigName %in% unique(bin_41_duplicated_markers$contigName)
And now lets plot the data, changing the color of the points based on the value of the ‘containsDuplicateMarker’ column

plot(bin_41$final.contigs.3730.bam, bin_41$final.contigs.5579.bam, pch = 19, col = "lightgrey", cex=0.5, xlab="3730 coverage", ylab="5579 coverage", main="Contigs containing duplicated markers")
points(bin_41[bin_41$containsDuplicateMarker,]$final.contigs.3730.bam, bin_41[bin_41$containsDuplicateMarker,]$final.contigs.5579.bam, col = "red")
plot of chunk bin-decontamination-all-duplicate-markers Apart from a couple of outliers, the majority of the contigs that contain multiple markers are in the central mass of contigs. There doesn’t appear to be any way to systematically remove a substantial amount of contamination in this genome bin.

Instead of looking at all contigs that contain any duplicated markers, we can also visualise the positions of contigs for a specific duplicated marker. You can get a list of the markers that are duplicated in the bin by using the unique command. Then create a logical vector of bin_41 of the contigs that contain any of the particular markers.

unique(bin_41_duplicated_markers$marker)

contains_x_marker = bin_41$contigName %in% subset(bin_41_duplicated_markers, marker == "PF01157.13")$contigName
With this vector we can plot the points like we did with the complete set of duplicated markers.

plot(bin_41$final.contigs.3730.bam, bin_41$final.contigs.5579.bam, pch = 19, col = "lightgrey", cex=0.5, main="Position of contigs with PF01157.13", xlab="3730 coverage", ylab="5579 coverage")
points(bin_41[contains_x_marker,]$final.contigs.3730.bam, bin_41[contains_x_marker,]$final.contigs.5579.bam, col = "red")
plot of chunk bin-decontamination-single-marker-positions

So now we can see that ther are three contigs containing this marker, one appears to be an outlier, but the other two contigs have quite similar coverage profiles

##  Custom Perl scripts

After R analysis we exported a table with the contigs to be eliminated:

write.table(newdata_bin4, "bin4_decontaminar.txt", sep="\t")

In the terminal:

print the column with the contig id,
Example:

```shell

awk '{print $2}' bin4_decontaminar.txt | sed s/\"//g | grep -v "bin" > bin4_first_column_parse_2

perl bin_cleanner.pl bin_378.fa bin378_first_column_parse_2

 ```

In order to know if the completeness is affected, is good to analyse if we let at least one contig per gene marker

export from R the file with the gene marker of the bin in question:


write.table(bin_4_duplicated_markers, "bin4_all_duplicate_markers.txt", sep="\t")

Example:

```shell


perl print_gene_marker_removed.pl bin4_all_duplicate_markers.txt bins/bin4_first_column_parse_2 


 ```







