#!perl -w
#_ Matrix _____________________________________________________________
# 3*3 matrix manipulation    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Matrix;
$VERSION=1.03;
use Math::Zap::Vector;
use Carp;
use constant debug => 0; # Debugging level

#_ Matrix _____________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(matrix);

#_ Matrix _____________________________________________________________
# Check its a matrix
#______________________________________________________________________

sub check(@)
 {if (debug)
   {for my $m(@_)
     {confess "$m is not a matrix" unless ref($m) eq __PACKAGE__;
     }
    }
  return (@_)
 }

#_ Matrix _____________________________________________________________
# Test its a matrix
#______________________________________________________________________

sub is(@)
 {for my $m(@_)
   {return 0 unless ref($m) eq __PACKAGE__;
   }
  'matrix';
 }

#_ Matrix _____________________________________________________________
# Singular matrix?
#______________________________________________________________________

sub singular($$)
 {my $m = shift;  # Matrix   
  my $a = 1e-2;   # Accuracy
  my $A = shift;  # Action 0: return indicator, 1: confess 

  my $n = abs
   ($m->{11}*$m->{22}*$m->{33}
   -$m->{11}*$m->{23}*$m->{32}
   -$m->{12}*$m->{21}*$m->{33}
   +$m->{12}*$m->{23}*$m->{31}
   +$m->{13}*$m->{21}*$m->{32}
   -$m->{13}*$m->{22}*$m->{31})
   < $a;
  confess "Singular matrix2" if $n and $A;
  $n;      
 }

#_ Matrix _____________________________________________________________
# Get/Set accuracy for comparisons
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Matrix _____________________________________________________________
# Round: round to nearest integer if within accuracy of that integer 
#______________________________________________________________________

sub round($)
 {my ($a) = @_;
  check(@_) if debug; 
  my ($n, $N);
  for my $k(qw(11 12 13  21 22 23 31 32 33))
   {$n = $a->{$k};
    $N = int($n);
    $a->{$k} = $N if abs($n-$N) < $accuracy;
   }
  $a;
 }

#_ Matrix _____________________________________________________________
# Create a matrix
#______________________________________________________________________

sub new($$$$$$$$$)
 {my
  ($a11, $a12, $a13,
   $a21, $a22, $a23,
   $a31, $a32, $a33,
  ) = @_;

  my $m = round bless
   {11=>$a11, 12=>$a12, 13=>$a13,
    21=>$a21, 22=>$a22, 23=>$a23,
    31=>$a31, 32=>$a32, 33=>$a33,
   }; 
  singular($m, 1);
  $m;
 }

sub matrix($$$$$$$$$)
 {new($_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7],$_[8]);
 }

#_ Matrix _____________________________________________________________
# Create a matrix from three vectors
#______________________________________________________________________

sub new3v($$$)
 {my ($a, $b, $c) = @_; 
  Math::Zap::Vector::check(@_) if debug; 
  my $m = round bless
   {11=>$a->x, 12=>$b->x, 13=>$c->x,
    21=>$a->y, 22=>$b->y, 23=>$c->y,
    31=>$a->z, 32=>$b->z, 33=>$c->z,
   };
  singular($m, 1);
  $m;
 }

#_ Matrix _____________________________________________________________
# Create a matrix from three vectors
#______________________________________________________________________

sub new3vnc($$$)
 {my ($a, $b, $c) = Math::Zap::Vector::check(@_); 
  my $m = round bless
   {11=>$a->x, 12=>$b->x, 13=>$c->x,
    21=>$a->y, 22=>$b->y, 23=>$c->y,
    31=>$a->z, 32=>$b->z, 33=>$c->z,
   };
  $m;
 }

#_ Matrix _____________________________________________________________
# Create a matrix from another matrix
#______________________________________________________________________

sub clone($)
 {my ($m) = check(@_); # Matrix
  round bless
   {11=>$m->{11}, 12=>$m->{12}, 13=>$m->{13},
    21=>$m->{21}, 22=>$m->{22}, 23=>$m->{23},
    31=>$m->{31}, 32=>$m->{32}, 33=>$m->{33},
   }; 
 }

#_ Matrix _____________________________________________________________
# Print matrix
#______________________________________________________________________

sub print($)
 {my ($m) = check(@_); # Matrix 
  'matrix('.$m->{11}.', '.$m->{12}.', '.$m->{13}.
       ', '.$m->{21}.', '.$m->{22}.', '.$m->{23}.
       ', '.$m->{31}.', '.$m->{32}.', '.$m->{33}.
  ')';
 } 

#_ Matrix _____________________________________________________________
# Add matrices
#______________________________________________________________________

sub add($$)
 {my ($a, $b) = check(@_); # Matrices
  round bless
   {11=>$a->{11}+$b->{11}, 12=>$a->{12}+$b->{12}, 13=>$a->{13}+$b->{13},
    21=>$a->{21}+$b->{21}, 22=>$a->{22}+$b->{22}, 23=>$a->{23}+$b->{23},
    31=>$a->{31}+$b->{31}, 32=>$a->{32}+$b->{32}, 33=>$a->{33}+$b->{33},
   }; 
 }

