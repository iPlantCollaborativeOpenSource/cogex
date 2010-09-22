package CoGeX::Result::Dataset;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2006-12-01 18:13:38

use strict;
use warnings;
use Data::Dumper;
use POSIX;
use base 'DBIx::Class::Core';
use CoGeX::Result::Feature;
use CoGeX::ResultSet::Dataset;
use Text::Wrap;
use Carp;

=head1 NAME

CoGeX::Dataset

=head1 SYNOPSIS

This object uses the DBIx::Class to define an interface to the C<dataset> table in the CoGe database.

=head1 DESCRIPTION

Has columns:
C<dataset_id> (Primary Key)
Type: INT, Default: undef, Nullable: no, Size: 11

C<data_source_id>
Type: INT, Default: 0, Nullable: no, Size: 11

C<name>
Type: VARCHAR, Default: "", Nullable: no, Size: 100

C<description>
Type: VARCHAR, Default: undef, Nullable: yes, Size: 255

C<version>
Type: VARCHAR, Default: undef, Nullable: yes, Size: 50

C<link>
Type: TEXT, Default: undef, Nullable: yes, Size: 65535

C<date>
Type: DATETIME, Default: "", Nullable: no, Size: 19

Belongs to CCoGeX::Result::CoGeX::DataSource> via C<data_source_id>
Has many CCoGeX::Result::Feature> via C<dataset_id>
Has many CCoGeX::Result::DatasetConnector> via C<dataset_id>

=head1 USAGE

 use CoGeX;

=head1 METHODS

=cut

