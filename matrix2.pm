#!perl -w
#_ Matrix2 ____________________________________________________________
# 2*2 matrix manipulation    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Matrix2;
$VERSION=1.03;
use Math::Zap::Vector2;
use Carp;
use constant debug => 0; # Debugging level

#_ Matrix2 ____________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(matrix2);

#_ Matrix2 ____________________________________________________________
# Check its a matrix
#______________________________________________________________________

sub check(@)
 {if (debug)
   {for my $m(@_)
     {confess "$m is not a matrix2" unless ref($m) eq __PACKAGE__;
     } 
   }
  return (@_)
 }

#_ Matrix2 ____________________________________________________________
# Test its a matrix
#______________________________________________________________________

sub is(@)
 {for my $m(@_)
   {return 0 unless ref($m) eq __PACKAGE__;
   }
  'matrix2';
 }

#_ Matrix2 ____________________________________________________________
# Get/Set accuracy 
#______________________________________________________________________

my $accuracy = 1e-10;

sub accuracy
 {return $accuracy unless scalar(@_);
  $accuracy = shift();
 }

#_ Matrix2 ____________________________________________________________
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

#_ Matrix2 ____________________________________________________________
# Singular matrix?
#______________________________________________________________________

sub singular($$)
 {my $m = shift;  # Matrix   
  my $a = 1e-2;   # Accuracy
  my $A = shift;  # Action 0: return indicator, 1: confess 
  my $n = abs
    ($m->{11} * $m->{22} -                                        
     $m->{12} * $m->{21})
    < $a;
  confess "Singular matrix2" if $n and $A;
  $n;      
 }

#_ Matrix2 ____________________________________________________________
# Create a matrix
#______________________________________________________________________

sub new($$$$)
 {my
  ($a11, $a12,
   $a21, $a22,
  ) = @_;

  my $m = round bless
   {11=>$a11, 12=>$a12,
    21=>$a21, 22=>$a22,
   };
  singular($m, 1);
  $m;
 }

sub matrix2($$$$)
 {new($_[0],$_[1],$_[2],$_[3]);
 }

#_ Matrix2 ____________________________________________________________
# Create a matrix from two vectors
#______________________________________________________________________

sub new2v($$)
 {Math::Zap::Vector2::check(@_) if debug;
  my ($a, $b, $c) =  @_;
  my $m = round bless
   {11=>$a->{x}, 12=>$b->{x},
    21=>$a->{y}, 22=>$b->{y},
   };
  singular($m, 1);
  $m;
 }

#_ Matrix2 ____________________________________________________________
# Create a matrix from another matrix
#______________________________________________________________________