#_ Matrix _____________________________________________________________
# Negate matrix
#______________________________________________________________________

sub negate($)
 {my ($a) = check(@_); # Matrices
  round bless
   {11=>-$a->{11}, 12=>-$a->{12}, 13=>-$a->{13},
    21=>-$a->{21}, 22=>-$a->{22}, 23=>-$a->{23},
    31=>-$a->{31}, 32=>-$a->{32}, 33=>-$a->{33},
   }; 
 }

#_ Matrix _____________________________________________________________
# Subtract matrices
#______________________________________________________________________

sub subtract($$)
 {my ($a, $b) = check(@_); # Matrices
  round bless
   {11=>$a->{11}-$b->{11}, 12=>$a->{12}-$b->{12}, 13=>$a->{13}-$b->{13},
    21=>$a->{21}-$b->{21}, 22=>$a->{22}-$b->{22}, 23=>$a->{23}-$b->{23},
    31=>$a->{31}-$b->{31}, 32=>$a->{32}-$b->{32}, 33=>$a->{33}-$b->{33},
   }; 
 }

#_ Matrix _____________________________________________________________
# Vector = Matrix * Vector     
#______________________________________________________________________

sub matrixVectorMultiply($$)
 {my ($a) =         check(@_[0..0]); # Matrix
  my ($b) = Math::Zap::Vector::check(@_[1..1]); # Vector 
  vector
   ($a->{11}*$b->x+$a->{12}*$b->y+$a->{13}*$b->z,
    $a->{21}*$b->x+$a->{22}*$b->y+$a->{23}*$b->z,
    $a->{31}*$b->x+$a->{32}*$b->y+$a->{33}*$b->z,
   );
 }

#_ Matrix _____________________________________________________________
# Matrix = Matrix * scalar      
#______________________________________________________________________

sub matrixScalarMultiply($$)
 {my ($a) = check(@_[0..0]); # Matrix
  my ($b) =       @_[1..1];  # Scalar
  confess "$b is not a scalar" if ref($b);   
  round bless
   {11=>$a->{11}*$b, 12=>$a->{12}*$b, 13=>$a->{13}*$b,
    21=>$a->{21}*$b, 22=>$a->{22}*$b, 23=>$a->{23}*$b,
    31=>$a->{31}*$b, 32=>$a->{32}*$b, 33=>$a->{33}*$b,
   }; 
 }

#_ Matrix _____________________________________________________________
# Matrix = Matrix * Matrix      
#______________________________________________________________________

sub matrixMatrixMultiply($$)
 {my ($a, $b) = check(@_); # Matrices
  round bless
   {11=>$a->{11}*$b->{11}+$a->{12}*$b->{21}+$a->{13}*$b->{31}, 12=>$a->{11}*$b->{12}+$a->{12}*$b->{22}+$a->{13}*$b->{32}, 13=>$a->{11}*$b->{13}+$a->{12}*$b->{23}+$a->{13}*$b->{33},
    21=>$a->{21}*$b->{11}+$a->{22}*$b->{21}+$a->{23}*$b->{31}, 22=>$a->{21}*$b->{12}+$a->{22}*$b->{22}+$a->{23}*$b->{32}, 23=>$a->{21}*$b->{13}+$a->{22}*$b->{23}+$a->{23}*$b->{33},
    31=>$a->{31}*$b->{11}+$a->{32}*$b->{21}+$a->{33}*$b->{31}, 32=>$a->{31}*$b->{12}+$a->{32}*$b->{22}+$a->{33}*$b->{32}, 33=>$a->{31}*$b->{13}+$a->{32}*$b->{23}+$a->{33}*$b->{33},
   }; 
 }

#_ Matrix _____________________________________________________________
# Matrix=Matrix / non zero scalar
#______________________________________________________________________

sub matrixScalarDivide($$)
 {my ($a) = check(@_[0..0]); # Matrices
  my ($b) = @_[1..1];        # Scalar
  confess "$b is not a scalar" if ref($b);   
  confess "$b is zero"         if $b == 0;   
  round bless
   {11=>$a->{11}/$b, 12=>$a->{12}/$b, 13=>$a->{13}/$b,
    21=>$a->{21}/$b, 22=>$a->{22}/$b, 23=>$a->{23}/$b,
    31=>$a->{31}/$b, 32=>$a->{32}/$b, 33=>$a->{33}/$b,
   }; 
 }

#_ Matrix _____________________________________________________________
# Determinant of matrix.
#______________________________________________________________________

sub det($)
 {my ($a) = @_;       # Matrix
  check(@_) if debug; # Check

+$a->{11}*$a->{22}*$a->{33}
-$a->{11}*$a->{23}*$a->{32}
-$a->{12}*$a->{21}*$a->{33}
+$a->{12}*$a->{23}*$a->{31}
+$a->{13}*$a->{21}*$a->{32}
-$a->{13}*$a->{22}*$a->{31};
 }

