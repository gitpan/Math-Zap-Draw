#!perl -w
#_ Vector _____________________________________________________________
# 3 dimensional vectors: via operator overloading    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Vector; 
$VERSION=1.03;
use Math::Trig;
use Carp;
use constant debug => 0; # Debugging level

#_ Vector _____________________________________________________________
# Exports
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(vector);

#_ Vector _____________________________________________________________
# Check its a vector
#______________________________________________________________________

sub check(@)
 {if (debug)
   {for my $v(@_)
     {confess "$v is not a vector" unless ref($v) eq __PACKAGE__;
     }
   }
  return (@_)
 }

#_ Vector _____________________________________________________________
# Test its a vector
#______________________________________________________________________

sub is(@)
 {for my $v(@_)
   {return 0 unless ref($v) eq __PACKAGE__;
   }
  'vector';
 }

#_ Vector _____________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Vector _____________________________________________________________
# Round: round to nearest integer if within accuracy of that integer 
#______________________________________________________________________

sub round($)
 {unless (debug)
   {return $_[0];
   }
  else
   {my ($a) = @_;
    for my $k(keys(%$a))
     {my $n = $a->{$k};
      my $N = int($n);
      $a->{$k} = $N if abs($n-$N) < $accuracy;
     }
    return $a;
   }
 }

#_ Vector _____________________________________________________________
# Create a vector from numbers
#______________________________________________________________________

sub new($$$)
 {return round bless {x=>$_[0], y=>$_[1], z=>$_[2]} if debug; 
  bless {x=>$_[0], y=>$_[1], z=>$_[2]}; 
 }

sub vector($$$) {new($_[0], $_[1], $_[2])}

#_ Vector _____________________________________________________________
# x,y,z components of vector
#______________________________________________________________________

$x = new(1,0,0);
$y = new(0,1,0);
$z = new(0,0,1);

sub x($) {check(@_) if debug; $_[0]->{x}}
sub y($) {check(@_) if debug; $_[0]->{y}}
sub z($) {check(@_) if debug; $_[0]->{z}}

sub units() {($x, $y, $z)}

#_ Vector _____________________________________________________________
# Create a vector from another vector
#______________________________________________________________________

sub clone($)
 {my ($v) = check(@_); # Vectors
  round bless {x=>$v->x, y=>$v->y, z=>$v->z}; 
 }

#_ Vector _____________________________________________________________
# Length of a vector
#______________________________________________________________________

sub length($)
 {my ($v) = check(@_[0..0]); # Vectors
  sqrt($v->x**2+$v->y**2+$v->z**2);
 } 

#_ Vector _____________________________________________________________
# Print vector
#______________________________________________________________________

sub print($)
 {my ($v) = check(@_); # Vectors
  my ($x, $y, $z) = ($v->x, $v->y, $v->z);

  "vector($x, $y, $z)";
 } 

#_ Vector _____________________________________________________________
# Normalize vector
#______________________________________________________________________

sub norm($)
 {my ($v) = check(@_); # Vectors
     $v = $v->clone;   # Copy vector
  my $l = $v->length;

  $l > 0 or confess "Cannot normalize zero length vector $v";

  $v->{x} /= $l;
  $v->{y} /= $l;
  $v->{z} /= $l;
  $v;
 } 

#_ Vector _____________________________________________________________
# Dot product
#______________________________________________________________________

sub dot($$)
 {my ($a, $b) = check(@_); # Vectors
  $a->x*$b->x+$a->y*$b->y+$a->z*$b->z;
 } 

#_ Vector _____________________________________________________________
# Angle between two vectors
#______________________________________________________________________

sub angle($$)
 {my ($a, $b) = check(@_); # Vectors
  acos($a->norm->dot($b->norm));
 } 

#_ Vector _____________________________________________________________
# Cross product
#______________________________________________________________________

sub cross($$)
 {my ($a, $b) = check(@_); # Vectors

	new
  ((($a->y * $b->z) - ($a->z * $b->y)),
	 (($a->z * $b->x) - ($a->x * $b->z)),
	 (($a->x * $b->y) - ($a->y * $b->x))
  );
 }

#_ Vector _____________________________________________________________
# Add vectors
#______________________________________________________________________

sub add($$)
 {my ($a, $b) = check(@_); # Vectors
  new($a->x+$b->x, $a->y+$b->y, $a->z+$b->z);
 }

#_ Vector _____________________________________________________________
# Subtract vectors
#______________________________________________________________________

sub subtract($$)
 {check(@_) if debug; # Vectors
  new($_[0]->{x}-$_[1]->{x}, $_[0]->{y}-$_[1]->{y}, $_[0]->{z}-$_[1]->{z});
 }

#_ Vector _____________________________________________________________
# Vector times a scalar
#______________________________________________________________________

sub multiply($$)
 {my ($a) = check(@_[0..0]); # Vector 
  my ($b) =       @_[1..1];  # Scalar
  
  confess "$b is not a scalar" if ref($b);
  new($a->x*$b, $a->y*$b, $a->z*$b);
 }

#_ Vector _____________________________________________________________
# Vector divided by a non zero scalar
#______________________________________________________________________

sub divide($$)
 {my ($a) = check(@_[0..0]); # Vector 
  my ($b) =       @_[1..1];  # Scalar

  confess "$b is not a scalar" if ref($b);
  confess "$b is zero"         if $b == 0;
  new($a->x/$b, $a->y/$b, $a->z/$b);
 }

