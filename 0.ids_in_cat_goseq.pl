#!/usr/bin/perl
use warnings;
use strict;

# script para capturar los ids dentro de las categorias enriquecidas de goSeq

#mi variables de entrada
my $GO_table_enrich = "$ARGV[0]"; # archivo de GO enriquecido up o down genes, son las ""
my $ids_GO_transcriptoma = "go_transcript_format.txt"; # archivo de ids splitted con los GO
my $tmp1 = "${GO_table_enrich}.ids_with_GO.txt"; # archivo temporal con todos los IDS de los GO encontrados enriquecidos
my $diff_table_edgeR = "$ARGV[1]"; # tabla resultante de edgeR con las anotaciones
my $output = "allgo_dge.txt";
my $output_2 = "${GO_table_enrich}_ids_added.txt";

#abrir archivos
open (IN,"< $GO_table_enrich") or die "I can't open $GO_table_enrich file $! \n";

#bucle para buscar los GO en el archivo de ids
my (%GO,@GO_campos, $GO, $idx);

while(<IN>){
   chomp;
   next if /category/;
   @GO_campos =  split ("\t", $_);
   $GO{$GO_campos[1]} = 1;
   #print "$GO_campos[1]\n"; # just to see if GO are captured
}

close IN;

# Buscando GO en el formato general de IDS-GO
open (GO, "<$ids_GO_transcriptoma") or die "can't open $ids_GO_transcriptoma file $!\n";
open (TMP, ">$tmp1") or die "can't create $tmp1 file $!\n";
my (@camp_format);
$GO = $GO_campos[1];
   
while(<GO>){
    chomp;
    @camp_format = split ("\t", $_);
    if ($GO{$camp_format[1]}){
        print TMP "$camp_format[0]\t$camp_format[1]\n";
    }
}

close GO;
close TMP;

#segunda parte, abrir archivo con todos los ids y GO encontrados para hacer el filtro con los encontrados expresados diferencialmente
open (IN2, "<$tmp1") or die;
open (IN3,"<$diff_table_edgeR") or die;
open (OUT,"> $output") or die;
my (@id_go, $go,@edgeR, %table_edgeR, $id, @rest, @all);

#haash of array para la tabla de edgeR

while(<IN3>){
        chomp;
         @all = split (" ", $_);
         ($id, @rest) = ($all[0],@all[1..$#all]);
        # print "$id\n";
        #print "@rest\n";
        #@edgeR = split(" ", @rest);
        $table_edgeR{$id} = [ @rest ];    
}

while(<IN2>){
    chomp;
    my @id_go = split(" ",$_);
   # print "$id_go[0]\n";
   if($table_edgeR{$id_go[0]}){
       #my $local $" = " ";
       print OUT "@id_go[0,1]\t@{$table_edgeR{$id_go[0]}}[3..$#{$table_edgeR{$id_go[0]}}]\n";
    }
}

close IN2;
close IN3;

# creando archivo final
open (IN, "<$GO_table_enrich") or die;
open (OUT_2, ">$output_2") or die;
my (@cam_go, $go_2, $go_term);

while(<IN>){
    chomp;
    next if /category/;
    @cam_go = split("\t",$_);
    my $cap = `grep -i "$cam_go[1]" $output`;
     print OUT_2 "@cam_go[1,6]\n$cap";
     
}

close IN;
close OUT_2;

`rm $tmp1`;
