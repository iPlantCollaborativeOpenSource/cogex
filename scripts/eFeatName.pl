#!/usr/bin/perl -w

use CoGeX;
use strict;
use Data::Dumper;
use DBIxProfiler;
$| = 1;


my $connstr = 'dbi:mysql:genomes:biocon:3306';
my $s = CoGeX->connect($connstr, 'cnssys', 'CnS' );

#$s->storage->debugobj(new DBIxProfiler());
#$s->storage->debug(1);




my @results;
my $rs = $s->resultset('FeatureName')->search( { 
                    'me.name' =>  { '-like' => 'At2g26%' } 
                    },
                    {
                        join => [ {'feature' => 'locations' }]
                    });

#print "got resultset\n";
while (my $fn = $rs->next()){
    my $locs = $fn->feature->locations;
    
    foreach my $loc ($locs->next()){
        print $loc->start . "\n";
    }
    #map { push(@results, $_->annotation)  } $feat->annotations;
}


