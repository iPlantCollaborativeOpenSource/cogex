#!/usr/bin/perl -w

use strict;
use CoGeX;
use DBIxProfiler;
use CoGeX::Feature;
use CoGe::Genome::Accessory::Annotation;
use Data::Dumper;

my $connstr = 'dbi:mysql:dbname=genomes;host=biocon;port=3306';
my $coge = CoGeX->connect($connstr, 'cnssys', 'CnS' );
#$coge->storage->debugobj(new DBIxProfiler());
#$coge->storage->debug(0);
foreach my $feat ($coge->resultset('Feature')->search(
						      {"feature_names.name"=>"at2g29610"},
						      {join => ['feature_names']}
						     ))
  {
    next unless $feat->dataset->version == "7";
    foreach my $anno ($feat->annotations({},{prefetch=>[{'annotation_type'=>'annotation_type_group'}]}))
      {
	print $anno->annotation,"\n";
      }
  }

