#!perl -w
#_ Triangle ___________________________________________________________
# Triangles in 2d space    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Triangle2;
$VERSION=1.03;
use Math::Zap::Line2;
use Math::Zap::Matrix2;
use Math::Zap::Vector2;
use Math::Zap::Vector;
use Math::Trig;            
use Carp qw(cluck confess);
use constant debug => 0; # Debugging level

#_ Triangle2 __________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(triangle2);

#_ Triangle2 __________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Triangle2 __________________________________________________________
# Narrow (colinear) colinear?
#______________________________________________________________________

sub narrow($$)
 {my $t = shift;  # Triangle
  my $a = 1e-2;   # Accuracy
  my $A = shift;  # Action 0: return indicator, 1: confess 
  my $b = vector($t->{b}{x}-$t->{a}{x}, $t->{b}{y}-$t->{a}{y}, 0);                                           
  my $c = vector($t->{c}{x}-$t->{a}{x}, $t->{c}{y}-$t->{a}{y}, 0);                                           
  my $n = ($b x $c)->length < $a;
  confess "Narrow triangle2" if $n and $A;
  $n;      
 }

#_ Triangle2 __________________________________________________________
# Check its a triangle
#______________________________________________________________________

sub check(@)
 {if (debug)
   {for my $t(@_)
     {confess "$t is not a triangle2" unless ref($t) eq __PACKAGE__;
     }
   }
  @_;
 }

#_ Triangle2 __________________________________________________________
# Test its a triangle
#______________________________________________________________________

sub is(@)
 {for my $t(@_)
   {return 0 unless ref($t) eq __PACKAGE__;
   }
  'triangle2';
 }

#_ Triangle2 __________________________________________________________
# Create a triangle from 3 vectors specifying the coordinates of each
# corner in space coordinates.
#______________________________________________________________________

sub new($$$)
 {Math::Zap::Vector2::check(@_) if debug;
  my $t = bless {a=>$_[0], b=>$_[1], c=>$_[2]};
  narrow($t, 1);      
  $t;
 }

sub triangle2($$$) {new($_[0],$_[1],$_[2])};

#_ Triangle2 __________________________________________________________
# New without narrowness check
#______________________________________________________________________

sub newnnc($$$)
 {Math::Zap::Vector2::check(@_) if debug;
  bless {a=>$_[0], b=>$_[1], c=>$_[2]};
 }

#_ Triangle2 __________________________________________________________
# Create a triangle from the x,y components of 3 3d vectors.
#______________________________________________________________________

sub newV($$$)
 {Math::Zap::Vector::check(@_) if debug;
  my $t = bless
   {a=>vector2($_[0]->{x}, $_[0]->{y}),
    b=>vector2($_[1]->{x}, $_[1]->{y}),
    c=>vector2($_[2]->{x}, $_[2]->{y})};
  narrow($t, 1);      
  $t;
 }

#_ Triangle2 __________________________________________________________
# Create a triangle from the x,y components of 3 3d vectors without
# narrowness checking - assumes caller will do thir own.
#______________________________________________________________________

sub newVnnc($$$)
 {Math::Zap::Vector::check(@_) if debug;
  bless
   {a=>vector2($_[0]->{x}, $_[0]->{y}),
    b=>vector2($_[1]->{x}, $_[1]->{y}),
    c=>vector2($_[2]->{x}, $_[2]->{y})};
 }

#_ Triangle2 __________________________________________________________
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

sub lab($)  {check(@_) if debug; line2($_[0]->{b}, $_[0]->{a})}
sub lac($)  {check(@_) if debug; line2($_[0]->{c}, $_[0]->{a})}
sub lba($)  {check(@_) if debug; line2($_[0]->{a}, $_[0]->{b})}
sub lbc($)  {check(@_) if debug; line2($_[0]->{c}, $_[0]->{b})}
sub lca($)  {check(@_) if debug; line2($_[0]->{a}, $_[0]->{c})}
sub lcb($)  {check(@_) if debug; line2($_[0]->{b}, $_[0]->{c})}

#_ Triangle2 __________________________________________________________
# Create a triangle from another triangle 
#______________________________________________________________________

sub clone($)
 {my ($t) = check(@_); # Triangle   
  bless {a=>$t->a, b=>$t->b, c=>$t->c};
 }

#_ Triangle2 __________________________________________________________
# Cyclically permute the points of a triangle
#______________________________________________________________________

