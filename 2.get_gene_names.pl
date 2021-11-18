#!/usr/bin/env perl

use warnings;
use strict;

# my vars
my $up_genes = $ARGV[0] or die "not ids_file entered!! $!"; # table file
my $uniprot_names = "uniprot_sprot_formated.fasta";
my $id_uniprot_names = "ids_blastx_names.txt";
my $ids_blastx = "blastx_id_swprot.txt"; # index of id and uniprot names-pre processed
my $final_out = "${up_genes}_add_annotation.txt";

# searching ids up genes into blastx file
# saving ids and uniprot hit into a hash
my ($ids, $uni_ids);
my %hit_blastx = ();

open (IN, "< $ids_blastx") || die "can't open $ids_blastx file!! $! \n";
while (<IN>) {
    chomp;
	if (/^(TR.+g\d+)_i\d+\s+(.+)/){
    ($ids, $uni_ids) =($1, $2);
    $hit_blastx{$ids} = $uni_ids;
    } else {
        print "What is wrong with this line -> $_\n";
    }
}
close IN;

# open connections
open (HIT, "< $up_genes") || die "can't open $up_genes file!! $!\n";
open (OUT, "> $id_uniprot_names") || die "can't create $id_uniprot_names file!! $! \n";

# my required vars
my @data;
local $" = "\t";
my $title = <HIT>;
print OUT "$title";

# loop with up genes table file
while (<HIT>) {
    chomp;   
    next if /^ID/; 
    @data = split(/\t/);
    if ($hit_blastx{$data[0]}) {
        print OUT "@data\t$hit_blastx{$data[0]}\n";
    }else{
        print "what is wrong -> $_\n";
    }
}

close HIT;
close OUT;

# creating a hash with uniprot codes and complete names from uniprot data base
open (UNP, "< $uniprot_names") || die "can't open $uniprot_names file!! $! \n";

# my required vars
my ($uni_code, $full_names_uniprot);
my %code_full = ();
while (<UNP>) {
    chomp;
    next if /^\w/;
    if (/^>(\w+_\w+)(.+)/) {
        ($uni_code, $full_names_uniprot) = ($1, $2);
        $code_full{$uni_code} = $full_names_uniprot;
       # print "$uni_code\t$code_full{$uni_code}\n";
    }
}

close UNP;

# getting final table
open (UNPE, "< $id_uniprot_names") || die "can't open $id_uniprot_names file!! $! \n";
open (FT," > $final_out") || die "can't create $final_out file!! $! \n";

# my vars
my @camp;
local $" = "\t";

my $title2 = <UNPE>;
print FT "$title2";

 while (<UNPE>) {
    chomp;
    #next if /^ID/;
    @camp = split (/\t/);
    if ($code_full{$camp[4]}) {
        #print "@camp\n";
        print FT "@camp\t$code_full{$camp[4]}\n";
    } else {
        #print "@camp\n";
        print "-> $_\n";
    }
}

close UNPE;
close FT;