#_ Matrix _____________________________________________________________
# Determinant of 2*2 matrix
# a c       
# b d
#______________________________________________________________________

sub d2($$$$)
 {my ($a, $b, $c, $d) = @_;    
  $a*$d-$b*$c;
 }

#_ Matrix _____________________________________________________________
# Inverse of matrix
#______________________________________________________________________

sub inverse($)
 {my ($a) = @_;       # Matrix
  check(@_) if debug; # Check
  return $a->{inverse} if defined($a->{inverse});

  my $d = det($a);
  return undef if $d == 0;

  my $i = round bless
   {11=>d2($a->{22}, $a->{32}, $a->{23}, $a->{33})/$d,
    21=>d2($a->{23}, $a->{33}, $a->{21}, $a->{31})/$d,
    31=>d2($a->{21}, $a->{31}, $a->{22}, $a->{32})/$d,

    12=>d2($a->{13}, $a->{33}, $a->{12}, $a->{32})/$d,
    22=>d2($a->{11}, $a->{31}, $a->{13}, $a->{33})/$d,
    32=>d2($a->{12}, $a->{32}, $a->{11}, $a->{31})/$d,

    13=>d2($a->{12}, $a->{22}, $a->{13}, $a->{23})/$d,
    23=>d2($a->{13}, $a->{23}, $a->{11}, $a->{21})/$d,
    33=>d2($a->{11}, $a->{21}, $a->{12}, $a->{22})/$d,
   };
  $a->{inverse} = $i;
  $i;
 }

#_ Matrix _____________________________________________________________
# Identity matrix
#______________________________________________________________________

sub identity()
 {bless
   {11=>1, 21=>0, 31=>0,                              
    12=>0, 22=>1, 32=>0,                              
    13=>0, 23=>0, 33=>1,
   }; 
 }

#_ Matrix _____________________________________________________________
# Equals to within accuracy
#______________________________________________________________________

sub equals($$)
 {my ($a, $b) = check(@_); # Matrices
  abs($a->{11}-$b->{11}) < $accuracy and
  abs($a->{12}-$b->{12}) < $accuracy and
  abs($a->{13}-$b->{13}) < $accuracy and

  abs($a->{21}-$b->{21}) < $accuracy and
  abs($a->{22}-$b->{22}) < $accuracy and
  abs($a->{23}-$b->{23}) < $accuracy and

  abs($a->{31}-$b->{31}) < $accuracy and
  abs($a->{32}-$b->{32}) < $accuracy and
  abs($a->{33}-$b->{33}) < $accuracy;
 }

#_ Matrix _____________________________________________________________
# Operator overloads
#______________________________________________________________________

use overload
 '+'        => \&add3,      # Add two vectors
 '-'        => \&subtract3, # Subtract one vector from another
 '*'        => \&multiply3, # Times by a scalar, or vector dot product 
 '/'        => \&divide3,   # Divide by a scalar
 '!'        => \&det3,      # Determinant                       
 '=='       => \&equals3,   # Equals (to accuracy)
 '""'       => \&print3,    # Print
 'fallback' => FALSE;

#_ Matrix _____________________________________________________________
# Add operator.
#______________________________________________________________________

sub add3
 {my ($a, $b) = @_;
  $a->add($b);
 }

#_ Matrix _____________________________________________________________
# Negate operator.
#______________________________________________________________________

sub subtract3
 {my ($a, $b, $c) = @_;

  return $a->subtract($b) if $b;
  negate($a);
 }

#_ Matrix _____________________________________________________________
# Multiply operator.
#______________________________________________________________________

sub multiply3
 {my ($a, $b) = @_;
  return $a->matrixScalarMultiply($b) unless ref($b);
  return $a->matrixVectorMultiply($b) if Math::Zap::Vector::is($b);
  return $a->matrixMatrixMultiply($b) if is($b);
  confess "Cannot multiply $a by $b\n";
 }

#_ Matrix _____________________________________________________________
# Divide operator.
#______________________________________________________________________

sub divide3
 {my ($a, $b, $c) = @_;
  if (!ref($b))
   {return $a->matrixScalarDivide($b)            unless $c;
    return $a->inverse->matrixScalarMultiply($b) if     $c;
   }
  else 
   {return $a->inverse->matrixVectorMultiply($b) if Math::Zap::Vector::is($b);
    return $a->matrixMatrixMultiply($b->inverse) if is($b);
    confess "Cannot multiply $a by $b\n";
   }
 }

#_ Matrix _____________________________________________________________
# Equals operator.
#______________________________________________________________________

sub equals3
 {my ($a, $b, $c) = @_;
  return $a->equals($b);
 }

#_ Matrix _____________________________________________________________
# Determinant of a matrix
#______________________________________________________________________

sub det3
 {my ($a, $b, $c) = @_;
  $a->det;
 }

#_ Matrix _____________________________________________________________
# Print a vector.
#______________________________________________________________________

sub print3
 {my ($a) = @_;
  return $a->print;
 }

#_ Matrix _____________________________________________________________
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

