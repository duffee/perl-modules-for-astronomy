package Astro::ADS::Result::Paper;

# ---------------------------------------------------------------------------

#+ 
#  Name:
#    Astro::ADS::Result:;Paper

#  Purposes:
#    Perl wrapper for the ADS database

#  Language:
#    Perl module

#  Description:
#    This module wraps the ADS online database.

#  Authors:
#    Alasdair Allan (aa@astro.ex.ac.uk)

#  Revision:
#     $Id: Paper.pm,v 1.7 2001/11/02 01:59:30 aa Exp $

#  Copyright:
#     Copyright (C) 2001 University of Exeter. All Rights Reserved.

#-

# ---------------------------------------------------------------------------

=head1 NAME

Astro::ADS::Result::Paper - A individual paper in an Astro::ADS::Result object

=head1 SYNOPSIS

  $paper = new Astro::ADS::Result::Paper( Bibcode   => $bibcode,
                                          Title     => $title,
                                          Authors   => \@authors,
                                          Affil     => \@affil,
                                          Journal   => $journal_refernce,
                                          Published => $published,
                                          Keywords  => \@keywords,
                                          Origin    => $journal,
                                          Links     => \@associated_links,
                                          URL       => $abstract_url,
                                          Abstract  => \@abstract,
                                          Object    => $object );

  $bibcode = $paper->bibcode();
  @authors = $paper->authors();

=head1 DESCRIPTION

Stores meta-data about an individual paper in the Astro::ADS::Result object
returned by an Astro::ADS::Query object.

=cut

# L O A D   M O D U L E S --------------------------------------------------

use strict;
use vars qw/ $VERSION /;


'$Revision: 1.7 $ ' =~ /.*:\s(.*)\s\$/ && ($VERSION = $1);

# C O N S T R U C T O R ----------------------------------------------------

=head1 REVISION

$Id: Paper.pm,v 1.7 2001/11/02 01:59:30 aa Exp $

=head1 METHODS

=head2 Constructor

=over 4

=item B<new>

Create a new instance from a hash of options

  $paper = new Astro::ADS::Result::Paper( Bibcode   => $bibcode,
                                          Title     => $title,
                                          Authors   => \@authors,
                                          Affil     => \@affil,
                                          Journal   => $journal_refernce,
                                          Published => $published,
                                          Keywords  => \@keywords,
                                          Origin    => $journal,
                                          Links     => \@outbound_links,
                                          URL       => $abstract_url,
                                          Abstract  => \@abstract,
                                          Object    => $object  );

returns a reference to an ADS paper object.

=cut

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;

  # bless the query hash into the class
  my $block = bless { BIBCODE   => undef,
                      TITLE     => undef,
                      AUTHORS   => [],
                      AFFIL     => [],
                      JOURNAL   => undef,
                      PUBLISHED => undef,
                      KEYWORDS  => [],
                      ORIGIN    => undef,
                      LINKS     => [],
                      URL       => undef,
                      ABSTRACT  => [],
                      OBJECT    => undef }, $class;

  # If we have arguments configure the object
  $block->configure( @_ ) if @_;

  return $block;

} 

# A C C E S S O R  --------------------------------------------------------

=back

=head2 Accessor Methods

=over 4

=item B<bibcode>

Return (or set) the bibcode for the paper

   $bibcode = $paper->bibcode();
   $paper->bibcode( $bibcode );

=cut

sub bibcode {
  my $self = shift;
  if (@_) { 
    $self->{BIBCODE} = shift;
  }
  return $self->{BIBCODE};
}

=item B<Title>

Return (or set) the title for the paper

   $title = $paper->title();
   $paper->title( $title );

=cut

sub title {
  my $self = shift;
  if (@_) { 
    $self->{TITLE} = shift;
  }
  return $self->{TITLE};
}

=item B<Authors>

Return (or set) the authors for the paper

   @authors = $paper->authors();
   $first_author = $paper->authors();
   $paper->authors( \@authors );

if called in a scalar context it will return the first author.

=cut

sub authors {
  my $self = shift;
  if (@_) { 
    $self->{AUTHORS} = shift;
  }  
  my @authors = @{$self->{AUTHORS}};
  return wantarray ? @authors : $authors[0];
}

=item B<Affil>

Return (or set) the affiliation of each author for the paper

   @institutions = $paper->affil();
   $first_author_inst = $paper->affil();
   $paper->affil( \@institutions );

if called in a scalar context it will return the affiliation of the
first author.

=cut

