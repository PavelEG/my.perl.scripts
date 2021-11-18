#!/usr/bin/env perl

use warnings;
use strict;

# my initial vars
my $genome = $ARGV[0] or die "file wasn't selected";
my $genome_small_contigs = "genome_small.fsa";
my $genome_big_contigs = "genome_big.fsa";
my $genome_merged = "merged_genomes.fsa";
my $length_filter = 10000; # maximum length of the contigs that are going to be merged into a single chrUnknown

# my connections
open (IN, "gunzip -c $genome |") or die "can't open $genome file!! $! \n";
open (OUT, "> $genome_small_contigs") or die "can't create $genome_small_contigs file!! $! \n";
open (BIG, "> $genome_big_contigs") or die "can't cretae $genome_big_contigs file!! $! \n";

# processing file
# my tem vars
my ($header, %seq);

while (<IN>){
    chomp;
    if (/>(.+)/){
        $header = $1;
    } else { 
        $seq{$header} .= $_;  
    }
} 

close IN;

# adding the length in the header
while (my ($x, $y) = each %seq){
    my $len = length $y;
    if ($len <= $length_filter){
    print OUT ">$x\tlen=$len\n$y\n";
    } else {
        print BIG ">$x\tlen=$len\n$y\n";
    }
}

close OUT;
close BIG;

# merged small contigs into a big one
open (IN2,"< $genome_small_contigs") or die "can't open $genome_small_contigs file!! $!\n";
open (ALL, "> $genome_merged") or die "can't cretae $genome_merged file!! $! \n";

# my local vars
my $seq;

while (<IN2>) {
    chomp;
    next if /^>/;
    $seq .= $_;
}

# printing all contigs
my $len = length $seq;
print ALL ">chrUnknown len=$len\n$seq\n";

close IN2;
close ALL;

# cat all contigs, make format and gzip
`cat $genome_merged $genome_big_contigs > merged_genome_all.fsa`;
`./fasta_formatter -w 80 -i merged_genome_all.fsa -o merged_genome_all_formatted.fsa`;
`gzip merged_genome_all_formatted.fsa`;

# removing tmp files
my @tpm_files = ($genome_small_contigs, $genome_big_contigs, $genome_merged, "merged_genome_all.fsa");
unlink (@tpm_files) or die "$! @tpm_files";

