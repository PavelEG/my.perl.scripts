#!/usr/bin/perl

use warnings;
use strict;

# usage print
sub usage {
    print "\nUsage: $0 ids_deg GO_enriched_file file_wt_all_id_GO_relations\n"; 
}

# Check correct number of arguments
my $len_arg = scalar @ARGV;
print "Incorrect number of arguments\n" and usage and exit unless ($len_arg == 2);

# My vars
my $GO_file = "$ARGV[1]" or die;
my $ID_uniq_file = "$ARGV[0]" or die;
#my $all_GO_file = "$ARGV[2]" or die;

# my output files
my $all_id_match = "id_match_GO.txt";
my $all_ID_GO_relation = "go_transcript_format.txt";

# open files
open (IN, "< $ID_uniq_file") or die "can't open the $ID_uniq_file $!\n";
open (OUT, "> $all_id_match") or die "can't create the $all_id_match file $!\n";

# loop throughout the id file
my ($hit, @field_ids_dge);

while (<IN>){
    chomp;
    @field_ids_dge = split("\t",$_); 
    $hit = `grep -i "$field_ids_dge[0]" $all_ID_GO_relation`;
    $"= "\t";
    print OUT $hit;
}

close IN;
close OUT;

# getting the final file
## tmp file created
my (@field_GO_file,@id_captured_GO);
my $final_output = "${ID_uniq_file}.bubble_format"; 
my $final_output_2 = "${ID_uniq_file}.bubble_format_final";
#open connections
open (IN2, "< $GO_file") or die "can't open $GO_file file $!\n";
open (OUT2,"> $final_output") or die " can't open $final_output file $!\n";

#print titles
print OUT2 "category\tID\tterm\tgenes\tadj_pval\n";
my $var;
while (<IN2>){
    chomp;
    next if /category/;
    @field_GO_file = split("\t", $_);
    `rm match_go_file.txt`;
    `grep -i "$field_GO_file[1]" $all_id_match > match_go_file.txt`;
    my $capture_ID_GO_match = "match_go_file.txt";
    open(IN3, "< $capture_ID_GO_match") or die "what's going on here --> $!\n";
   
    while(<IN3>){
        chomp;
       $var = $_;
       unless(/!^TR.+/){
        @id_captured_GO = split ("\t",$var);
       push(@field_GO_file,$id_captured_GO[0]);
       }
        
    }
  print OUT2 "$field_GO_file[7]\t$field_GO_file[1]\t$field_GO_file[6]\t@field_GO_file[8..$#field_GO_file]\t$field_GO_file[2]\n"
}

close IN2;
close OUT2;

# last format, erasing lines without genes
my (@final_field);

open (IN4, "< $final_output") or die;
open (OUT3, "> $final_output_2") or die;
while (<IN4>){
    chomp;
    @final_field = split("\t",$_);
    if($final_field[3] and $final_field[2] ne "NA"){
        $"="\t";
        print OUT3 "@final_field[0,1,2]\t";
        $"=",";
        print OUT3 "@final_field[3..$#final_field-1]\t";
        $" = "\t";
        print OUT3 "$final_field[$#final_field]\n";

    }
}

close IN4;
close OUT3;


# last format, order ID of the GO term

# my final files to be cat
my $BP = "tmp_BP.txt";
my $CC = "tmp_CC.txt";
my $MF = "tmp_PB.txt";

# open connection
open (OUT4, "> $BP")  or die;
open (OUT5, "> $CC") or die;
open (OUT6,"> $MF") or die;
open (IN5, "< $final_output_2") or die;


# separate files
my @field_final;
$" = "\t";

#loop
while(<IN5>){
    chomp;
    next if /^category/;
    @field_final = split ("\t", $_);
    if ($field_final[0] eq "BP"){
        print OUT4 "@field_final\n";
    }elsif($field_final[0] eq "CC"){
        print OUT5 "@field_final\n";
    }elsif($field_final[0] eq "MF"){
        print OUT6 "@field_final\n";
    }     
}

close IN5;
close OUT4;
close OUT5;
close OUT6;

# final files
my $final_output_3 = "${ID_uniq_file}.bubble_format_final_order";
open (OUTF, ">$final_output_3") or die;

print OUTF "category\tID\tterm\tgenes\tadj_pval\n";

close OUTF;

# print system
`cat $BP $CC $MF >> $final_output_3`;

# remove garbage files
unlink "$BP", "$CC", "$MF";

# print 
print "All ran well\n";
