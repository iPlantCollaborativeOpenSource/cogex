# -*- perl -*-

# t/001_load.t - check module loading and create testing directory,
# including connecting to the DB on biocon

use Test::More tests => 26;

BEGIN {
  use_ok( 'CoGeX' );
  use_ok( 'CoGeX::Result::Annotation' );
  use_ok( 'CoGeX::Result::FeatureType' );
  use_ok( 'CoGeX::Result::AnnotationType' );
  use_ok( 'CoGeX::Result::GenomicSequence' );
  use_ok( 'CoGeX::Result::AnnotationTypeGroup' );
  use_ok( 'CoGeX::Result::Image' );
  use_ok( 'CoGeX::Result::Location' );
  use_ok( 'CoGeX::Result::DataSource' );
  use_ok( 'CoGeX::Result::Organism' );
  use_ok( 'CoGeX::Result::Dataset' );
  use_ok( 'CoGeX::Result::Permission' );
  use_ok( 'CoGeX::Result::Sequence' );
  use_ok( 'CoGeX::Result::SequenceType' );
  use_ok( 'CoGeX::Result::Feature' );
  use_ok( 'CoGeX::Result::User' );
  use_ok( 'CoGeX::Result::FeatureList' );
  use_ok( 'CoGeX::Result::UserGroup' );
  use_ok( 'CoGeX::Result::FeatureListConnector' );
  use_ok( 'CoGeX::Result::UserGroupConnector' );
  use_ok( 'CoGeX::Result::FeatureListGroup' );
  use_ok( 'CoGeX::Result::UserGroupFeatureListPermissionConnector' );
  use_ok( 'CoGeX::Result::FeatureListGroupImageConnector' );
  use_ok( 'CoGeX::Result::UserSession' );
  use_ok( 'CoGeX::Result::FeatureName' );
}

my $connstr = 'dbi:mysql:genomes:biocon:3306';
my $s = CoGeX->connect($connstr, 'cnssys', 'CnS' );

isa_ok ($s, 'CoGeX');
