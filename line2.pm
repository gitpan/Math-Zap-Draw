#!perl -w
#_ Line2 ______________________________________________________________
# Lines in 2d space
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Line2;
$VERSION=1.03;
use Math::Zap::Vector2;
use Math::Zap::Matrix2;
use Carp;
use constant debug => 0; # Debugging level

#_ Line2 ______________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(line2);

#_ Line2 ______________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Line2 ______________________________________________________________
# Short line?                      
#______________________________________________________________________

sub short($$)
 {my $l = shift;  # Line       
  my $a = 1e-4;   # Accuracy
  my $A = shift;  # Action 0: return indicator, 1: confess 
  my $n =
     ($l->{a}{x}-$l->{b}{x})**2 + ($l->{a}{y}-$l->{b}{y})**2                                      
    < $a;
  confess "Short line2" if $n and $A;
  $n;      
 }

#_ Line2 ______________________________________________________________
# Create a line from two vectors
#______________________________________________________________________

sub new($$)
 {Math::Zap::Vector2::check(@_) if debug;
  my $l = bless {a=>$_[0], b=>$_[1]};
  short($l, 1);
  $l; 
 }

sub line2($$) {new($_[0],$_[1])};

#_ Line2 ______________________________________________________________
# Check its a line
#______________________________________________________________________

sub check(@)
 {unless (debug)
   {for my $l(@_)
     {confess "$l is not a line" unless ref($l) eq __PACKAGE__;
     }
   }
   @_;
 }

#_ Line2 ______________________________________________________________
# Test its a line
#______________________________________________________________________

sub is(@)
 {for my $l(@_)
   {return 0 unless ref($l) eq __PACKAGE__;
   }
  'line2';
 }

#_ Line2 ______________________________________________________________
# Components of line
#______________________________________________________________________

sub a($)  {check(@_) if (debug); $_[0]->{a}}
sub b($)  {check(@_) if (debug); $_[0]->{b}}
sub ab($) {check(@_) if (debug); vector2($_[0]->{b}{x}-$_[0]->{a}{x}, $_[0]->{b}{y}-$_[0]->{a}{y})}
sub ba($) {check(@_) if (debug); $_[0]->a-$_[0]->b}

#_ Line2 ______________________________________________________________
# Create a line from another line
#______________________________________________________________________

sub clone($)
 {my ($l) = check(@_); # Lines
  bless {a=>$l->a, b=>$l->b}; 
 }

#_ Line2 ______________________________________________________________
# Print line
#______________________________________________________________________

sub print($)
 {my ($l) = check(@_); # Lines
  my ($a, $b) = ($l->a, $l->b);
  my ($A, $B) = ($a->print, $b->print);  
  "line2($A, $B)";
 } 

#_ Line2 ______________________________________________________________
# Angle between two lines
#______________________________________________________________________

sub angle($$)
 {my ($a, $b) = check(@_); # Lines
  $a->a-$a->b < $b->a-$b->b;     
 } 

#_ Line2 ______________________________________________________________
# Are two lines parallel
#______________________________________________________________________

sub parallel($$)
 {my ($a, $b) = check(@_); # Lines

# return 1 if abs(1 - abs($a->ab->norm * $b->ab->norm)) < $accuracy;
  return 1 if abs(1 - abs($a->ab->norm * $b->ab->norm)) < 1e-3;     
  0;
 }

#_ Line2 ______________________________________________________________
# Intersection of two lines
#______________________________________________________________________

sub intersect($$)
 {my ($a, $b) = check(@_); # Lines

  return 0 if $a->parallel($b);
  my $i = Math::Zap::Matrix2::new2v($a->ab, $b->ba) / ($b->a - $a->a);

  $a->a+$i->x*$a->ab;
 }

#_ Line2 ______________________________________________________________
# Intersection of two lines occurs within second line?
#______________________________________________________________________

sub intersectWithin($$)
 {my ($a, $b) = check(@_); # Lines

  return 0 if $a->parallel($b);
  my $i = Math::Zap::Matrix2::new2v($a->ab, $b->ba) / ($b->a - $a->a);

  0 <= $i->y and $i->y <= 1;
 } 

#_ Line2 ______________________________________________________________
# Do the two line segments cross over each other?
#______________________________________________________________________

sub crossOver($$)
 {my ($a, $b) = check(@_); # Lines

  return 0 if $a->parallel($b);
  my $i = Math::Zap::Matrix2::new2v($a->ab, $b->ba) / ($b->a - $a->a);

  0 <= $i->x and $i->x <= 1 and 0 <= $i->y and $i->y <= 1;
 } 

#_ Line2 ______________________________________________________________
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

