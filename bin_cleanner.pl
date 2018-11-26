#!/usr/bin/perl 

use warnings; 
use strict; 


my ($file1) = $ARGV[0]; #fasta file
my ($file2) = $ARGV[1]; #file parse with the list 

open my $fh1, '<', $file1 or die "Could not open file $!";
open my $fh2, '<', $file2 or die "Could not open file $!";
my @names;

my $caca=0;
my $count=0;
#print "@names\n";
while (my $row = <$fh2>) {
chomp $row;
push @names,$row; 
}
#print "@names\n"

while (my $row = <$fh1>) {
  chomp $row;
 

if ($row =~ /^>/) { $caca=0; $count=0;}

    
foreach my $element (@names) {

if($row =~ m/$element/)  {$count= $count+1;}

}


if ($count >= 1)  {$caca =0}
else {$caca =1}



if ($caca==1) {print "$row\n";}



#push @names,$row ;
}


close $fh1;
close $fh2;
