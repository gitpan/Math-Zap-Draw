#!perl -w
#_ Cube _______________________________________________________________
# Cubes in 3d space    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Cube;
$VERSION=1.03;
use Math::Zap::Unique;
use Math::Zap::Triangle;
use Math::Zap::Vector;
use Carp;

#_ Cube _______________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(cube);

#_ Cube _______________________________________________________________
# Check its a cube
#______________________________________________________________________

sub check(@)
 {for my $c(@_)
   {confess "$c is not a cube" unless ref($c) eq __PACKAGE__;
   }
  return (@_)
 }

#_ Cube _______________________________________________________________
# Test its a cube     
#______________________________________________________________________

sub is(@)
 {for my $r(@_)
   {return 0 unless ref($r) eq __PACKAGE__;
   }
  'cube';
 }

#_ Cube _______________________________________________________________
# Create a rectangle from 3 vectors:
# a position of any corner
# x first side
# y second side.
# z third side.
#______________________________________________________________________

sub new($$$$)
 {my ($a, $x, $y, $z) = Math::Zap::Vector::check(@_);
  bless {a=>$a, x=>$x, y=>$y, z=>$z}; 
 }

sub cube($$$$) {new($_[0], $_[1], $_[2], $_[3])};

#_ Cube _______________________________________________________________
# Components of cube
#______________________________________________________________________

sub a($) {my ($c) = check(@_); $c->{a}}
sub x($) {my ($c) = check(@_); $c->{x}}
sub y($) {my ($c) = check(@_); $c->{y}}
sub z($) {my ($c) = check(@_); $c->{z}}

#_ Cube _______________________________________________________________
# Create a cube from another cube
#______________________________________________________________________

sub clone($)
 {my ($c) = check(@_); # Cube
  bless {a=>$c->a, x=>$c->x, y=>$c->y, z=>$c->z};
 }

#_ Cube _______________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Cube _______________________________________________________________
# Unit cube                   
#______________________________________________________________________

sub unit()
 {cube(vector(0,0,0), vector(1,0,0), vector(0,1,0), vector(0,0,1));
 }

#_ Cube _______________________________________________________________
# Add a vector to a cube                   
#______________________________________________________________________

sub add($$)
 {my ($c) =         check(@_[0..0]); # Cube       
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector     
  new($c->a+$v, $c->x, $c->y, $c->z);                         
 }

#_ Cube _______________________________________________________________
# Subtract a vector from a cube                   
#______________________________________________________________________

sub subtract($$)
 {my ($c) =         check(@_[0..0]); # Cube       
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector     
  new($c->a-$v, $c->x, $c->y, $c->z);                         
 }

#_ Cube _______________________________________________________________
# Cube times a scalar
#______________________________________________________________________

sub multiply($$)
 {my ($a) = check(@_[0..0]); # Cube   
  my ($b) =       @_[1..1];  # Scalar
  
  new($a->a, $a->x*$b, $a->y*$b, $a->z*$b);
 }

#_ Cube _______________________________________________________________
# Cube divided by a non zero scalar
#______________________________________________________________________

sub divide($$)
 {my ($a) = check(@_[0..0]); # Cube   
  my ($b) =       @_[1..1];  # Scalar
  
  confess "$b is zero" if $b == 0;
  new($a->a, $a->x/$b, $a->y/$b, $a->z/$b);
 }

#_ Cube _______________________________________________________________
# Print cube     
#______________________________________________________________________

sub print($)
 {my ($t) = check(@_); # Cube       
  my ($a, $x, $y, $z) = ($t->a, $t->x, $t->y, $t->z);
  "cube($a, $x, $y, $z)";
 }

#_ Cube _______________________________________________________________
# Triangulate
#______________________________________________________________________

