#!/usr/bin/perl

#script to compare two deg files to find differences between them.

use warnings;
use strict;

#  my vars
my $input = "$ARGV[0]" or die; # file at 24
my $input_2 = "$ARGV[1]" or die; # file at 30 degrees
my $output = "${input}_uniq_at_24.txt";
my $output_2 ="${input_2}_uniq_at_30.txt";
my $output_3 = "genes_shared.txt";

# open connections
open (IN,"<$input") or die "can't open $input file $!\n";

#my loop var
my (%com, @term);

while(<IN>){ # file at 24 degrees is saved into a hash
	chomp;
	next if /^ID/;
	@term = split("\t",$_);
	$com{$term[4]} = $term[5];
}

close IN;

# now, we're going to compare file at 24 agaisnt 30 for the same tissue

open (IN2, "<$input_2") or die "can't open $input_2 file$!\n";
open (OUT1,">$output_2") or die "can't cretae $output_2 file $!\n";
open (OUT2,">$output_3") or die "can't create $output_3 file $!\n";

# set var for split
my (@uni_name);

while (<IN2>){
	chomp;
	next if /^ID/;
	@uni_name = split ("\t", $_);
	if ($com{$uni_name[4]}){
	print OUT2 "$uni_name[0]\t$uni_name[4]\t$uni_name[5]\n";
	}else{
		print OUT1 "$uni_name[0]\t$uni_name[4]\t$uni_name[5]\n";
	}
}


close IN2;
close OUT2;
close OUT1;

# now we need to find specific genes at 24 degrees.

# open connections
open (INC,"<$input_2") or die "can't open $input_2 file $!\n";

#my loop var
my (%com_2, @term_2);

while(<INC>){ # file at 30 degrees is saved into a hash
	chomp;
	next if /^ID/;
	@term_2 = split("\t",$_);
	$com_2{$term_2[4]} = $term_2[5];
}

close INC;

# now search for those genes into de 24 files
open (IN,"<$input") or die "can't open $input file $!\n";
open (OUT, ">$output") or die "can't create $output file $!\n";

# my var
my @uniprot;

while(<IN>){
	chomp;
	next if /^ID/;
	@uniprot = split("\t",$_);
	unless($com_2{$uniprot[4]}){
		print OUT "$uniprot[0]\t$uniprot[4]\t$uniprot[5]\n";
	}
}

close IN;
close OUT;