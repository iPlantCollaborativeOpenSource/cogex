package CoGeX::Result::Organism;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2006-12-01 18:13:38

use strict;
use warnings;
use CoGeX::ResultSet::Organism;
use base 'DBIx::Class::Core';

=head1 NAME

CoGeX::Organism

=head1 SYNOPSIS

This object uses the DBIx::Class to define an interface to the C<organism> table in the CoGe database.
The C<organism> table contains the name, description, and normalized name for an organism.

=head1 DESCRIPTION

Has columns:
C<organism_id> (Primary Key)
Type: INT, Default: undef, Nullable: no, Size: 11
Primary identification key for table.

C<name>
Type: VARCHAR, Default: "", Nullable: no, Size: 200
Organism name.

C<description>
Type: VARCHAR, Default: undef, Nullable: yes, Size: 255
Organism description.

C<normalized_name>
Type:VARCHAR, Default: "", Nullable: no, Size: 200
File-system 'safe' (only alphanumeric characters and underscores) version of 'name' field above.


Relates to CCoGeX::Result::DatasetGroup> via C<organism_id>, in a one-to-many relationship.

=head1 USAGE

  use CoGeX;

=head1 METHODS

=cut

__PACKAGE__->table("organism");
__PACKAGE__->add_columns(
  "organism_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 200 },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "restricted",  { data_type => "int", default_value => "0", is_nullable => 0, size => 1 },
  "access_count",  { data_type => "int", default_value => "0", is_nullable => 0, size => 10 },
);
__PACKAGE__->set_primary_key("organism_id");

__PACKAGE__->has_many("dataset_groups" => "CoGeX::Result::DatasetGroup", 'organism_id');


################################################ subroutine header begin ##

=head2 current_genome

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 
           : 

See Also   : 

=cut

################################################## subroutine header end ##

sub current_genome
  {
    my $self = shift;
    my %opts = @_;
    my $gstid = $opts{type} || $opts{genomic_sequence_type} || $opts{sequence_type} || $opts{gstid};
    $gstid = 1 unless $gstid;
    $gstid = ref($gstid) =~/Type/ ? $gstid->id : $gstid;
    my ($dsg) = $self->dataset_groups({genomic_sequence_type_id=>$gstid},
				      {'order_by' => 'me.version desc',
				       join=>[{'dataset_connectors'=>'dataset'}, 'organism'],
				      prefetch=>[{'dataset_connectors'=>'dataset'}, 'organism']
				      },
				     );
    return $dsg;
  }


################################################ subroutine header begin ##

=head2 current_datasets

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 
           : 

See Also   : 

=cut

################################################## subroutine header end ##

sub current_datasets
  {
    my $self = shift;
    my %opts = @_;
    my $dgs = $self->current_genome(%opts);
    return $dgs->datasets();
  }


################################################ subroutine header begin ##

=head2 current_datasets_old

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 
           : 

See Also   : 

=cut

################################################## subroutine header end ##

sub current_datasets_old
  {
    my $self = shift;
    my %opts = @_;
    my $type = $opts{type} || $opts{genomic_sequence_type} || $opts{sequence_type} || $opts{gstid};
    $type =1 unless $type;
    my %data;
    my $typeid;
    $typeid = ref($type) =~/Type/ ? $type->id : $type;
    my $version;
    my $contig_set =0;
    ds_loop: foreach my $ds ($self->datasets({},{distict=>'version',order_by=>'version desc'}))
      {
	next unless $ds->sequence_type && $ds->sequence_type->id eq $typeid;
	$version = $ds->version unless $version;
	$version = $ds->version if $ds->version > $version;
#	next unless $version == $ds->version;
	my @chrs = $ds->get_chromosomes;
	$contig_set = 1 if scalar @chrs > 50; #more than 50 chromosome?  probably a contig dataset
	foreach my $chr (@chrs)
	  {
	    #this is a hack but the general problem is that some organisms have different chromosomes at different versions, however, partially complete genomes will have many contigs and different versions will have different contigs.  So, to get around this, there is a check to see if the chromosome name has contig in it, if so, then only the most current version is used.  Otherwise, all versions are game.
	    next unless $chr;
	    if ($chr =~ /contig/i || $chr=~/scaffold/i || $contig_set)
	      {
		$contig_set = 1;
		next ds_loop if $ds->version ne $version;
	      }
	    $data{$chr} = $ds unless $data{$chr};# || $contig_set;
	    $data{$chr} = $ds if $ds->version > $data{$chr}->version;
	  }
      }
    %data = map {$_->id,$_} values %data;
    return wantarray ? values %data : [values %data];
  }


################################################ subroutine header begin ##

=head2 genomic_sequence_types

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub genomic_sequence_types
  {
    my $self = shift;
    my %data;
    foreach my $ds ($self->datasets)
      {
	my $type = $ds->sequence_type;
	$data{$type->id} = $type;
      }
    return wantarray ? values %data : [values %data];
  }


################################################ subroutine header begin ##

=head2 types

 Usage     : 
 Purpose   : See genomic_sequence_types()
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : Alias for genomic_sequence_types() method.

See Also   : genomic_sequence_types()

=cut

################################################## subroutine header end ##

sub types
  {
    return shift->genomic_sequence_types(@_);
  }


################################################ subroutine header begin ##

=head2 datasets

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub datasets
  {
    my $self = shift;
    my %opts = @_;
    my %ds;
    map {$ds{$_->id}=$_} map{$_->datasets} $self->dataset_groups;
    return wantarray ? values %ds : [values %ds];
  }

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
