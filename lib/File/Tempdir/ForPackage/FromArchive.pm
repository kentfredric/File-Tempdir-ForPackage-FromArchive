use strict;
use warnings;

package File::Tempdir::ForPackage::FromArchive;

# ABSTRACT: Inflate any archive to a temporary directory and work in it.

=head1 SYNOPSIS

 use File::Tempdir::ForPackage::FromArchive;

 my $stash = File::Tempdir::ForPackage::FromArchive->new(
  archive => 'path/to/archive.tar.gz',
 );
 while(1){
  $stash->run_once_in(sub{
   #  Disk thrashes here as
   #  archive is repeatedly checked out,
   #  modified, then erased.
  });
 }

=head1 DESCRIPTION

Most features of this module are provided by L<< File::Tempdir::C<ForPackage>|File::Tempdir::ForPackage >>, except that empty Tempdirs are constructed containing the contents of the specified archive with Archive-Any.

This is useful if you have some sort of mutable directory state that you need to bundle with your distribution for testing as a nested archive, and you don't want changes to persist between test runs.


=cut

use Moo;
use Sub::Quote qw( quote_sub );
extends 'File::Tempdir::ForPackage';

has archive => (
  is       => ro =>,
  required => 1,
  isa      => (
    ## no critic (RequireInterpolationOfMetachars)
    quote_sub q| if ( not -r -e $_[0] ){ | . q| die "archive is not readable: $_[0]"; | . q| }|
  ),
);

around _build__dir => sub {
  my ( $orig, $self, @rest ) = @_;
  require Archive::Any;
  my $dir = $orig->( $self, @rest );
  my $archive = Archive::Any->new( $self->archive );
  $archive->extract($dir);
  return $dir;
};

no Moo;

1;
