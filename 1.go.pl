#!/usr/bin/env perl

use warnings;
use strict;

my $input = $ARGV[0] or die "no file\n";

open (IN,"< $input") || die "no open $input\n";

my ($id, $go, @na);
while(<IN>){
    chomp;
    if (/(TR.+)\t(.+)/){
        ($id, $go) = ($1, $2);
        @na = split (/,/, $go);
        my $sca = scalar(@na);
       # print "$sca\n";
       # print "@na\n";
        foreach my $hit (@na){
            print "$id\t$hit\n";
        }
    }
}