sub affil {
  my $self = shift;
  if (@_) { 
    $self->{AFFIL} = shift;
  }
  my @affil = @{$self->{AFFIL}};
  return wantarray ? @affil : $affil[0];;
}

=item B<Journal>

Return (or set) the journal reference for the paper

   $journal_ref = $paper->journal();
   $paper->journal( $journal_ref );

=cut

sub journal {
  my $self = shift;
  if (@_) { 
    $self->{JOURNAL} = shift;
  }
  return $self->{JOURNAL};
}

=item B<Published>

Return (or set) the month and year when the paper was published.

   $published = $paper->published();
   $paper->published( $published );

=cut

sub published {
  my $self = shift;
  if (@_) { 
    $self->{PUBLISHED} = shift;
  }
  return $self->{PUBLISHED};
}

=item B<Links>

Return (or set) the different keywords the paper is indexed by, could
include such keys as ACCRETION DISCS, WHITE DWARFS, etc.

   @keywords = $paper->keywords();
   $paper->keywords( \@keywords );

if called in a scalar context it will return the number of keywords.

=cut

sub keywords {
  my $self = shift;
  if (@_) { 
    $self->{KEYWORDS} = shift;
  }
  return wantarray ? @{$self->{KEYWORDS}} : $#{$self->{KEYWORDS}};
}

=item B<Origin>

Return (or set) the origin of the paper in the ADS archive, this is not
necessarily the journal in which the paper was published, but could be
set to AUTHOR, ADS or SIMBAD for instance.

   $source = $paper->origin();
   $paper->origin( $source );

=cut

sub origin {
  my $self = shift;
  if (@_) { 
    $self->{ORIGIN} = shift;
  }
  return $self->{ORIGIN};
}

=item B<Links>

Return (or set) the different type of outbounds links offered by ADS for this
paper, examples include ABSTRACT, EJOURNAL, ARTICLE, REFERENCES, CITATIONS,
SIMBAD objects etc.

   @outbound_links = $paper->links();
   $paper->links( \@outbound_links );

if called in a scalar context it will return the number of outbound links
available.

=cut

sub links {
  my $self = shift;
  if (@_) { 
    $self->{LINKS} = shift;
  }
  return wantarray ? @{$self->{LINKS}} : $#{$self->{LINKS}};
}

=item B<URL>

Return (or set) the URL pointing to the paper at the ADS

   $adsurl = $paper->url();
   $paper->url( $adsurl );

=cut

sub url {
  my $self = shift;
  if (@_) { 
    $self->{URL} = shift;
  }
  return $self->{URL};
}

=item B<Abstract>

Return (or set) the abstract of the paper, this may be either the full text
of the abstract, or a URL pointing to the scanned abstract at the ADS.

   @abstract = $paper->abstract();
   $paper->abstract( @abstract );

if called in a scalar context it will return the number of lines of text in
the abstract.

=cut

sub abstract {
  my $self = shift;
  if (@_) { 
    $self->{ABSTRACT} = shift;
  }
  return wantarray ? @{$self->{ABSTRACT}} : $#{$self->{ABSTRACT}};
}

=item B<object>

Return (or set) the object tag for the paper.

   $object = $paper->object();
   $paper->object( $object );

=cut

sub object {
  my $self = shift;
  if (@_) { 
    $self->{OBJECT} = shift;
  }
  return $self->{OBJECT};
}

# F O L L O W U P   M E T H O D S ---------------------------------------

=back

=head2 Followup Queries

=over 4

=item B<references>

Returns an Astro::ADS::Result object containing the references for the paper.

   $result = $paper->references();

returns undef if this external link type is not available for this paper.

=cut

sub references {
  my $self = shift;
  
  # check to see if link is defined
  my $flag = undef;
  for my $i ( 0 ... $#{$self->{LINKS}} ) {
     $flag = 1 if ${$self->{LINKS}}[$i] eq "REFERENCES";
  }
  
  # return if keyword has not been flagged
  return undef unless defined $flag;
  
  # grab the bibcode of the paper  
  my $bibcode = $self->{BIBCODE};
  
  # build a query object
  my $query = new Astro::ADS::Query();
                                      
  return $query->followup( $bibcode, "REFERENCES" );
}

=item B<citations>

Returns an Astro::ADS::Result object containing the citations for the paper.

   $result = $paper->citations();

returns undef if this external link type is not available for this paper.

=cut

