#_ Matrix _____________________________________________________________
# Test 3*3 matrices    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

use Math::Zap::Matrix;
use Math::Zap::Vector;
use Test::Simple tests=>8;

my ($a, $b, $c, $v);

$a = matrix
 (8, 0, 0,
  0, 8, 0,
  0, 0, 8
 );

$b = matrix
 (4, 2, 0,
  2, 4, 2,
  0, 2, 4
 );

$c = matrix
 (4, 2, 1,
  2, 4, 2,
  1, 2, 4
 );

$v = vector(1,2,3);

ok($a/$a           == Math::Zap::Matrix::identity);
ok($b/$b           == Math::Zap::Matrix::identity);
ok($c/$c           == Math::Zap::Matrix::identity);
ok(2/$a*$a/2       == Math::Zap::Matrix::identity);
ok(($a+$b)/($a+$b) == Math::Zap::Matrix::identity);
ok(($a-$c)/($a-$c) == Math::Zap::Matrix::identity);
ok(-$a/-$a         == Math::Zap::Matrix::identity);
ok(1/$a*($a*$v)    == $v);

