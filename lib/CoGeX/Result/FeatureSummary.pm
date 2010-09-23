package CoGeX::Result::FeatureSummary;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CoGeX::Result::FeatureSummary

=head1 SYNOPSIS

This object defines a view that can be used to obtain summarized feature
information for a dataset in the CoGe database.

=head1 DESCRIPTION

Has columns:
C<feature_type_id>
Type: INT, Default: undef, Nullable: no, Size: 11

C<feature_type_name>
Type: VARCHAR, Default: "", Nullable: no, Size 255

C<feature_count>
Type: INT, Default: undef, Nullable: no, Size: 11

=head1 USAGE

  use CoGeX;

=head1 METHODS

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("feature");
__PACKAGE__->add_columns(
    "feature_type_id",
    {   data_type     => "INT",
        default_value => undef,
        is_nullable   => 0,
        size          => 11
    },
    "feature_type_name",
    {   data_type     => "VARCHAR",
        default_value => "",
        is_nullable   => 0,
        size          => 255
    },
    "feature_count",
    {   data_type     => "INT",
        default_value => undef,
        is_nullable   => 0,
        size          => 11
    },
);

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'END_OF_DEFINITION');
    SELECT
        f.feature_type_id   AS feature_type_id,
        t.name              AS feature_type_name,
        COUNT(f.feature_id) AS feature_count
    FROM feature f JOIN feature_type t ON t.feature_type_id = f.feature_type_id
    WHERE f.dataset_id = ?
    GROUP BY f.feature_type_id
END_OF_DEFINITION

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
