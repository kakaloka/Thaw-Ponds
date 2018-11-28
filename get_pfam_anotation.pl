#!/usr/bin/perl 

use warnings; 
use strict; 


my ($file1) = $ARGV[0];
my ($file2) = $ARGV[1];

open my $fh1, '<', $file1 or die "Could not open file $!"; #file with the duplicated gene market
open my $fh2, '<', $file2 or die "Could not open file $!"; #file parse with the list to remove
my @names;

my $caca="";
#my $count=0;
#print "@names\n";
while (my $row = <$fh2>) {
chomp $row;
push @names,$row; 
}
#print "@names\n"

while (my $row = <$fh1>) {
  chomp $row;
 
if($row =~ m/Description/)  {$caca= $row;}


foreach my $element (@names) {

my $new_element= $element.'_';

if($row =~ m/$new_element/)  {print "$row $caca"; print "\n";}
#print $new_element;

}



#push @names,$row ;
}


close $fh1;
close $fh2;
