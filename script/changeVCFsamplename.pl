#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$changefile,$split);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"o:s"=>\$fOut,
	"g:s"=>\$changefile,
	"split:s"=>\$split,
			) or &USAGE;
&USAGE unless ($fIn and $fOut and $changefile);
$split||="\n";
my %stat;
my @sample;
open IN,$changefile;
while(<IN>){
	chomp;
	next if ($_ eq "" || /^$/);
	my($sample,$newid,undef)=split/\s+/,$_;
	$stat{$sample}=$newid;
	push @sample,$sample;
}
close IN;
$/=$split if($split);
open In,$fIn;
if ($fIn =~ /.gz/) {
	close In;
	open In,"zcat $fIn|";
}
my @info;
open Out,">$fOut";
while (<In>) {
	chomp;
	next if($_ eq ""|| /^$/);
	if(/^##/){
		print Out $_,"\n";
		next;
	}elsif(/^#/){
		my@info=split/\t/,$_;
		my@out;
		foreach my$info(@info){
			if(exists $stat{$info}){
				$info=~s/$info/$stat{$info}/g;
			}
			push @out,$info;
		}
		print Out join("\t",@out),"\n";
		next;
	}else{
		print Out $_,"\n";
	}
}
close In;
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

Usage:
  Options:
  -i	<file>	input file name
  -o	<file>	output file name
  -g	<file>	sample change file
  -split	<str>	split string
  -h         Help

USAGE
        print $usage;
        exit;
}
