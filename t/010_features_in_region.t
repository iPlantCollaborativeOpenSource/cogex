# -*- perl -*-

# t/010_features_in_region.t - get the feature objects for an
# dataset in a particular region

use Data::Dumper;
use Benchmark;
use Test::More tests => 3;

BEGIN {
    use_ok( 'CoGeX' );
    use_ok( 'DBIxProfiler' );
}

SKIP: {
    skip "test database not available", 1 if !exists $ENV{HAVE_TESTDB};

    my $connstr = 'dbi:mysql:genomes:biocon:3306';
    my $s = CoGeX->connect($connstr, 'cnssys', 'CnS' );

    #$s->storage->debugobj(new DBIxProfiler());
    #$s->storage->debug(1);

    isa_ok ($s, 'CoGeX');

    my $data = {};
    my $start = 10800000;
    my $stop = 10850000;
    my $t0 = new Benchmark;

    while ( $stop < 12000000 ) {
        my @f = $s->get_features_in_region2(
            start => $start,
            end => $stop,
            chromosome => 2,
            dataset_id => 4
        );
        $data->{ $stop - $start } = { 'time' => new Benchmark, 'features' => scalar @f };
        $stop += 50000;
    }

    print STDERR "REGION,FCOUNT,TIME,SYSTIME\n";
    foreach my $reg ( sort { $a <=> $b } keys %$data ) {
        print STDERR "$reg,";
        print STDERR $data->{$reg}->{'features'}, ",";
        my $ts = timestr( timediff( $data->{$reg}->{'time'}, $t0 ) );
        #  14 wallclock secs (13.84 usr +  0.07 sys = 13.91 CPU)
        $ts =~ /(\d+) wallclock secs \((.*) usr.*\)/;
        print STDERR $1, ",", $2, "\n";
    }
}
