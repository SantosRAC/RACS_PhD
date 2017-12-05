#!/usr/bin/perl

use warnings;
use strict;
use LWP::Simple;
use Getopt::Long;

# 0.1 (UNICAMP master Renato: https://github.com/SantosRAC/UNICAMP_RACSMaster)
# 0.2 changes:
## - 

my $version='0.2';
my $license='';
my $keggPathwaysFile='';
my $gmtFile='';
my $help='';
my %path2KO;
my $sleep=2;
my $sleepSET='';

GetOptions(
  'help|h|?'                 => \$help,
  'license|l'                => \$license,
  'kegg_pathways_file|i=s'   => \$keggPathwaysFile,
  'sleep_set|s'              => \$sleepSET,
  'ko_gmt|o=s'               => \$gmtFile,
);

if(!-s $keggPathwaysFile) {
  print "User must provide KEGG maps.\n";
  &usage();
  exit(1);
}

if(!-s $keggPathwaysFile) {
  print "The input file with Kegg pathways provided by user does not exist.\n";
  &usage();
  exit(1);
}

if(-s $gmtFile) {
  print "The output file already exists.\n";
  &usage();
  exit(1);
}

if(!$gmtFile) {
  print "The output file name is required.\n";
  &usage();
  exit(1);
}

if($help) {
  &usage();
  exit(0);
}

if($license) {
 &license();
 exit(0);
}

open(KEGGPATHWAYS,$keggPathwaysFile);

# Check if user provided a sleep time in seconds to wait (KEGG REST request)
if($sleepSET){
 $sleep = $sleepSET;
}

while(<KEGGPATHWAYS>) {
 chomp;
 my ($keggPathwayID,$keggPathwayDesc)=split(/\t/,$_);
 $keggPathwayID =~ s/path://g;
 if ($path2KO{$keggPathwayID}){
  die "$keggPathwayID appears more than one time in input file.\n";
 } else {
  @{$path2KO{$keggPathwayID}}=();
 }
 my $kegg_url = "http://rest.kegg.jp/link/ko/$keggPathwayID";
 my $content = get($kegg_url);
 if($content =~ /path:(map\d+)	ko:(K\d+)/) {
  my @contentLines = split(/\n/,$content);
  foreach my $line (@contentLines){
   my (undef,$ko)=split(/\t/,$line);
   $ko =~ s/ko://;
   if($ko ~~ @{$path2KO{$keggPathwayID}}){
    die "Duplicated KO for a pathway ($keggPathwayID): $ko\n";
   }
   push(@{$path2KO{$keggPathwayID}},$ko);
  }
  open(GMT,">>",$gmtFile);
  print GMT "$keggPathwayID\t$keggPathwayDesc\t".join("\t",@{$path2KO{$keggPathwayID}})."\n";
  close(GMT);
 }
 sleep $sleep;
}

close(KEGGPATHWAYS);

sub usage {
    print STDERR "$0 version $version, Renato Augusto Correa dos Santos\n";
    print STDERR <<EOF;

NAME
    $0 takes a list of Kegg Pathways resulting from using Kegg List API, and returns a GMT file
    with maps and the corresponding KOs.

USAGE
    $0 --kegg_pathways_file kegg.list.txt --ko_gmt OUTFILE.gmt

OPTIONS
    --kegg_pathways_file  -i      Input file with Kegg Pathways from list of Kegg API.             REQUIRED
      Example of line in this file (obtained with KEGG REST: http://rest.kegg.jp/list/pathway):
      path:map00010   Glycolysis / Gluconeogenesis
    --ko_gmt              -o      GMT file (pathways and corresponding KOs)                        REQUIRED
    --sleep_set           -s      Time (in seconds) to make server request (KEGG REST)             OPTIONAL
      Default time: 2 seconds
    --help                -h      This help.
    --license             -l      License.

EOF
}

sub license{
    print STDERR <<EOF;
Copyright (C) 2016,2017 Renato Augusto Correa dos Santos
http://fcfrp.usp.br/
e-mail: renatoacsantos\@gmail.com

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
EOF
exit;
}
