#!perl -w
#_ Triangle ___________________________________________________________
# Triangles in 3d space    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
# Definitions:
#   Space coordinates = 3d space
#   Plane coordinates = a triangle in 3d space defines a 2d plane
#     with a natural coordinate system:  the origin is the first point
#     of the triangle, the (x,y) units of this plane are the sides from
#     the triangles first point to its other points.   
#______________________________________________________________________

package Math::Zap::Triangle;
$VERSION=1.03;
use Math::Zap::Line2;
use Math::Zap::Unique;
use Math::Zap::Vector2;
use Math::Zap::Vector;
use Math::Zap::Matrix;
use Carp qw(cluck confess);
use constant debug => 0; # Debugging level

#_ Triangle ___________________________________________________________
# Exports
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(triangle);

#_ Triangle ___________________________________________________________
# Narrow (colinear) triangle?
#______________________________________________________________________

sub narrow($$)
 {my $t = shift;  # Triangle
  my $a = 1e-2;   # Accuracy
  my $A = shift;  # Action 0: return indicator, 1: confess 
  
  my $n = (($t->b-$t->a) x ($t->c-$t->a))->length < $a;
  
  confess "Narrow triangle" if $n and $A;
  $n;      
 }

#_ Triangle ___________________________________________________________
# Check its a triangle
#______________________________________________________________________

sub check(@)
 {if (debug)
   {for my $t(@_)
     {confess "$t is not a triangle" unless ref($t) eq __PACKAGE__;
     }
   } 
  return (@_)
 }

#_ Triangle ___________________________________________________________
# Test its a triangle
#______________________________________________________________________

sub is(@)
 {for my $t(@_)
   {return 0 unless ref($t) eq __PACKAGE__;
   }
  'triangle';
 }

#_ Triangle ___________________________________________________________
# Create a triangle from 3 vectors specifying the coordinates of each
# corner in space coordinates.
#______________________________________________________________________

sub new($$$)
 {my ($a, $b, $c) = Math::Zap::Vector::check(@_);
  my $t = bless {a=>$a, b=>$b, c=>$c};
  narrow($t, 1);
  $t; 
 }

sub triangle($$$) {new($_[0],$_[1],$_[2])};

#_ Triangle ___________________________________________________________
# Components of a triangle
#______________________________________________________________________

sub a($)   {check(@_) if debug; $_[0]->{a}}
sub b($)   {check(@_) if debug; $_[0]->{b}}
sub c($)   {check(@_) if debug; $_[0]->{c}}

sub ab($)  {check(@_) if debug; ($_[0]->{b}-$_[0]->{a})}
sub ac($)  {check(@_) if debug; ($_[0]->{c}-$_[0]->{a})}
sub ba($)  {check(@_) if debug; ($_[0]->{a}-$_[0]->{b})}
sub bc($)  {check(@_) if debug; ($_[0]->{c}-$_[0]->{b})}
sub ca($)  {check(@_) if debug; ($_[0]->{a}-$_[0]->{c})}
sub cb($)  {check(@_) if debug; ($_[0]->{b}-$_[0]->{c})}

sub abc($) {check(@_) if debug; ($_[0]->{a}, $_[0]->{b}, $_[0]->{c})}
sub area($){check(@_) if debug; ($_[0]->ab x $_[0]->ac)->length}

#_ Triangle ___________________________________________________________
# Create a triangle from another triangle 
#______________________________________________________________________

sub clone($)
 {my ($t) = check(@_); # Triangle   
  bless {a=>$t->a, b=>$t->b, c=>$t->c};
 }

#_ Triangle ___________________________________________________________
# Cyclically permute the points of a triangle
#______________________________________________________________________

sub permute($)
 {my ($t) = check(@_); # Triangle   
  bless {a=>$t->b, b=>$t->c, c=>$t->a};
 }

#_ Triangle ___________________________________________________________
# Center 
#______________________________________________________________________

sub center($)
 {my ($t) = check(@_); # Triangle   
  ($t->a + $t->b + $t->c) / 3;
 }

#_ Triangle ___________________________________________________________
# Add a vector to a triangle               
#______________________________________________________________________

sub add($$)
 {my ($t) =         check(@_[0..0]); # Triangle   
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector     
  new($t->a+$v, $t->b+$v, $t->c+$v);                         
 }

