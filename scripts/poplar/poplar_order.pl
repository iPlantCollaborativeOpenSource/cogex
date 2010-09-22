#! /usr/bin/perl -w

use strict;
use CoGeX;


# 9min 9 sec
my $connstr = 'dbi:mysql:genomes:biocon:3306';
my $s = CoGeX->connect($connstr, 'cnssys', 'CnS' );

# 6min 42sec
my $connstr = 'dbi:Pg:dbname=genomes;host=biocon;port=5432';
my $s = CoGeX->connect($connstr, 'bpederse', 'wsa47r' );


$s->storage->debug(0);

my $org = $s->resultset('Dataset')->search(
    { 'organism.name' => {like => "%Poplar%" },
      'version'       => '1.1' 
    },
    { join => 'organism' }
);
my $orgid = $org->next()->dataset_id;


my $rs = $s->resultset('Feature')->search(
        { 
            'dataset_id' => $orgid,
            'feature_type.name' =>   'CDS', 
        },
        {
            join => ['feature_names','feature_type','sequences'],
            prefetch => ['feature_names','feature_type'],
            order_by => ['me.feature_id']
        }

);

while( my $feature = $rs->next()){
    print "> " . $feature->feature_names->next()->name . "\n";
    my $seqset = $feature->sequences;
    foreach my $seq ($feature->sequences({},{prefetch=>"sequence_type"})){
        print $seq->sequence_data; # if $seq->sequence_type->name =~ /protein/i;
    }

    print "\n";
}