sub clone($)
 {my ($m) = check(@_); # Matrix
  round bless
   {11=>$m->{11}, 12=>$m->{12},
    21=>$m->{21}, 22=>$m->{22},
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Print matrix
#______________________________________________________________________

sub print($)
 {my ($m) = check(@_); # Matrix 
  'matrix2('.$m->{11}.', '.$m->{12}. 
        ', '.$m->{21}.', '.$m->{22}.
  ')';
 } 

#_ Matrix2 ____________________________________________________________
# Add matrices
#______________________________________________________________________

sub add($$)
 {my ($a, $b) = check(@_); # Matrices
  my $m = round bless
   {11=>$a->{11}+$b->{11}, 12=>$a->{12}+$b->{12}, 
    21=>$a->{21}+$b->{21}, 22=>$a->{22}+$b->{22}, 
   }; 
  singular($m, 1);
  $m;
 }

#_ Matrix2 ____________________________________________________________
# Negate matrix
#______________________________________________________________________

sub negate($)
 {my ($a) = check(@_); # Matrices
  my $m = round bless
   {11=>-$a->{11}, 12=>-$a->{12},
    21=>-$a->{21}, 22=>-$a->{22},
   }; 
  singular($m, 1);
  $m;
 }

#_ Matrix2 ____________________________________________________________
# Subtract matrices
#______________________________________________________________________

sub subtract($$)
 {my ($a, $b) = check(@_); # Matrices
  my $m = round bless
   {11=>$a->{11}-$b->{11}, 12=>$a->{12}-$b->{12},
    21=>$a->{21}-$b->{21}, 22=>$a->{22}-$b->{22},
   }; 
  singular($m, 1);
  $m;
 }

#_ Matrix2 ____________________________________________________________
# Vector = Matrix * Vector     
#______________________________________________________________________

sub matrixVectorMultiply($$)
 {         check(@_[0..0]) if debug; # Matrix
  Math::Zap::Vector2::check(@_[1..1]) if debug; # Vector 
  my ($a, $b) = @_;
  vector2
   ($a->{11}*$b->{x}+$a->{12}*$b->{y},
    $a->{21}*$b->{x}+$a->{22}*$b->{y},
   );
 }

#_ Matrix2 ____________________________________________________________
# Matrix = Matrix * scalar      
#______________________________________________________________________

sub matrixScalarMultiply($$)
 {my ($a) = check(@_[0..0]); # Matrix
  my ($b) = @_[1..1];        # Scalar
  confess "$b is not a scalar" if ref($b);   
  round bless
   {11=>$a->{11}*$b, 12=>$a->{12}*$b,
    21=>$a->{21}*$b, 22=>$a->{22}*$b,
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Matrix = Matrix * Matrix      
#______________________________________________________________________

sub matrixMatrixMultiply($$)
 {my ($a, $b) = check(@_); # Matrices
  round bless
   {11=>$a->{11}*$b->{11}+$a->{12}*$b->{21}, 12=>$a->{11}*$b->{12}+$a->{12}*$b->{22},
    21=>$a->{21}*$b->{11}+$a->{22}*$b->{21}, 22=>$a->{21}*$b->{12}+$a->{22}*$b->{22},
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Matrix=Matrix / non zero scalar
#______________________________________________________________________

sub matrixScalarDivide($$)
 {my ($a) = check(@_[0..0]); # Matrices
  my ($b) = @_[1..1];        # Scalar
  confess "$b is not a scalar" if ref($b);   
  confess "$b is zero"         if $b == 0;   
  round bless
   {11=>$a->{11}/$b, 12=>$a->{12}/$b,
    21=>$a->{21}/$b, 22=>$a->{22}/$b,
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Determinant of matrix.
#______________________________________________________________________

sub det($)
 {my ($a) = check(@_); # Matrices

+$a->{11}*$a->{22}
-$a->{12}*$a->{21}
 }

#_ Matrix2 ____________________________________________________________
# Inverse of matrix
#______________________________________________________________________

sub inverse($)
 {my ($a) = check(@_); # Matrices

  my $d = det($a);
  return undef if $d == 0;

  round bless
   {11=> $a->{22}/$d, 21=>-$a->{21}/$d,
    12=>-$a->{12}/$d, 22=> $a->{11}/$d,
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Identity matrix
#______________________________________________________________________

sub identity()
 {bless
   {11=>1, 21=>0,                              
    12=>0, 22=>1,                              
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Rotation matrix: rotate anti-clockwise by t radians
#______________________________________________________________________

sub rotate($)
 {my ($a) = @_;
   bless
   {11=>cos($t), 21=>-sin($t),                              
    12=>sin($t), 22=> cos($t),                              
   }; 
 }

#_ Matrix2 ____________________________________________________________
# Equals to within accuracy
#______________________________________________________________________

sub equals($$)
 {my ($a, $b) = check(@_); # Matrices
  abs($a->{11}-$b->{11}) < $accuracy and
  abs($a->{12}-$b->{12}) < $accuracy and

  abs($a->{21}-$b->{21}) < $accuracy and
  abs($a->{22}-$b->{22}) < $accuracy;
 }

#_ Matrix2 ____________________________________________________________
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

#_ Matrix2 ____________________________________________________________
# Add operator.
#______________________________________________________________________

sub add3
 {my ($a, $b) = @_;
  $a->add($b);
 }

#_ Matrix2 ____________________________________________________________
# Negate operator.
#______________________________________________________________________

sub subtract3
 {my ($a, $b, $c) = @_;

  return $a->subtract($b) if $b;
  negate($a);
 }

#_ Matrix2 ____________________________________________________________
# Multiply operator.
#______________________________________________________________________

sub multiply3
 {my ($a, $b) = @_;
  return $a->matrixScalarMultiply($b) unless ref($b);
  return $a->matrixVectorMultiply($b) if Math::Zap::Vector2::is($b);
  return $a->matrixMatrixMultiply($b) if is($b);
  confess "Cannot multiply $a by $b\n";
 }

#_ Matrix2 ____________________________________________________________
# Divide operator.
#______________________________________________________________________

sub divide3
 {my ($a, $b, $c) = @_;
  if (!ref($b))
   {return $a->matrixScalarDivide($b)            unless $c;
    return $a->inverse->matrixScalarMultiply($b) if     $c;
   }
  else 
   {return $a->inverse->matrixVectorMultiply($b) if Math::Zap::Vector2::is($b);
    return $a->matrixMatrixMultiply($b->inverse) if is($b);
    confess "Cannot multiply $a by $b\n";
   }
 }

#_ Matrix2 ____________________________________________________________
# Equals operator.
#______________________________________________________________________

sub equals3
 {my ($a, $b, $c) = @_;
  return $a->equals($b);
 }

#_ Matrix2 ____________________________________________________________
# Determinant of a matrix
#______________________________________________________________________

sub det3
 {my ($a, $b, $c) = @_;
  $a->det;
 }

#_ Matrix2 ____________________________________________________________
# Print a vector.
#______________________________________________________________________

sub print3
 {my ($a) = @_;
  return $a->print;
 }

#_ Matrix2 ____________________________________________________________
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