#_ Triangle ___________________________________________________________
# Subtract a vector from a triangle               
#______________________________________________________________________

sub subtract($$)
 {my ($t) =         check(@_[0..0]); # Triangle   
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector     
  new($t->a-$v, $t->b-$v, $t->c-$v);                         
 }

#_ Triangle ___________________________________________________________
# Print triangle 
#______________________________________________________________________

sub print($)
 {my ($t) = check(@_); # Triangle   
  my ($a, $b, $c) = ($t->a, $t->b, $t->c);
  "triangle($a, $b, $c)";
 }

#_ Triangle ___________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Triangle ___________________________________________________________
# Is point in plane defined by triangle?
#______________________________________________________________________

#sub isPointInPlane($$)
# {my ($t) =         check(@_[0..0]); # Triangle 
#  my ($p) = Math::Zap::Vector::check(@_[1..1]); # Point
#
#  my ($a, $b, $c) = $t->abc;
#
#  my $ab = $b-$a;
#  my $ac = $c-$a;
#  my $ap = $p-$a;
#
#  my $w  = $ab < $ac;  # Angle between ab and ac
#  my $w1 = $ap < $ab;  # Angle between ap and ab
#  my $w2 = $ap < $ac;  # Angle between ap and ac
#  
#  return 1 if abs($w-$w1-$w2) < $accuracy;
#  0;
# }

#_ Triangle ___________________________________________________________
# Intersect line between two points with plane defined by triangle and
# return the intersection in space coordinates.
# t = triangle
# a = start vector
# b = end vector
# Solve the simultaneous equations of the plane defined by the
# triangle and the line between the vectors:
#   ta+l*tab+m*tac = a+(b-a)*n 
# =>ta+l*tab+m*tac+n*(a-b) = a-ta 
# Note:  no checks (yet) for line parallel to plane.
#______________________________________________________________________

#sub intersection($$$)
# {my ($t)     =         check(@_[0..0]); # Triangle  
#  my ($a, $b) = Math::Zap::Vector::check(@_[1..2]); # Vectors
#   
#  $s = Math::Zap::Matrix::new3v($t->ab, $t->ac, $a-$b)/($a-$t->a);
#
#  $t->a+$s->x*$t->ab+$s->y*$t->ac;
# }

#_ Triangle ___________________________________________________________
# Shortest distance from plane defined by triangle t to point p                                
#______________________________________________________________________

sub distance($$)
 {my ($t) =         check(@_[0..0]); # Triangle  
  my ($p) = Math::Zap::Vector::check(@_[1..1]); # Vector
  my  $n  = $t->ab x $t->ac;         # Plane normal
  my ($a, $b) = ($p, $p+$n);
   
  my $s = Math::Zap::Matrix::new3v($t->ab, $t->ac, $a-$b)/($a-$t->a);

  ($n*$s->z)->length;
 }

#_ Triangle ___________________________________________________________
# Intersect line between two points with plane defined by triangle and
# return the intersection in plane coordinates. 
# Identical logic as per intersection().
# Note:  no checks (yet) for line parallel to plane.
#______________________________________________________________________

sub intersectionInPlane($$$)
 {my ($t)     =         check(@_[0..0]); # Triangle  
  my ($a, $b) = Math::Zap::Vector::check(@_[1..2]); # Vectors
   
  Math::Zap::Matrix::new3v($t->ab, $t->ac, $a-$b)/($a-$t->a);
 }
#_ Triangle ___________________________________________________________
# Distance to plane defined by triangle t going from a to b, or undef 
# if the line is parallel to the plane           
#______________________________________________________________________

sub distanceToPlaneAlongLine($$$)
 {my ($t)     =         check(@_[0..0]); # Triangle  
  my ($a, $b) = Math::Zap::Vector::check(@_[1..2]); # Vectors

  return undef if abs(($t->ab x $t->ac) * ($b - $a)) < $accuracy;
   
  my $i = Math::Zap::Matrix::new3v($t->ab, $t->ac, $a-$b)/($a-$t->a);
  $i->z * ($a-$b)->length;
 }

#_ Triangle ___________________________________________________________
# Convert space to plane coordinates                                   
#______________________________________________________________________

