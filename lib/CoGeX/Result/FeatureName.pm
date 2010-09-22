package CoGeX::Result::FeatureName;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2006-12-01 18:13:38

use strict;
use warnings;

use base 'DBIx::Class::Core';
use CoGeX::ResultSet::FeatureName;
=head1 NAME

CoGeX::FeatureName

=head1 SYNOPSIS

This object uses the DBIx::Class to define an interface to the C<feature_name> table in the CoGe database.
The C<feature_name> table describes a variety of identifying information for a feature.

=head1 DESCRIPTION

Has columns:
C<feature_name_id> (Primary Key)
Type: INT, Default: undef, Nullable: no, Size: 11
Primary identification key for table.

C<name>
Type: VARCHAR, Default: "", Nullable: no, Size: 100
Name of the feature.

C<description>
Type: VARCHAR, Default: undef, Nullable: yes, Size: 255
Description of the feature.

C<feature_id>
Type: INT, Default: 0, Nullable: no, Size: 11
ID number that links a record in the C<feature_name> table to a record in the C<feature> table.

C<primary_name>
Type: TINYINT, Default: 0, Nullable: no, Size: 1
????

Relates to CCoGeX::Result::Feature> via C<feature_id>; one-to-one relationship.

=head1 USAGE

  use CoGeX;

=head1 METHODS

=cut

__PACKAGE__->table("feature_name");
__PACKAGE__->add_columns(
  "feature_name_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 255 },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 1024,
  },
  "feature_id",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "primary_name",
  { data_type => "TINYINT", default_value => 0, is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("feature_name_id");
__PACKAGE__->belongs_to("feature" => "CoGeX::Result::Feature", "feature_id");
__PACKAGE__->has_one("annotation" => "CoGeX::Result::Annotation", {'foreign.feature_id'=>'self.feature_id'});




1;


=head1 BUGS

=head1 SUPPORT

=head1 AUTHORS

 Eric Lyons
 Brent Pedersen

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

=cut
