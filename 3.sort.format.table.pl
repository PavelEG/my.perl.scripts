#!/usr/bin/env perl

use warnings;
use strict;

# my vars
my $file = $ARGV[0] or die;
my $sorted_output = "${file}.sort";

# creating an array of a reference array
open (IN2,"< $file") or die;
open( OUT2, "> $sorted_output" ) or die;

my $title = <IN2>;
print OUT2 "$title";

my (@data, @fl);
while (<IN2>) {
    chomp;
    next if /ID/;
    @fl = split(/\t/);
    push (@data, [ @fl ]);
}

close IN2; 

# sorting rows acording to evalue column
my @sorted_by_score = reverse sort { $a->[1] <=> $b->[1] } @data;

#łoop
foreach my $var (@sorted_by_score) {
    local $" = "\t";
    print OUT2 "@$var\n";
    
}

close OUT2;