sub convertSpaceToPlane($$)
 {my ($t) =         check(@_[0..0]); # Triangle  
  my ($p) = Math::Zap::Vector::check(@_[1..1]); # Vector
   
  my $q = $p-$t->a;

  vector
   ($q * $t->ab / ($t->ab * $t->ab),
    $q * $t->ac / ($t->ac * $t->ac),
    $q * ($t->ab x $t->ac)->norm
   );
 }

#_ Triangle ___________________________________________________________
# Convert splane to space coordinates                                   
#______________________________________________________________________

sub convertPlaneToSpace($$)
 {my ($t, $p) = @_;
           check(@_[0..0]) if debug; # Triangle  
  Math::Zap::Vector2::check(@_[1..1]) if debug; # Vector in plane
   
  $t->a + ($p->x * $t->ab) + ($p->y * $t->ac);
 }

#_ Triangle ___________________________________________________________
# Determine whether a test point b as viewed from a view point a is in
# front of(1), in(0), or behind(-1) a plane defined by a triangle t.
# Identical logic as per intersection(), except this time we use the
# z component to determine the relative position of the point b.
# Note:  no checks (yet) for line parallel to plane.
#______________________________________________________________________

sub frontInBehind($$$)
 {my ($t, $a, $b) = @_;
          check(@_[0..0]) if debug; # Triangle  
  Math::Zap::Vector::check(@_[1..2]) if debug; # Vectors
  return 1 if abs(($t->ab x $t->ac) * ($a-$b)) < $accuracy; # Parallel
  $s = Math::Zap::Matrix::new3v($t->ab, $t->ac, $a-$b)/($a-$t->a);
  $s->z <=> 1;
 }

sub frontInBehindZ($$$)
 {my ($t, $a, $b) = @_;
          check(@_[0..0]) if debug; # Triangle  
  Math::Zap::Vector::check(@_[1..2]) if debug; # Vectors
  return undef if abs(($t->ab x $t->ac) * ($a-$b)) < $accuracy;  # Parallel
  $s = Math::Zap::Matrix::new3v($t->ab, $t->ac, $a-$b)/($a-$t->a);
  $s->z;
 }

#_ Triangle ___________________________________________________________
# Are two triangle parallel?
# I.e. do they define planes that are parallel?
# If they are parallel, their normals will have zero cross product
#______________________________________________________________________

sub parallel($$)
 {my ($a, $b) = check(@_); # Triangles
  !(($a->ab x $a->ac) x ($b->ab x $b->ac))->length;
 }

#_ Triangle ___________________________________________________________
# Are two triangle co-planar?
#______________________________________________________________________

#sub coplanar($$)
# {my ($a, $b) = check(@_); # Triangles
#  return 0 unless $a->parallel($b);
#  my $d = $a->a - $b->a;
#  return 1 if $d->length < $accuracy;
#  return 1 if abs(($a->ab x $a->ac) * $d) < $accuracy;
#  0;
# }

#_ Triangle ___________________________________________________________
# Divide triangle b by a:  split b into triangles each of which is not
# intersected by a. 
# Triangles are easy to draw in 3d except when they intersect:
# If they do not intersect, we can always draw one on top of the other
# and obtain the correct result;
# If they do intersect, they have to be split along the line of
# intersection into a sub triangle and a quadralateral: which can
# be be split again to obtain a result consisting of only triangles.
# The splitting can be done once: Each new view point only requires
# the correct ordering of the non intersecting triangles.
#______________________________________________________________________

