#!/usr/bin/perl

use warnings;
use strict;

# My vars
my $input = "$ARGV[0]";#file with the uniq or shared ids
my $input2 = "$ARGV[1]";  #file with all id_GO relations
my $output = "${input}_into_cat.txt";
my $output2 = "${input}_all_info_add.txt";

# open connections
open(IN, "< $input") or die "can't open $input file $!\n";
open(OUT, "> $output") or die "can't create $output file $!\n";

# My loop variables
my (@cam, $hit,$GO, $length);

# Loop
while(<IN>){
    chomp;
    @cam = split("\t",$_);
    $hit = `grep -i "$cam[0]" $input2`;
    $" = "\t";
    print OUT "$hit";
}

close IN;
close OUT;

# add all info
open (IN2, "< $output") or die;
open (OUT2, "> $output2") or die;
my (@out,@match);

# loop
while(<IN2>){
    chomp;
    @out = split("\t",$_);
    #print "$out[1]\n";
    @match = `grep -i "$out[0]" $input`;
    chomp(@match);
    $" = "\t";
    print OUT2 "@match\t$out[1]\n"; 
}

close IN2;
close OUT2;

# removing files
`rm $output`;

# creating final files
# vars
my $input3 = "$ARGV[2]"; #GO enrichment file
my $output3 = "${output2}_GO_Enrichemnt_added.txt";
my (@GO, $match_GO);

open (IN3, "< $input3") or die;
open (OUT3, "> $output3") or die;

while(<IN3>){
    chomp;
    next if /category/;
    @GO = split("\t");
    chomp(@GO);
    $match_GO = `grep -i "$GO[1]" $output2`;
    #chomp(@match_GO);
    print OUT3 "@GO[1,6]\n$match_GO\n"; 
}

close IN3;
close OUT3;

# last part of the script, I'm going to add the ids with GO unrichment or without GO asignation. 

# my vars
my (%TR,@IDS);

my $file = "TMP2.txt"; 
`egrep -o "TR.+g[0-9]+" $output3 | sort |uniq > $file`; 

open (IN4, "< $file") or die;

while(<IN4>){
    chomp;
    $TR{$_} = 1; 
}

close IN4;
## searching IDs found with GO against all the ID uniq or shared
my $output4 = "IDS_restantes.txt";

# my vars
my @LID;

#open connections
open (IN5, "< $input") or die;
open (OUT4,"> $output4") or die;

print OUT4 "IDS with GO but not GO enrichment\n";

while(<IN5>){
   chomp; 
    @LID = split("\t");
   #print "@LID[0,1,2]\n";
    if($TR{$LID[0]}){
        #print "$LID[0]\n";
        print "ID found with GO enrichment\n";
    }else{
        $"="\t";
        print OUT4 "@LID[0,1,2]\n";
    }

}

close OUT4;
close IN5;

# joining files
`cat $output3 $output4 > ${input}.Final`;

# removing tmpfiles
`rm $output2 $output3 $output4 $file`;


