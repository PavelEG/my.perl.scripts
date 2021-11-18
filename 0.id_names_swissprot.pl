#!/usr/bin/env perl

use warnings;
use strict;

# my vars
my $input = $ARGV[0];
my $index = $ARGV[1];
my $blastx = $ARGV[2];
my $id_output = "ids_processed.txt";
my $output_2 = "table_add_id_swiss.txt";
my $final_table = "${input}.names_added.txt";

# my usage
sub usage {
    print "\nUsage: $0 matrix_file uniprot_index (id_name_index.txt) blastx_file\n";
}

# check arguments
my $arg = scalar @ARGV;
print "Incorrect number of arguments\n" and usage and exit unless ($arg == 3);

# open connecction
open (IN,"< $input") or die "can't open $input file!! $! \n";
open (OUT,"> $id_output") or die "can't create $id_output file!! $! \n";

# get title
my $title1 = <IN>;
chomp $title1;
my @title_f = split (/\t/, $title1);
local $" = "\t";
print OUT "ID\t@title_f\n";

# processing id file
my (@fields, $id);

while (<IN>) {
    chomp;
    @fields = split (/\t/);
    if($fields[0] =~ /(\w+_\w+|TR.+i\d+)(\^.+|)/) {
        $id = $1;
        print OUT "$id\t@fields[1..$#fields]\n";
    } 
}

# close connections
close IN;
close OUT;

# saving swissprot-index into a hash
open (IN3,"< $index") or die "can't open $index file!! $! \n";
my (%sp_index, $prot_id, $prot_name);

# loop
while (<IN3>) {
    chomp;
    if (/>(\w+_\w+)\s+(.+)/) {
        ($prot_id, $prot_name) = ($1,$2);
        $sp_index{$prot_id} = $prot_name;
        #print STDOUT "$sp_index{$prot_id}\n";
    }
}

close IN3;

# blastx into a hash
open (IN4, "< $blastx") or die "can't open $blastx file!! $! \n";
my (%id_name, @cam);

# loop
while (<IN4>) {
    chomp;
    @cam = split (/\t/);
    if ($cam[0] =~ /(c\d+_g\d+|TR.+i\d+)/) {
    $id_name{$1} = $cam[1];
    #print STDOUT "$id_name{$1}\n";
    }else{
        print STDOUT "$_\n";
    }
}

close IN4;

# search ids into blastx to get uniprot names
open (IN2, "< $id_output") or die "can't open $id_output file!! $! \n";
open (OUT1,"> $output_2") or die "can't create $output_2 file!! $! \n";

my @col_mod;

# get new title
my $title2 = <IN2>;
chomp $title2;
my @title2_f = split(/\t/, $title2);
local $" ="\t"; 
print OUT1 "$title2_f[0]\tid_uniprot\t@title2_f[1..$#title2_f]\n";

# loop
while (<IN2>) {
    chomp;
    next if /^ID/;
    @col_mod = split(/\t/);
    if ($id_name{$col_mod[0]}) {
        print OUT1 "$col_mod[0]\t$id_name{$col_mod[0]}\t$col_mod[1]\t@col_mod[2..$#col_mod]\n";
    }else{
        print OUT1 "$col_mod[0]\tNA\t$col_mod[1]\t@col_mod[2..$#col_mod]\n";

    }
}

close IN2;
close OUT1;

# final table
open (IN5,"< $output_2") or die "can't open $output_2 file!! $! \n";
open (OUT3, "> $final_table") or die "can't create $final_table file!! $! \n";

# get title
my $title3 = <IN5>;
chomp $title3;
my @title3_f = split(/\t/, $title3);
 local $" = "\t";
print OUT3 "@title3_f[0,1]\tUniprot_names@title3_f[2..$#title3_f]\n";

# loop
my @col_mod_aga;

while (<IN5>) {
    chomp;
    #print "$_\n";
    @col_mod_aga = split (/\t/);
    if ($sp_index{$col_mod_aga[1]}) {
        print OUT3 "$col_mod_aga[0]\t$col_mod_aga[1]\t$sp_index{$col_mod_aga[1]}\t@col_mod_aga[2..$#col_mod_aga]\n";
    }else{
        print OUT3 "$col_mod_aga[0]\t$col_mod_aga[1]\tNA\t@col_mod_aga[2..$#col_mod_aga]\n";
    }
}

close IN5;
close OUT3;

# remove tmp file
unlink $id_output, $output_2;