#_ Vector _____________________________________________________________
# Equals to within accuracy
#______________________________________________________________________

sub equals($$)
 {my ($a, $b) = check(@_); # Vectors
  abs($a->x-$b->x) < $accuracy and
  abs($a->y-$b->y) < $accuracy and
  abs($a->z-$b->z) < $accuracy;
 }

#_ Vector _____________________________________________________________
# Operator overloads
#______________________________________________________________________

use overload
 '+'        => \&add3,      # Add two vectors
 '-'        => \&subtract3, # Subtract one vector from another
 '*'        => \&multiply3, # Times by a scalar, or vector dot product 
 '/'        => \&divide3,   # Divide by a scalar
 'x'        => \&cross3,    # BEWARE LOW PRIORITY! Cross product
 '<'        => \&angle3,    # Angle in radians between two vectors
 '>'        => \&angle3,    # Angle in radians between two vectors
 '=='       => \&equals3,   # Equals
 '""'       => \&print3,    # Print
 '!'        => \&length,    # Length
 'fallback' => FALSE;

#_ Vector _____________________________________________________________
# Add operator.
#______________________________________________________________________

sub add3
 {my ($a, $b) = @_;
  $a->add($b);
 }

#_ Vector _____________________________________________________________
# Negate operator.
#______________________________________________________________________

sub subtract3
 {return new($_[0]->{x}-$_[1]->{x}, $_[0]->{y}-$_[1]->{y}, $_[0]->{z}-$_[1]->{z}) if ref($_[1]);
# my ($a, $b, $c) = @_;
#
# return $a->subtract($b) if ref($b);
  new(-$_[0]->{x}, -$_[0]->{y}, -$_[0]->{z});
 }

#_ Vector _____________________________________________________________
# Multiply operator.
#______________________________________________________________________

sub multiply3
 {my ($a, $b) = @_;
  return $a->dot     ($b) if ref($b);
  return $a->multiply($b);
 }

#_ Vector _____________________________________________________________
# Divide operator.
#______________________________________________________________________

sub divide3
 {my ($a, $b, $c) = @_;
  return $a->divide($b);
 }

#_ Vector _____________________________________________________________
# Cross operator.
#______________________________________________________________________

sub cross3
 {my ($a, $b, $c) = @_;
  return $a->cross($b);
 }

#_ Vector _____________________________________________________________
# Angle between two vectors.
#______________________________________________________________________

sub angle3
 {my ($a, $b, $c) = @_;
  return $a->angle($b);
 }

#_ Vector _____________________________________________________________
# Equals operator.
#______________________________________________________________________

sub equals3
 {my ($a, $b, $c) = @_;
  return $a->equals($b);
 }

#_ Vector _____________________________________________________________
# Print a vector.
#______________________________________________________________________

sub print3
 {my ($a) = @_;
  return $a->print;
 }

#_ Vector _____________________________________________________________
# Package loaded successfully
#______________________________________________________________________

1;
__DATA__

#______________________________________________________________________
# User guide.
#______________________________________________________________________

=head1 NAME

Math::Zap::Draw - supplies methods to draw a scene, containing three
dimensional objects, as a two dimensional image, using lighting and
shadowing to assist the human observer in reconstructing the original
three dimensional scene.

 #!perl -w
 #______________________________________________________________________
 # Draw cube floating against triangular corner in 3d with shadows.
 # Perl License.
 # PhilipRBrenan@yahoo.com, 2004.
 #______________________________________________________________________ 

 use Math::Zap::Draw;
 use Math::Zap::Color;
 use Math::Zap::Cube;
 use Math::Zap::Triangle;
 use Math::Zap::Vector;

 #_ Draw _______________________________________________________________
 # Draw this set of objects.
 #______________________________________________________________________

 draw 
   ->from    (vector( 10,   10,  10))
   ->to      (vector(  0,    0,   0))
   ->horizon (vector(  1,  0.5,   0))
   ->light   (vector( 20,   30, -20))

     ->object(triangle(vector( 0,  0,  0), vector( 8,  0,  0), vector( 0,  8,  0)),                         'red')
     ->object(triangle(vector( 0,  0,  0), vector( 0,  0,  8), vector( 0,  8,  0)),                         'green')
     ->object(triangle(vector( 0,  0,  0), vector(12,  0,  0), vector( 0,  0, 12)) - vector(2.5,  0,  2.5), 'blue')
     ->object(triangle(vector( 0,  0,  0), vector( 8,  0,  0), vector( 0, -8,  0)),                         'pink')
     ->object(triangle(vector( 0,  0,  0), vector( 0,  0,  8), vector( 0, -8,  0)),                         'orange')
     ->object(Math::Zap::Cube::unit()*2+vector(3,5,1), 'lightblue')

 ->done; 


=head1 DESCRIPTION

This package supplies methods to draw a scene, containing three dimensional
objects, as a two dimensional image, using lighting and shadowing to assist the
human observer in reconstructing the original three dimensional scene.

There are many existing packages to perform this important task: this
package is the only one to make the attempt in Pure Perl. Pending the
power of Petaflop Parallel Perl (when we will be set free from C), this
approach is slow. However, it is not so slow as to be completely useless
for simple scenes as might be encountered inside, say for instance, beam
lines used in high energy particle physics, the owners of which often
have large Perl computers.

The key advantage of this package is that is open: you can manipulate
both the objects to be drawn and the drawing itself all in Pure Perl.

=head1 AUTHOR

Philip R Brenan at B<philiprbrenan@yahoo.com>

=cut