sub divide($$)
 {my ($a, $b) = check(@_);         # Triangles  

  return ($b) if $a->parallel($b); # Parallel: no need to split

  my $A = $a->permute; $a = $A if $b->distance($A->a) > $b->distance($a->a);
     $A = $A->permute; $a = $A if $b->distance($A->a) > $b->distance($a->a);
 
  my $na = $a->ab x $a->ac;        # Normal to a
  my $nb = $b->ab x $b->ac;        # Normal to b

  my $aa = $a->a;
  my $ab = $a->b;
  my $ac = $a->c;
  my $bc = $a->bc;

# Avoid using vectors in a that are parallel to b
  $ab += $bc/2 if ($a->ab->norm * $nb->norm) < 0.1;
  $ac += $bc/2 if ($a->ac->norm * $nb->norm) < 0.1;

# Two points in both planes in b plane coordinates
  my $i = $b->intersectionInPlane($aa, $ab);
  my $j = $b->intersectionInPlane($aa, $ac);


# Does the line between these points intersect the sides of triangle b?
  my $l = line2
   (vector2($i->x, $i->y), 
    vector2($j->x, $j->y),
   );
  return ($b) if ($l->b-$l->a)->length < $accuracy;

# Triangle b has very simple sides in b plane coordinates

  my $l1 = line2(vector2(0, 0), vector2(1, 0)); # ab
  my $l2 = line2(vector2(0, 0), vector2(0, 1)); # ac
  my $l3 = line2(vector2(1, 0), vector2(0, 1)); # bc 

  my $i1 = ((!$l->parallel($l1)) and ($l->intersectWithin($l1)));
  my $i2 = ((!$l->parallel($l2)) and ($l->intersectWithin($l2)));
  my $i3 = ((!$l->parallel($l3)) and ($l->intersectWithin($l3)));

# There should be either 0 or 2 intersections.
   {my $n = $i1+$i2+$i3;
    ($n == 1 or $n == 3) and  debug and warn "There should 0 or 2 intersections, not $n";
    return ($b) unless $n == 2; # No division required
   }

# There are two intersections.
# Make a copy of b called c, orientated so that the line of 
# intersection crosses sides c->ab, c->ac           
  my $c;
  $c = $b                                 if $i1 and $i2;   
  $c = triangle($b->b, $b->a, $b->c) if $i1 and $i3;   
  $c = triangle($b->c, $b->a, $b->b) if $i2 and $i3;

# Find intersection points in terms of reorientated triangle   

  unless ($i1 and $i2)
   {$i = $c->intersectionInPlane($aa, $ab);
    $j = $c->intersectionInPlane($aa, $ac);
    $l = line2
     (vector2($i->x, $i->y), 
      vector2($j->x, $j->y),
     );
   }

# this time in plane coordinates
  $i1 = $l->intersect($l1);
  $i2 = $l->intersect($l2);

# Convert to space coordinates
  my $s1 = $c->convertPlaneToSpace($i1);
  my $s2 = $c->convertPlaneToSpace($i2);

# Vertices close to intersection points 
  my $a1 = ($c->a - $s1)->length < 1e-3; 
  my $a2 = ($c->a - $s2)->length < 1e-3; 
  my $b1 = ($c->b - $s1)->length < 1e-3; 
  my $b2 = ($c->b - $s2)->length < 1e-3; 
  my $c1 = ($c->c - $s1)->length < 1e-3; 
  my $c2 = ($c->c - $s2)->length < 1e-3;

  return ($b) if ($a1 or $b1 or $c1) and ($a2 or $b2 or $c2);
  
# Divide b into 3 if the intersections points are far from the vertices
  return
   (triangle($c->a, $s1, $s2),
    triangle($c->b, $s1, $s2),
    triangle($c->b, $s2, $c->c),
   ) unless $a1 or $a2 or $b1 or $b2 or $c1 or $c2;

# If only one intersection point is close to a vertex, make it s1.
  ($s1, $s2, $a1, $b1, $c1, $a2, $b2, $c2) =
  ($s2, $s1, $a2, $b2, $c2, $a1, $b1, $c1) if !($a1 or $b1 or $c1) and ($a2 or $b2 or $c2);

# Divide b into 2 if one intersection point is close to a vertex
  return
   (triangle($c->a, $c->b, $s2),
    triangle($c->a, $c->c, $s2),
   ) if $a1;
  return
   (triangle($c->a, $c->b, $s2),
    triangle($c->c, $c->b, $s2),
   ) if $b1;
  return
   (triangle($c->a, $c->c, $s2),
    triangle($c->b, $c->c, $s2),
   ) if $c1;
  confess "Unable to divide triangle $a by $b\n"
 }

#_ Triangle ___________________________________________________________
# Project onto the plane defined by triangle t the image of a triangle
# triangle T as viewed from a view point p.
# Return the coordinates of the projection of T onto t using the plane
# coordinates induced by t.
# The projection coordinates are (of course) 2d in the projection plane,
# however they are returned as the x,y components of a 3d vector with 
# the z component set to the multiple of the distance from the view point
# to the corresponding corner of T required to reach t. If z > 1, this
# corner of T is in front the plane of t, if z < 1 this corner of T is
# behind the plane of t.
# The logic is the same as intersection().
#______________________________________________________________________