sub permute($)
 {my ($t) = check(@_); # Triangle   
  bless {a=>$t->b, b=>$t->c, c=>$t->a};
 }

#_ Triangle2 __________________________________________________________
# Center 
#______________________________________________________________________

sub center($)
 {my ($t) = check(@_); # Triangle   
  ($t->a + $t->b + $t->c) / 3;
 }

#_ Triangle2 __________________________________________________________
# Area 
#______________________________________________________________________

sub area($)
 {my ($t) = check(@_); # Triangle   
  sqrt((($t->ab*$t->ab) * ($t->ac*$t->ac)) - ($t->ab * $t->ac))/2;
 }

#_ Triangle2 __________________________________________________________
# Add a vector to a triangle               
#______________________________________________________________________

sub add($$)
 {my ($t) =          check(@_[0..0]); # Triangle   
  my ($v) = Math::Zap::Vector2::check(@_[1..1]); # Vector     
  new($t->a+$v, $t->b+$v, $t->c+$v);                         
 }

#_ Triangle2 __________________________________________________________
# Subtract a vector from a triangle               
#______________________________________________________________________

sub subtract($$)
 {my ($t) =          check(@_[0..0]); # Triangle   
  my ($v) = Math::Zap::Vector2::check(@_[1..1]); # Vector     
  new($t->a-$v, $t->b-$v, $t->c-$v);                         
 }

#_ Triangle2 __________________________________________________________
# Multiply a triangle by a scalar               
#______________________________________________________________________

sub multiply($$)
 {my ($t) = check(@_[0..0]); # Triangle   
  my ($s) =       @_[1..1] ; # Scalar     
  new($t->a * $s, $t->b * $s, $t->c * $s);                         
 }

#_ Triangle2 __________________________________________________________
# Divide a triangle by a scalar               
#______________________________________________________________________

sub divideBy($$)
 {my ($t) = check(@_[0..0]); # Triangle   
  my ($s) =       @_[1..1] ; # Scalar
  $s != 0 or confess "Attempt to divide by zero";    
  new($t->a / $s, $t->b / $s, $t->c / $s);                         
 }

#_ Triangle2 __________________________________________________________
# Print triangle 
#______________________________________________________________________

sub print($)
 {my ($t) = @_; # Triangle   
  check(@_) if debug;   
  my ($a, $b, $c) = ($t->a, $t->b, $t->c);
  "triangle2($a, $b, $c)";
 }

#_ Triangle2 __________________________________________________________
# Convert space to plane coordinates                                   
#______________________________________________________________________

sub convertSpaceToPlane($$)
 {my ($t, $p) = @_;
           check(@_[0..0]) if debug; # Triangle  
  Math::Zap::Vector2::check(@_[1..1]) if debug; # Vector
   
  my $q = $p-$t->a;

  vector2
   ($q * $t->ab / ($t->ab * $t->ab),
    $q * $t->ac / ($t->ac * $t->ac),
   );
 }

#_ Triangle2 __________________________________________________________
# Check whether point p is completely contained within triangle t.                                   
#______________________________________________________________________

sub containsPoint($$)
 {my ($t, $p) = @_;
           check(@_[0..0]) if debug; # Triangle  
  Math::Zap::Vector2::check(@_[1..1]) if debug; # Vector

  my $s = Math::Zap::Matrix2::new2v($t->ab, $t->ac) / ($p - $t->a);
                 
  return 1 if 0 <= $s->x and $s->x <= 1
          and 0 <= $s->y and $s->y <= 1
          and        $s->x + $s->y <= 1;
  0;
 }

#_ Triangle2 __________________________________________________________
# Check whether triangle T is completely contained within triangle t.                                   
#______________________________________________________________________

sub contains($$)
 {my ($t, $T) = @_; 
  check(@_) if debug; # Triangles

$Math::Zap::DB::single = 1 if 
ref($t) eq 'triangle2=HASH(0x20c8038)' and
ref($T) eq 'triangle2=HASH(0x20c6cc8)';

  return 1 if $t->containsPoint($T->a) and
              $t->containsPoint($T->b) and
              $t->containsPoint($T->c);   
  0;
 }

#_ Triangle2 __________________________________________________________
# Find points in common to two triangles.  A point in common is a point
# on the border of one triangle touched by the border of the other
# triangle.
#______________________________________________________________________

