#!perl -w
#_ Rectangle __________________________________________________________
# Rectangles in 3d space    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Rectangle;
$VERSION=1.03;
use Math::Zap::Vector;
use Math::Zap::Matrix;
use Carp;

#_ Rectangle __________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(rectangle);

#_ Rectangle __________________________________________________________
# Check its a rectangle
#______________________________________________________________________

sub check(@)
 {for my $r(@_)
   {confess "$r is not a rectangle" unless ref($r) eq __PACKAGE__;
   }
  return (@_)
 }

#_ Rectangle __________________________________________________________
# Test its a rectangle
#______________________________________________________________________

sub is(@)
 {for my $r(@_)
   {return 0 unless ref($r) eq __PACKAGE__;
   }
  'rectangle';
 }

#_ Rectangle __________________________________________________________
# Create a rectangle from 3 vectors:
# a position of any corner
# b first side
# c second side.
# Note that vectors b,c must be at right angles to each other.
#______________________________________________________________________

sub new($$$)
 {my ($a, $b, $c) = Math::Zap::Vector::check(@_);
  $b->dot($c) == 0 or confess 'non rectangular rectangle specified';
  bless {a=>$a, b=>$b, c=>$c}; 
 }

sub rectangle($$$) {new($_[0],$_[1],$_[2])};

#_ Rectangle __________________________________________________________
# Components of rectangle
#______________________________________________________________________

sub a($) {my ($r) = check(@_); $r->{a}}
sub b($) {my ($r) = check(@_); $r->{b}}
sub c($) {my ($r) = check(@_); $r->{c}}

#_ Rectangle __________________________________________________________
# Create a rectangle from another rectangle
#______________________________________________________________________

sub clone($)
 {my ($r) = check(@_); # Rectangles
  bless {a=>$r->a, b=>$r->b, c=>$r->c};
 }

#_ Rectangle __________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Rectangle __________________________________________________________
# Intersect line between two vectors with plane defined by a rectangle
# r rectangle
# a start vector
# b end vector
# Solve the simultaneous equations of the plane defined by the
# rectangle and the line between the vectors:
#   ra+l*rb+m*rc         = a+(b-a)*n 
# =>ra+l*rb+m*rc+n*(a-b) = a-ra 
# Note:  no checks (yet) for line parallel to plane.
#______________________________________________________________________

sub intersection($$$)
 {my ($r)     =         check(@_[0..0]); # Rectangles
  my ($a, $b) = Math::Zap::Vector::check(@_[1..2]); # Vectors
   
  $s = Math::Zap::Matrix::new3v($r->b, $r->c, $a-$b)/($a-$r->a);
 } 

#_ Rectangle __________________________________________________________
# Test whether a line between two vectors intersects a rectangle
# Note:  no checks (yet) for line parallel to plane.
#______________________________________________________________________

sub intersects($$$)
 {my ($r)     =         check(@_[0..0]); # Rectangles
  my ($a, $b) = Math::Zap::Vector::check(@_[1..2]); # Vectors
   
  my $s = $r->intersection($a, $b);
  return 1 if $s->x >=0 and $s->x < 1 and
              $s->y >=0 and $s->y < 1 and
              $s->z >=0 and $s->z < 1;
  0;
 } 

#_ Rectangle __________________________________________________________
# Visibility of a rectangle r hid by other rectangles R from a view
# point p.
# Rectangle r is divided up into I*J sub rectangles: each sub rectangle
# is tested for visibility from point p via the intervening rectangles.
#______________________________________________________________________

sub visible($$@)
 {my ($p)     = Math::Zap::Vector::check(@_[0.. 0]);    # Vector
  my ($I, $J) =              (@_[1.. 2]);    # Number of divisions  
  my ($r, @R) =         check(@_[3..scalar(@_)-1]);  # Rectangles

  my $v;
  $v->{r} = $r;                              # Save rectangle data
  $v->{I} = $I;                              # 
  $v->{J} = $J;                              #

  for      my $i(1..$I)                      # Along one edge
   {L: for my $j(1..$J)                      # Along the other edge
     {my $c = $r->a+($r->b)*(($i-1/2)/$I)    # Test point
                   +($r->c)*(($j-1/2)/$J);
      
      for my $R(@R)                          # Each intervening rectangle
       {my ($x, $y, $z) = ($c->x, $c->y, $c->z);
        my $in = $R->intersects($p, $c);
        next L if $in;                       # Solid, intersected
       }
      $v->{v}{$i}{$j} = 1;
     }
   }
  $v;
 } 

#_ Rectangle __________________________________________________________
# Project rectangle r onto rectangle R from a point p
#______________________________________________________________________

sub project($$$)
 {my ($p)     = Math::Zap::Vector::check(@_[0.. 0]);    # Vector
  my ($r, $R) =              (@_[1.. 2]);    # Rectangles           
   
  my $A = $r->a;                             # Main  corner of r
  my $B = $r->a+$r->b;                       # One   corner of r
  my $C = $r->a+$r->c;                       # Other corner of r

  my $a = $R->intersection($p, $A);          # Main  corner of r on R
  my $b = $R->intersection($p, $B);          # One   corner of r on R
  my $c = $R->intersection($p, $C);          # Other corner of r on R

  $aR = $p+($A-$p)*$a->z;                    # Coordinates of main  corner of r on R
  $bR = $p+($B-$p)*$b->z;                    # Coordinates of one   corner of r on R
  $cR = $p+($C-$p)*$c->z;                    # Coordinates of other corner of r on R
  print "a=$aR\n";
  print "b=$bR\n";
  print "c=$cR\n";

  rectangle($aR, $bR, $cR);
 } 

#_ Rectangle __________________________________________________________
# Project rectangle r into rectangle R from a point p
#______________________________________________________________________

sub projectInto($$$)
 {my ($r, $R) =              (@_[0..1]);    # Rectangles           
  my ($p)     = Math::Zap::Vector::check(@_[2..2]);    # Vector
   
  my $A = $r->a;                             # Main     corner of r
  my $B = $r->a+$r->b;                       # One      corner of r
  my $C = $r->a+$r->c;                       # Other    corner of r
  my $D = $r->a+$r->b+$r->c;                 # Opposite corner of r

  my $a = $R->intersection($p, $A);          # Main     corner of r on R
  my $b = $R->intersection($p, $B);          # One      corner of r on R
  my $c = $R->intersection($p, $C);          # Other    corner of r on R
  my $d = $R->intersection($p, $D);          # Opposite corner of r on R

  ($a, $b, $d, $c);
 } 

#_ Rectangle __________________________________________________________
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