sub triangulate($$)
 {my ($c)     = check(@_[0..0]); # Cube
  my ($color) =       @_[1..1];  # Color           
  my  $plane;                    # Plane    
   
  my @t;
  $plane = Math::Zap::Unique::new();           
  push @t, {triangle=>triangle($c->a,                   $c->a+$c->x,       $c->a+$c->y),       color=>$color, plane=>$plane};
  push @t, {triangle=>triangle($c->a+$c->x+$c->y,       $c->a+$c->x,       $c->a+$c->y),       color=>$color, plane=>$plane};
  $plane = Math::Zap::Unique::new();           
  push @t, {triangle=>triangle($c->a+$c->z,             $c->a+$c->x+$c->z, $c->a+$c->y+$c->z), color=>$color, plane=>$plane};
  push @t, {triangle=>triangle($c->a+$c->x+$c->y+$c->z, $c->a+$c->x+$c->z, $c->a+$c->y+$c->z), color=>$color, plane=>$plane};

# x y z 
# y z x
  $plane = Math::Zap::Unique::new();           
  push @t, {triangle=>triangle($c->a,                   $c->a+$c->y,       $c->a+$c->z),       color=>$color, plane=>$plane};
  push @t, {triangle=>triangle($c->a+$c->y+$c->z,       $c->a+$c->y,       $c->a+$c->z),       color=>$color, plane=>$plane};
  $plane = Math::Zap::Unique::new();           
  push @t, {triangle=>triangle($c->a+$c->x,             $c->a+$c->y+$c->x, $c->a+$c->z+$c->x), color=>$color, plane=>$plane};
  push @t, {triangle=>triangle($c->a+$c->y+$c->z+$c->x, $c->a+$c->y+$c->x, $c->a+$c->z+$c->x), color=>$color, plane=>$plane};

# x y z 
# z x y
  $plane = Math::Zap::Unique::new();           
  push @t, {triangle=>triangle($c->a,                   $c->a+$c->z,       $c->a+$c->x),       color=>$color, plane=>$plane};
  push @t, {triangle=>triangle($c->a+$c->z+$c->x,       $c->a+$c->z,       $c->a+$c->x),       color=>$color, plane=>$plane};
  $plane = Math::Zap::Unique::new();           
  push @t, {triangle=>triangle($c->a+$c->y,             $c->a+$c->z+$c->y, $c->a+$c->x+$c->y), color=>$color, plane=>$plane};
  push @t, {triangle=>triangle($c->a+$c->z+$c->x+$c->y, $c->a+$c->z+$c->y, $c->a+$c->x+$c->y), color=>$color, plane=>$plane};
  @t;
 }

unless (caller())
 {$c = cube(vector(0,0,0), vector(1,0,0), vector(0,1,0), vector(0,0,1));
  @t = $c->triangulate('red');
  print "Done";
 }

#_ Cube _______________________________________________________________
# Operator overloads
#______________________________________________________________________

use overload
 '+',       => \&add3,      # Add a vector
 '-',       => \&sub3,      # Subtract a vector
 '*',       => \&multiply3, # Multiply by scalar
 '/',       => \&divide3,   # Divide by scalar 
 '=='       => \&equals3,   # Equals
 '""'       => \&print3,    # Print
 'fallback' => FALSE;

#_ Cube _______________________________________________________________
# Add operator.
#______________________________________________________________________

sub add3
 {my ($a, $b, $c) = @_;
  return $a->add($b);
 }

#_ Cube _______________________________________________________________
# Subtract operator.
#______________________________________________________________________

sub sub3
 {my ($a, $b, $c) = @_;
  return $a->subtract($b);
 }

#_ Cube _______________________________________________________________
# Multiply operator.
#______________________________________________________________________

sub multiply3
 {my ($a, $b) = @_;
  return $a->multiply($b);
 }

#_ Cube _______________________________________________________________
# Divide operator.
#______________________________________________________________________

sub divide3
 {my ($a, $b, $c) = @_;
  return $a->divide($b);
 }

#_ Cube _______________________________________________________________
# Equals operator.
#______________________________________________________________________

sub equals3
 {my ($a, $b, $c) = @_;
  return $a->equals($b);
 }

#_ Cube _______________________________________________________________
# Print a cube
#______________________________________________________________________

sub print3
 {my ($a) = @_;
  return $a->print;
 }

#_ Cube _______________________________________________________________
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

