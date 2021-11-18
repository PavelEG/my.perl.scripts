#!/usr/bin/env perl

use warnings;
use strict;

# my flags
my $edger_table = $ARGV[0] or die;
my $ids_up_down = $ARGV[1] or die;  #any of both files
my $result = "${edger_table}_up_upgenes.txt" or die;

# open connections
open (IN,"< $ids_up_down") || die "can't open $ids_up_down file!! $! \n";

# my required vars for loop
my (%id,$id);

while(<IN>) {
    chomp;
        if(/(TR.+g\d+)/){
        $id = $1;
        print "$id\n";
	$id{$id} = 1;
	}
}


close IN;

# open table and processes it
open (TB,"< $edger_table") || die "can't open $edger_table file!! $! \n";
open (OUT,"> $result") || die "can't open $result file!! $! \n";

print OUT "ID\tlogFC\tPValue\tFDR\tUniprot ID\tProtein name\n";

# my required vars
local $" = "\t";
my @fields;

while(<TB>) {
    chomp;
    next if /^ID/;
    @fields = split /\t/;
    if($id{$fields[0]}) {
        print OUT "@fields[0,1,4,5]\n";
    }
}

close TB;
close OUT;
