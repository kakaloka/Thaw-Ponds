#!/usr/bin/perl 

use warnings; 
use strict; 


my ($file1) = $ARGV[0];
my ($file2) = $ARGV[1];

open my $fh1, '<', $file1 or die "Could not open file $!"; #file with the duplicated gene market
open my $fh2, '<', $file2 or die "Could not open file $!"; #file parse with the list to remove
my @names;

#my $caca=0;
#my $count=0;
#print "@names\n";
while (my $row = <$fh2>) {
chomp $row;
push @names,$row; 
}
#print "@names\n"

while (my $row = <$fh1>) {
  chomp $row;
 
   
foreach my $element (@names) {

if($row =~ m/$element/)  {print "$row\n";}

}



#push @names,$row ;
}


close $fh1;
close $fh2;
