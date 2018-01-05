#!/usr/bin/perl

use warnings;
use strict;

my $wrongGTF=$ARGV[0];
my $geneListFile=$ARGV[1];
my @geneList=();

open(GLF,$geneListFile);

while(<GLF>){
 chomp;
 my $gene=$_;
 if($gene ~~ @geneList){
  die "Something is wrong in line of file with list of genes:\n$_\n";
 }else{
  push(@geneList,$gene);
 }
}

close(GLF);

open(WGTF,$wrongGTF);

while(<WGTF>){
 chomp;
 my $transcriptID='';
 my $geneID='';
 my $geneName='';
 if(/^#/){
  print "$_\n";
  next;
 }
 my ($chrom,$database,$feature,$start,$end,$score,$strand,$rfram,$otherInfo)=split(/\t/,$_);
 my @otherInfoList=split(/;/,$otherInfo);
 if($feature eq 'exon'){
  for my $info (@otherInfoList){
   if($info =~ /Parent=Afu\S+\-T/){
    $geneID = $info;
    $transcriptID = $info;
    $transcriptID =~ s/Parent=//g;
    $geneID =~ s/Parent=//g;
    $geneID =~ s/\-T//g;
    if($geneID ~~ @geneList){
     print "$chrom\t$database\t$feature\t$start\t$end\t0.000000\t$strand\t$rfram\tgene_id \"$geneID\"; transcript_id \"$transcriptID\";\n";
    } else {
     die "Something is wrong in line (gene identifier not found in list: $geneID):\n$_\n";
    }
   } elsif($info =~ /Parent=U1-\d-T/){
    $geneID = $info;
    $transcriptID = $info;
    $transcriptID =~ s/Parent=//g;
    $geneID =~ s/Parent=//g;
    $geneID =~ s/\-T//g;
    if($geneID ~~ @geneList){
     print "$chrom\t$database\t$feature\t$start\t$end\t0.000000\t$strand\t$rfram\tgene_id \"$geneID\"; transcript_id \"$transcriptID\";\n";
    } else {
     die "Something is wrong in line (gene identifier not found in list: $geneID):\n$_\n";
    }
   } else {
    die "Something is wrong in line:\n$_\n";
   }
  }
 }
 if($feature eq 'CDS'){
  for my $info (@otherInfoList){
   if($info =~ /Parent=Afu\S+\-T/){
    $geneID = $info;
    $transcriptID = $info;
    $transcriptID =~ s/Parent=//g;
    $geneID =~ s/Parent=//g;
    $geneID =~ s/\-T//g;
    if($geneID ~~ @geneList){
     print "$chrom\t$database\t$feature\t$start\t$end\t0.000000\t$strand\t$rfram\tgene_id \"$geneID\"; transcript_id \"$geneID\";\n";
    } else {
     die "Something is wrong in line (gene identifier not found in list: $geneID):\n$_\n";
    }
   } else {
    # We do not expect snRNAs to have CDS, this is why there is not a "elsif" for U1-1 or U1-2 like we do have in exon features
    die "Something is wrong in line:\n$_\n";
   }
  }
 }
 if (($feature eq 'rRNA') or ($feature eq 'mRNA') or ($feature eq 'ncRNA') or ($feature eq 'snRNA') or ($feature eq 'tRNA') or ($feature eq 'snoRNA')){
  for my $info (@otherInfoList){
   if($info =~ /ID=Afu\S+\-T/){
    $transcriptID = $info;
    $transcriptID =~ s/ID=//g;
   } elsif (($info =~ /ID=U\S+\-T/) and ($feature eq "snRNA")) {
    $transcriptID = $info;
    $transcriptID =~ s/ID=//g;
   } elsif ($info =~ /geneID=Afu\S+/){
    $geneID = $info;
    $geneID =~ s/geneID=//g;
   } elsif(($info =~ /ID=U\S+/) and ($feature eq "snRNA")){
    $geneID = $info;
    $geneID =~ s/geneID=//g;
   } elsif ($info =~ /gene_name=\S+/){
    #TODO I think there is nothing to do with gene names now
   } else {
    die "Something is wrong in line:\n$_\n";
   }
  }
  if($geneID ~~ @geneList){
   print "$chrom\t$database\t$feature\t$start\t$end\t0.000000\t$strand\t$rfram\tgene_id \"$geneID\"; transcript_id \"$transcriptID\";\n";
  } else {
   die "Something is wrong in line (gene identifier not found in list: $geneID):\n$_\n";
  }
 }
}

close(WGTF);