__PACKAGE__->table("dataset");
__PACKAGE__->resultset_class("CoGeX::ResultSet::Dataset");
__PACKAGE__->add_columns(
  "dataset_id",{ data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "data_source_id",{ data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "name",{ data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 100 },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "version",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 50,
  },
  "link",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "date",
  { data_type => "DATETIME", default_value => "", is_nullable => 0, size => 19 },
  "restricted",  { data_type => "int", default_value => "0", is_nullable => 0, size => 1 },
);

__PACKAGE__->set_primary_key("dataset_id");
__PACKAGE__->has_many("features" => "CoGeX::Result::Feature", 'dataset_id');
__PACKAGE__->has_many("dataset_connectors" => "CoGeX::Result::DatasetConnector", 'dataset_id', {join_type=>undef});
__PACKAGE__->belongs_to("data_source" => "CoGeX::Result::DataSource", 'data_source_id');


################################################ subroutine header begin ##

=head2 dataset_groups

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub dataset_groups
  {
    my $self = shift;
    my %opts = @_;
    my $chr = $opts{chr};
    my @dsgs;
    foreach my $dsc($self->dataset_connectors())
      {
	if (defined $chr)
	  {
	    my %chrs = map {$_,1} $dsc->dataset_group->chromosomes;
	    next unless $chrs{$chr};
	  }
	push @dsgs, $dsc->dataset_group;
      }
    return wantarray ? @dsgs : \@dsgs;
  }


################################################ subroutine header begin ##

=head2 groups

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub groups
  {
    shift->dataset_groups(@_);
  }


################################################ subroutine header begin ##

=head2 organism

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub organism
  {
    my $self = shift;
    my %opts = @_;
    my %orgs = map{$_->id, $_} map {$_->organism} $self->dataset_groups;
    if (keys %orgs > 1)
      {
	warn "sub organism in Dataset.pm fetched more than one organism!  Very odd:\n";
	warn join ("\n", map {$_->name} values %orgs),"\n";
	warn "Only one will be returned\n";
      }
    my ($org) = values %orgs;
    return $org;
  }


################################################ subroutine header begin ##

=head2 datasource

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub datasource
  {
    print STDERR "You are using an alias for data_source\n";
    shift->data_source(@_);
  }


################################################ subroutine header begin ##

=head2 get_genomic_sequence 

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub get_genomic_sequence 
  {
    my $self = shift;
    my %opts = @_;
#    print STDERR "Dataset: sub get_genomic_sequence\n";
#    print STDERR Dumper \%opts;
    my $start = $opts{start} || $opts{begin};
    my $stop = $opts{stop} || $opts{end};
    my $chr = $opts{chr};
    $chr = $opts{chromosome} unless defined $chr;
    my $strand = $opts{strand};
    my $seq_type = $opts{seq_type} || $opts{gstid};
    my $debug = $opts{debug};
    my $dsgid = $opts{dsgid};
    my $dsg; 
    $dsg = $dsgid if $dsgid && ref ($dsgid) =~ /DatasetGroup/;
    return $dsg->genomic_sequence(start=>$start, stop=>$stop, chr=>$chr, strand=>$strand, debug=>$debug) if $dsg;
    my $seq_type_id = ref($seq_type) =~ /GenomicSequenceType/i ? $seq_type->id : $seq_type;
    $seq_type_id = 1 unless $seq_type_id && $seq_type_id =~ /^\d+$/;
    foreach my $tmp_dsg ($self->groups)
      {
	if ( ($dsgid && $tmp_dsg->id == $dsgid) || ($seq_type_id && $tmp_dsg->genomic_sequence_type->id == $seq_type_id) )
	  {
	    return $tmp_dsg->genomic_sequence(start=>$start, stop=>$stop, chr=>$chr, strand=>$strand, debug=>$debug);
	  }
      }
    #hmm didn't return -- perhaps the seq_type_id was off.  Go ahead and see if anything can be returned
#    carp "In Dataset.pm, sub get_genomic_sequence.  Did not return sequence from a dataset_group with a matching sequence_type_id.  Going to try to return some sequence from any dataset_group.\n";
    ($dsg) = $self->groups;
    return $dsg->genomic_sequence(start=>$start, stop=>$stop, chr=>$chr, strand=>$strand, debug=>$debug);
  }


################################################ subroutine header begin ##

=head2 get_genome_sequence

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub get_genome_sequence
  {
    return shift->get_genomic_sequence(@_);
  }
  
  
################################################ subroutine header begin ##

=head2 genomic_sequence

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##  
  
sub genomic_sequence
  {
    return shift->get_genomic_sequence(@_);
  }


################################################ subroutine header begin ##

=head2 trim_sequence

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    :
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub trim_sequence {
  my $self = shift;
  my( $seq, $seqstart, $seqend, $newstart, $newend ) = @_;
  
  my $start = $newstart-$seqstart;
  my $stop = length($seq)-($seqend-$newend)-1;  
#  print STDERR join ("\t", $seqstart, $seqend, $newstart, $newend),"\n";
#  print STDERR join ("\t", length ($seq), $start, $stop, $stop-$start+1),"\n";
  $seq = substr($seq, $start, $stop-$start+1);
#  print STDERR "final seq lenght: ",length($seq),"\n";
  return($seq);
}


################################################## subroutine header start ##

=head2 last_chromsome_position

 Usage     : my $last = $genome_seq_obj->last_chromosome_position($chr);
 Purpose   : gets the last genomic sequence position for a dataset given a chromosome
 Returns   : an integer that refers to the last position in the genomic sequence refered
             to by a dataset given a chromosome
 Argument  : string => chromsome for which the last position is sought
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##


 sub last_chromosome_position
   {
     my $self = shift;
     my $chr = shift;
     return unless defined $chr;
     my ($dsg) = $self->dataset_groups;
     my ($item) =  $dsg->genomic_sequences(
					  {
					   chromosome=>"$chr",
					  },
					  );
     unless ($item)
       {
	 warn "Unable to find genomic_sequence object for $chr.";
	 return;
       }
     my $stop = $item->sequence_length();
     unless ($stop)
      {
        warn "No genomic sequence for ",$self->name," for chr $chr\n";
        return;
      }
     return $stop;
   }


################################################ subroutine header begin ##

=head2 last_chromosome_position_old

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub last_chromosome_position_old
   {
     my $self = shift;
     my $chr = shift;
     my $stop =  $self->genomic_sequences(
                                          {
                                           chromosome=>"$chr",
                                          },
                                         )->get_column('stop')->max;
     unless ($stop)
      {
        warn "No genomic sequence for ",$self->name," for chr $chr\n";
        return;
      }
     $stop;
   }


################################################ subroutine header begin ##

=head2 sequence_type

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub sequence_type
  {
    my $self = shift;
    my (@dsgs) = $self->groups;
    my %types = map{$_->id, $_} map {$_->genomic_sequence_type} @dsgs;
    my @types = values %types;
#    my ($type) = $self->genomic_sequences->slice(0,0);
#    return $type ? $type->genomic_sequence_type : undef;
    if (@types ==1)
      {
	return shift @types;
      }
    elsif (@types > 1)
      {
	return wantarray ? @types : \@types;
      }
    else
      {
	return undef;
      }
  }
  
 
################################################ subroutine header begin ##

=head2 genomic_sequence_type

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub genomic_sequence_type
  {
    my $self = shift;
    return $self->sequence_type(@_);
  }


################################################ subroutine header begin ##

=head2 get_chromosomes

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub get_chromosomes
  {
    my $self = shift;
    my %opts = @_;
    my $ftid = $opts{ftid}; #feature_type_id for feature_type of name "chromosome";
    my $length = $opts{length}; #opts to return length of chromosomes as well
    my @data;
    #this query is faster if the feature_type_id of feature_type "chromosome" is known.
    #features of this type refer to the entire stored sequence which may be a fully
    # assembled chromosome, or a contig, supercontig, bac, etc.
    if ($length)
      {
	if ($ftid)
	  {
	    @data = $self->features({
				     feature_type_id=>$ftid,
				    },
				   );
	  }
	else
	  {
	    @data =  $self->features(
				     {name=>"chromosome"},
				     {
				      join=>"feature_type",
				     },
				    );
	  }
      }
    else
      {
	if ($ftid)
	  {
	    @data = map{$_->chromosome} $self->features({
							 feature_type_id=>$ftid,
							},
							{
#							 as=>"chromosome",
							}
						       );
	  }
	else
	  {
	    @data =  map {$_->chromosome} $self->features(
							  {name=>"chromosome"},
							  {
							   join=>"feature_type",

#							   as=>"chromosome",
							  },
							 );
	  }
      }
    return wantarray ? @data : \@data;
  }


################################################ subroutine header begin ##

=head2 chromosomes

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub chromosomes
  {
    my $self = shift;
    $self->get_chromosomes(@_);
  }
    

################################################ subroutine header begin ##

=head2 has_chromosome

 Usage     : $ds->has_chromosome(chr=>"12")
 Purpose   : test to see if a dataset has a particular chromsome
 Returns   : 1 if yes, 0 if no
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub has_chromosome
  {
    
    my $self = shift;
    my %opts = @_;
    my $chr = $opts{chr};
    my ($res) = $self->features(
				{"feature_type.name"=>"chromosome",
				 "chromosome"=>"$chr",
				},
				{join=>["feature_type"]}
			       );
    return 1 if $res;
    return 0;
  }
    

################################################ subroutine header begin ##

=head2 percent_gc

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub percent_gc
  {
    my $self = shift;
    my %opts = @_;
    my $count = $opts{count};
#    my $chr = $opts{chr};
    my $seq = $self->genomic_sequence(%opts);
    my $length = length $seq;
    return unless $length;
    my ($gc) = $seq =~ tr/GCgc/GCgc/;
    my ($at) = $seq =~ tr/ATat/ATat/;
    my ($n) = $seq =~ tr/nNxX/nNxX/;
    return ($gc,$at, $n) if $count;
    return sprintf("%.4f", $gc/$length),sprintf("%.4f", $at/$length),,sprintf("%.4f", $n/$length);
  }


################################################ subroutine header begin ##

=head2 gc_content

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub gc_content
  {
    shift->percent_gc(@_);
  }


################################################ subroutine header begin ##

=head2 fasta

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub fasta
  {
    my $self = shift;
    my %opts = @_;
    my $col = $opts{col};
    #$col can be set to zero so we want to test for defined variable
    $col = $opts{column} unless defined $col;
    $col = $opts{wrap} unless defined $col;
    $col = 100 unless defined $col;
    my $chr = $opts{chr};
    ($chr) = $self->get_chromosomes unless defined $chr;
    my $strand = $opts{strand} || 1;
    my $start = $opts{start} || 1;
    $start =1 if $start < 1;
    my $stop = $opts{stop} || $self->last_chromosome_position($chr);
    my $prot = $opts{prot};
    my $rc = $opts{rc};
    my $gstid=$opts{gstid};
    $strand = -1 if $rc;
    my $seq = $self->genomic_sequence(start=>$start, stop=>$stop, chr=>$chr, gstid=>$gstid);
    $stop = $start + length($seq)-1 if $stop > $start+length($seq)-1;
    my $head = ">".$self->organism->name." (".$self->name;
    $head .= ", ".$self->description if $self->description;
    $head .= ", v".$self->version.")".", Location: ".$start."-".$stop." (length: ".($stop-$start+1)."), Chromosome: ".$chr.", Strand: ".$strand;

    $Text::Wrap::columns=$col;
    my $fasta;


    $seq = $self->reverse_complement($seq) if $rc;
    if ($prot)
      {
	my $trans_type = $self->trans_type;
	my $feat = new CoGeX::Result::Feature;
	my ($seqs, $type) = $feat->frame6_trans(seq=>$seq, trans_type=>$trans_type, gstid=>$gstid);
	foreach my $frame (sort {length($a) <=> length($b) || $a cmp $b} keys %$seqs)
	  {
	    $seq = $seqs->{$frame};
	    $seq = $self->reverse_complement($seq) if $rc;
	    $seq = join ("\n", wrap("","",$seq)) if $col;
	    $fasta .= $head. " $type frame $frame\n".$seq."\n";
	  }
      }
    else
      {
	$seq = join ("\n", wrap("","",$seq)) if $col;
	$fasta = $head."\n".$seq."\n";
      }
    return $fasta;
  }

################################################ subroutine header begin ##

=head2 gff

 Usage     : $ds->gff(print=>1)
 Purpose   : generating a gff file for a dataset from all the features it contains
 Returns   : a string
 Argument  : name_re     =>    regular expression for only displaying features containing a name that matches
             print       =>    print the gff file as the lines are retrieved
             debug       =>    prints some debugging stuff
 Throws    : 
 Comments  : 

See Also   : dataset_group->gff

=cut


################################################## subroutine header end ##

sub gff
  {
    my $self = shift;
    my %opts = @_;
    my $name_re = $opts{name_re};
    my $debug = $opts{debug};
    my $print = $opts{print};
    my $output; #store the goodies

    my %chrs;
    foreach my $chr ($self->get_chromosomes){
      $chrs{$chr} = $self->last_chromosome_position($chr);
    }
    my @chrs = sort { $a cmp $b } keys %chrs;
    my $tmp = "##gff-version\t3\n";
    $output.=  $tmp;
    print $tmp if $print;
    foreach my $chr (@chrs){
      $tmp = "##sequence-region $chr 1 " . $chrs{$chr} . "\n";
      $output .= $tmp;
      print $tmp if $print;
    }
    my %fids = ();
    my $count=0;
    my %types;
    foreach my $chr (@chrs){
        my %seen = ();
        my $feat_rs = $self->features( {
				      'me.chromosome' => $chr,
				     } , 
				     { 
				      'prefetch'           => [ 'feature_type', 'feature_names', {'annotations' => 'annotation_type'}],

				      'order_by'           => [ 'me.start', 'me.feature_type_id'] #go by order in genome, then make sure that genes (feature_type_id == 1) is first
				     }
				   );

        #gff: chr  organization feature_type  start stop strand . name
        print STDERR "dataset_id: " . $self->id . ";  chr: $chr\n" if $debug;
        while(my $feat = $feat_rs->next()){
	  if ($fids{$feat->feature_id}){ next; }
	  my @feat_names;
	  if($name_re){
	    @feat_names = grep { $_ =~ /$name_re/i } $feat->names(); 
	    next unless @feat_names;
	  }
	  else {
	    @feat_names = $feat->names(); 
	  }
	  my $strand = $feat->strand == 1 ? '+' : '-';
	  my ($names) = join (",", @feat_names);
	  my $attrs = "ID=$count";
	  $attrs .= ";Name=$names" if $names;
	  my @annos;
	  foreach my $anno ($feat->annotations)
	    {
	      next unless defined $anno->annotation;
	      my $anno_type = $anno->annotation_type;
	      my $tmp;
	      $tmp .= $anno_type->name.": " if $anno_type && $anno_type->name;
	      $tmp .= $anno->annotation;
	      $tmp =~ s/;//g;
	      push @annos, $tmp;
	    }
	  my $annos = join (",", @annos);
	  my $gstr = join("\t", ($chr, 'coge', $feat->feature_type->name, $feat->start, $feat->stop, ".", $strand, ".", $attrs));
	  $gstr .= ";Note=$annos" if $annos;
	  if($seen{$gstr}){ next; }
	  $seen{$gstr} = 1;
	  $tmp = $gstr . "\n";
	  $output .= $tmp;
	  print $tmp if $print;
	  $types{$feat->feature_type->name}++;
	  $fids{$feat->feature_id} = 1; #feat_id has been used
	  my $parent = $count;
	  $count++;
	  next unless $feat->feature_type_id == 1 && @feat_names; #if not a gene, don't do the next set of searches.
	  my $mrna_rs = $self->features( {
					'me.chromosome' => $chr,
					'feature_names.name' =>  {'IN'=>[@feat_names]},
					'me.feature_type_id'  =>  2
				       } ,
				       {
					'join' => 'feature_names',
					'prefetch'           => [ 'feature_type', 'locations'],
					'order_by'           => [ 'me.start', 'locations.start']
				       });
	  
	  while(my $f = $mrna_rs->next()){
	    if($fids{$f->feature_id}){ next; }
	    my $mrna_names = join (",", $f->names);
	    my $mrna_attrs = "Parent=$parent";
	    $mrna_attrs .= ";Name=$mrna_names" if $mrna_names;
	    my @tannos;
	    foreach my $anno ($f->annotations)
	      {
		next unless defined $anno->annotation;
		my $tmp;
		$tmp .= $anno->annotation_type->name.": " if $anno->annotation_type && $anno->annotation_type->name;
		$tmp .= $anno->annotation;
		$tmp =~ s/;//g;
		push @tannos, $tmp;
	      }
	    my $mrna_annos = join (",", @tannos);
	    foreach my $loc ($f->locations({},{'order_by'=>'start'})){
	      next if $loc->start > $feat->stop || $loc->stop < $feat->start; #outside of genes boundaries;  Have to count it as something else
	      my $gstr = join("\t", ($f->chr, 'coge', $f->feature_type->name, $loc->start, $loc->stop, ".", $strand, ".", $mrna_attrs));
	      $gstr.=";Note=$mrna_annos" if $mrna_annos;
	      if($seen{$gstr}){ next; }
	      $seen{$gstr} = 1;
	      $tmp = $gstr . "\n";
	      $output .= $tmp;
	      print $tmp if $print;
	      $fids{$f->feature_id} = 1; #feat_id has been used;
	      $types{$f->feature_type->name}++;
	    }
	  }
	  my $sub_rs = $self->features( {
				       'me.chromosome' => $chr,
				       'feature_names.name' =>  {'IN'=>[@feat_names]},
				       , 'me.feature_type_id'  =>  { 'NOT IN' => [1,2] }
				      },
				      {
				       'join'               => [ 'feature_names'],
				       'prefetch'           => [ 'feature_type', 'locations'] 
				       ,'order_by'           => [ 'me.chromosome', 'me.start']
				      });
	  while(my $f = $sub_rs->next()){
	    if($fids{$f->feature_id}){ next; }
	    my $other_names = join (",", $f->names);
	    my $other_attrs = "Parent=$parent";
	    $other_attrs .= ";Name=$other_names" if $other_names;
	    my @tannos;
	    foreach my $anno ($f->annotations)
	      {
		next unless $anno->annotation;
		my $tmp;
		$tmp .= $anno->annotation_type->name.": " if $anno->annotation_type && $anno->annotation_type->name;
		$tmp .= $anno->annotation;
		$tmp =~ s/;//g;
		push @tannos, $tmp;
	      }
	    my $other_annos = join (",", @tannos);
	    foreach my $loc ($f->locations({},{'order_by'=>'start'})){
	      next if $loc->start > $feat->stop || $loc->stop < $feat->start; #outside of genes boundaries;  Have to count it as something else
	      my $gstr = join("\t", ($f->chr, 'coge', $f->feature_type->name, $loc->start, $loc->stop, ".", $strand, ".", $other_attrs));
	      $gstr.=";Note=$other_annos" if $other_annos;
	      
	      if($seen{$gstr}){ next; }
	      $seen{$gstr} = 1;
	      $tmp = $gstr . "\n";
	      $output .= $tmp;
	      print $tmp if $print;
	      $fids{$f->feature_id} = 1; #feat_id has been used;
	      $types{$f->feature_type->name}++;
	    }
	  }
	}
      }
    return $output;
  }

################################################ subroutine header begin ##

=head2 trans_type

 Usage     : 

 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub trans_type
  {
    my $self = shift;
    my $trans_type;
    foreach my $feat ($self->features({feature_type_id=>3},{rows=>10}))
      {
#	next unless $feat->type->name =~ /cds/i;
	my ($code, $type) = $feat->genetic_code;
	($type) = $type =~/transl_table=(\d+)/ if $type =~ /transl_table/;
	return $type if $type;
      }
    return 1; #universal genetic code type;
  }


################################################ subroutine header begin ##

=head2 reverse_complement

 Usage     : 
 Purpose   : 
 Returns   : 
 Argument  : 
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub reverse_complement
  {
    my $self = shift;
    my $seq = shift;# || $self->genomic_sequence;
    my $rcseq = reverse($seq);
    $rcseq =~ tr/ATCGatcg/TAGCtagc/; 
    return $rcseq;
  }

sub distinct_feature_type_ids
  {
    my $self = shift;
    my %opts = @_;
    my $type = $opts{type}; #not used. . .
    my @ids;
    foreach my $id ($self->features({},
			       {
				select=>[{distinct=>"me.feature_type_id"}],
				as=>["feature_type_id"],
			       }))
      {
	print STDERR $id,"\n";;
      }
    return wantarray ? @ids : \@ids;
  }

1;