sub pointsInCommon($$)
 {my ($t, $T) = @_; 
  check(@_) if debug; # Triangles

  return ($T->a, $T->b, $T->c) if $t->contains($T);
  return ($t->a, $t->b, $t->c) if $T->contains($t);

  my @p = ();
  push @p, $t->a if $T->containsPoint($t->a);  
  push @p, $t->b if $T->containsPoint($t->b);  
  push @p, $t->c if $T->containsPoint($t->c);

  push @p, $T->a if $t->containsPoint($T->a);  
  push @p, $T->b if $t->containsPoint($T->b);  
  push @p, $T->c if $t->containsPoint($T->c);
  
  push @p, $t->lab->intersect($T->lab) if $t->lab->crossOver($T->lab); 
  push @p, $t->lab->intersect($T->lac) if $t->lab->crossOver($T->lac); 
  push @p, $t->lab->intersect($T->lbc) if $t->lab->crossOver($T->lbc); 
  push @p, $t->lac->intersect($T->lab) if $t->lac->crossOver($T->lab); 
  push @p, $t->lac->intersect($T->lac) if $t->lac->crossOver($T->lac); 
  push @p, $t->lac->intersect($T->lbc) if $t->lac->crossOver($T->lbc);
  push @p, $t->lbc->intersect($T->lab) if $t->lbc->crossOver($T->lab); 
  push @p, $t->lbc->intersect($T->lac) if $t->lbc->crossOver($T->lac); 
  push @p, $t->lbc->intersect($T->lbc) if $t->lbc->crossOver($T->lbc);

# Remove duplicate points caused by splitting the vertices - inefficient and unreliable
  my %p;
  $p{"$_"}=$_ for(@p);
  values(%p); 
 }

#_ Triangle2 __________________________________________________________
# Ring of points formed by overlaying triangle t and T
#______________________________________________________________________

sub ring($$)
 {my ($t, $T) = @_; 
  check(@_) if debug; # Triangles

  my @p = $t->pointsInCommon($T);
# scalar(@p) == 1 and warn "Only one point in common";
# scalar(@p) == 2 and warn "Only two points in common";
  return () unless scalar(@p) > 2;

# Find center
  my $c = vector2(0,0);
  $c += $_ for(@p);
  $c /= scalar(@p);

# Split by y coord   
  my (@yp, @yn);
  for my $p(0..@p-1)
   {return () if ($p[$p]-$c)->length < $accuracy;
    if (($p[$p]-$c)->y >= 0)
     {push @yp, $p;
     }
    else
     {push @yn, $p;
     }
   }

  @yp = sort {($p[$a]-$c)->norm->x <=> ($p[$b]-$c)->norm->x} @yp;
  @yn = sort {($p[$b]-$c)->norm->x <=> ($p[$a]-$c)->norm->x} @yn;

  my @a;
  push @a, $p[$_] for(@yp);
  push @a, $p[$_] for(@yn);
  @a;
 }

#_ Triangle2 __________________________________________________________
# Convert plane to space coordinates                                   
#______________________________________________________________________

sub convertPlaneToSpace($$)
 {my ($t, $p) = @_;                               
           check(@_[0..0]) if debug; # Triangle  
  Math::Zap::Vector2::check(@_[1..1]) if debug; # Vector in plane
   
  $t->a + ($p->x * $t->ab) + ($p->y * $t->ac);
 }

#_ Triangle2 __________________________________________________________
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

#_ Triangle2 __________________________________________________________
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

#_ Triangle2 __________________________________________________________
# Operator overloads
#______________________________________________________________________

use overload
 '+',       => \&add3,      # Add a vector
 '-',       => \&sub3,      # Subtract a vector
 '*',       => \&multiply3, # Multiply by a scalar
 '/',       => \&divide3,   # Divide by a scalar
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
# Multiply operator.
#______________________________________________________________________

sub multiply3
 {my ($a, $b) = @_;
  return $a->multiply($b);
 }

#_ Vector _____________________________________________________________
# Divide operator.
#______________________________________________________________________

sub divide3
 {my ($a, $b, $c) = @_;
  return $a->divideBy($b);
 }

#_ Vector _____________________________________________________________
# Equals operator.
#______________________________________________________________________

sub equals3
 {my ($a, $b, $c) = @_;
  return $a->equals($b);
 }

#_ Triangle2 __________________________________________________________
# Print a triangle
#______________________________________________________________________

sub print3
 {my ($a) = @_;
  return $a->print;
 }

#_ Triangle2 __________________________________________________________
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