sub project($$$)
 {my ($t, $T, $p) = @_;
          check(@_[0..1]) if debug; # Triangles 
  Math::Zap::Vector::check(@_[2..2]) if debug; # Vector

  new
   (Math::Zap::Matrix::new3v($t->ab, $t->ac, $p-$T->a)/($p-$t->a),
    Math::Zap::Matrix::new3v($t->ab, $t->ac, $p-$T->b)/($p-$t->a),
    Math::Zap::Matrix::new3v($t->ab, $t->ac, $p-$T->c)/($p-$t->a),
   );
 } 

#_ Triangle ___________________________________________________________
# Split a triangle into 4 sub triangles unless the sub triangles would
# be too small
#______________________________________________________________________

sub split($$)
 {my ($t) = check(@_[0..0]); # Triangles 
  my ($s) =      (@_[1..1]); # Minimum size 

  return () unless
    $t->ab->length > $s and
    $t->ac->length > $s and
    $t->bc->length > $s;

   (new($t->a, ($t->a+$t->b)/2, ($t->a+$t->c)/2),
    new($t->b, ($t->b+$t->a)/2, ($t->b+$t->c)/2),
    new($t->c, ($t->c+$t->a)/2, ($t->c+$t->b)/2),
    new(($t->a+$t->b)/2, ($t->a+$t->b)/2, ($t->b+$t->c)/2)
   )
 } 

#_ Triangle ___________________________________________________________
# Triangulate
#______________________________________________________________________

sub triangulate($$)
 {my ($t)    = check(@_[0..0]); # Triangle
  my  $color =       @_[1..1];  # Color           
  my  $plane = unique();        # Plane           
   
  {triangle=>$t, color=>$color, plane=>$plane};
 }

#_ Triangle ___________________________________________________________
# Compare two triangles for equality                                  
#______________________________________________________________________

sub equals($$)
 {my ($a, $b) = check(@_); # Triangles
  my ($aa, $ab, $ac) = ($a->a, $a->b, $a->c);
  my ($ba, $bb, $bc) = ($b->a, $b->b, $b->c);
  my  $d             = $accuracy;  

  return 1 if 
abs(($aa-$ba)->length) < $d and abs(($ab-$bb)->length) < $d and abs(($ac-$bc)->length) < $d or
abs(($aa-$ba)->length) < $d and abs(($ab-$bc)->length) < $d and abs(($ac-$bb)->length) < $d or
abs(($aa-$bb)->length) < $d and abs(($ab-$bc)->length) < $d and abs(($ac-$ba)->length) < $d or
abs(($aa-$bb)->length) < $d and abs(($ab-$ba)->length) < $d and abs(($ac-$bc)->length) < $d or
abs(($aa-$bc)->length) < $d and abs(($ab-$ba)->length) < $d and abs(($ac-$bb)->length) < $d or
abs(($aa-$bc)->length) < $d and abs(($ab-$bb)->length) < $d and abs(($ac-$ba)->length) < $d;  
  0;
 } 

#_ Triangle ___________________________________________________________
# Operator overloads
#______________________________________________________________________

use overload
 '+',       => \&add3,      # Add a vector
 '-',       => \&sub3,      # Subtract a vector
 '=='       => \&equals3,   # Equals
 '""'       => \&print3,    # Print
 'fallback' => FALSE;

#_ Vector _____________________________________________________________
# Add operator.
#______________________________________________________________________

sub add3
 {my ($a, $b, $c) = @_;
  return $a->add($b);
 }

#_ Vector _____________________________________________________________
# Subtract operator.
#______________________________________________________________________

sub sub3
 {my ($a, $b, $c) = @_;
  return $a->subtract($b);
 }

#_ Vector _____________________________________________________________
# Equals operator.
#______________________________________________________________________

sub equals3
 {my ($a, $b, $c) = @_;
  return $a->equals($b);
 }

#_ Triangle ___________________________________________________________
# Print a triangle
#______________________________________________________________________

sub print3
 {my ($a) = @_;
  return $a->print;
 }

#_ Triangle ___________________________________________________________
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


