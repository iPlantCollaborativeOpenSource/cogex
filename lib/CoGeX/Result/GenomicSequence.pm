package CoGeX::Result::GenomicSequence;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2006-12-01 18:13:38

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CoGeX::GenomicSequence

=head1 SYNOPSIS

This object uses the DBIx::Class to define an interface to the C<genomic_sequence_id> table in the CoGe database.
The C<genomic_sequence_id> table defines a genomic sequence (that is, a simple sequence of DNA). The actual sequence is stored in flat text file on disk in FASTA format.
Note that this table is used by the C<dataset_group> table, and is unrelated to the C<sequence> table or the C<feature> table.

=head1 DESCRIPTION

Has columns:
C<genomic_sequence_id> (Primary Key)
Type: INT, Default: 1, Nullable: no, Size: 11
Primary identification key for table.

C<sequence_length>
Type: INT, Default: "", Nullable: no, Size: 11
Length of genomic sequence, in basepairs.

C<chromosome>
Type: VARCHAR, Default: "", Nullable: no, Size: 255
Name of chromosome described by this record.

C<dataset_group_id>
Type: INT, Default: "", Nullable: no, Size: 11
Reference to a record in the C<dataset_group> table.

Relates to a record in the CCoGeX::Result::DatasetGroup> object via C<dataset_group_id> in a one-to-one relationship.

=head1 USAGE

  use CoGeX;

=head1 METHODS

=cut


__PACKAGE__->table("genomic_sequence");
__PACKAGE__->add_columns(
  "genomic_sequence_id",
  { data_type => "INT", default_value => 1, is_nullable => 0, size => 11 },
  "sequence_length",
  { data_type => "INT", default_value => "", is_nullable => 0, size => 11 },
  "chromosome",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 255 },
  "dataset_group_id",
  { data_type => "INT", default_value => "", is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("genomic_sequence_id");
__PACKAGE__->belongs_to("dataset_group" => "CoGeX::Result::DatasetGroup", "dataset_group_id");

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