sub citations {
  my $self = shift;
  
  # check to see if link is defined
  my $flag = undef;
  for my $i ( 0 ... $#{$self->{LINKS}} ) {
     $flag = 1 if ${$self->{LINKS}}[$i] eq "CITATIONS";
  }
  
  # return if keyword has not been flagged
  return undef unless defined $flag;
    
  # grab the bibcode of the paper  
  my $bibcode = $self->{BIBCODE};
  
  # build a query object
  my $query = new Astro::ADS::Query();
                                      
  return $query->followup( $bibcode, "CITATIONS" );
}

=item B<alsoread>

Returns an Astro::ADS::Result object containing papers which were `also
read' along with this paper.

   $result = $paper->alsoread();

returns undef if this external link type is not available for this paper.

=cut

sub alsoread {
  my $self = shift;
  
  # check to see if link is defined
  my $flag = undef;
  for my $i ( 0 ... $#{$self->{LINKS}} ) {
     $flag = 1 if ${$self->{LINKS}}[$i] eq "AR";
  }
  
  # return if keyword has not been flagged
  return undef unless defined $flag;
   
  # grab the bibcode of the paper  
  my $bibcode = $self->{BIBCODE};
  
  # build a query object
  my $query = new Astro::ADS::Query();
                                      
  return $query->followup( $bibcode, "AR" );
}


=item B<tableofcontents>

Returns an Astro::ADS::Result object containingteh table of contents of
the journal or proceedings.

   $result = $paper->tableofcontents();

returns undef if this external link type is not available for this paper.

=cut

sub tableofcontents {
  my $self = shift;
  
  # check to see if link is defined
  my $flag = undef;
  for my $i ( 0 ... $#{$self->{LINKS}} ) {
     $flag = 1 if ${$self->{LINKS}}[$i] eq "TOC";
  }
  
  # return if keyword has not been flagged
  return undef unless defined $flag;
   
  # grab the bibcode of the paper  
  my $bibcode = $self->{BIBCODE};
  
  # build a query object
  my $query = new Astro::ADS::Query();
                                      
  return $query->followup( $bibcode, "TOC" );
}

# C O N F I G U R E -------------------------------------------------------

=back

=head2 General Methods

=over 4

=item B<configure>

Configures the object from multiple pieces of information.

  $paper->configure( %options );

Takes a hash as argument with the following keywords:

=over 4

=item B<Bibcode>

The bibcode of the paper. A complete description of the bibcode reference 
coding has been published as a chapter of the book "Information & On-Line 
Data in Astronomy", 1995, D. Egret and M. A. Albrecht (Eds), Kluwer Acad. Publ.

A copy of the relevant chapter in this book is available online as a Postscript
file via the CDS at http://cdsweb.u-strasbg.fr/simbad/refcode.ps 

=item B<Title>

The title of the paper.

=item B<Authors>

The authors of the paper.

=item B<Affil>

Institute affiliations associated with each author.

=item B<Journal>

The journal reference for the paper, e.g. MNRAS, 279, 1345-1348 (1996)

=item B<Published>

Month and year published, e.g. 4/1996

=item B<Keywords>

Keywords for the paper, e.g. ACCRETION DISCS

=item B<Origin>

Origin of citation in ADS archive, this is not necessarily the journal, the
origin of the entry could be AUTHOR, or ADS or SIMBAD for instance.

=item B<Links>

Available type of links relating to the paper, e.g. SIMBAD objects mentioned
in the paper, References, Citations, Table of Contents of the Journal etc.

=item B<URL>

URL of the ADS page of the paper

=item B<Abstract>

Either the abstract text or a URL of the scanned abstract (for older papers).

=back

Does nothing if these keys are not supplied.

=cut

sub configure {
  my $self = shift;

  # return unless we have arguments
  return undef unless @_;

  # grab the argument list
  my %args = @_;

  # Loop over the allowed keys storing the values
  # in the object if they exist  
  for my $key (qw / Bibcode Title Authors Affil Journal Published
                    Keywords Origin Links URL Abstract Object /) {
      my $method = lc($key);
      $self->$method( $args{$key} ) if exists $args{$key};
  }  

}

# T I M E   A T   T H E   B A R  --------------------------------------------

=back

=end __PRIVATE_METHODS__

=head1 COPYRIGHT

Copyright (C) 2001 University of Exeter. All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Public License.

=head1 AUTHORS

Alasdair Allan E<lt>aa@astro.ex.ac.ukE<gt>,

=cut

# L A S T  O R D E R S ------------------------------------------------------

1;                                                                  
