#_ Matrix _____________________________________________________________
# Test 2*2 matrices    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

use Math::Zap::Matrix2;
use Math::Zap::Vector2;
use Test::Simple tests=>8;

my ($a, $b, $c, $v);

$a = matrix2
 (8, 0,
  0, 8,
 );

$b = matrix2
 (4, 2,
  2, 4,
 );

$c = matrix2
 (2, 2,
  1, 2,
 );

$v = vector2(1,2);

ok($a/$a           == Math::Zap::Matrix2::identity);
ok($b/$b           == Math::Zap::Matrix2::identity);
ok($c/$c           == Math::Zap::Matrix2::identity);
ok(2/$a*$a/2       == Math::Zap::Matrix2::identity);
ok(($a+$b)/($a+$b) == Math::Zap::Matrix2::identity);
ok(($a-$c)/($a-$c) == Math::Zap::Matrix2::identity);
ok(-$a/-$a         == Math::Zap::Matrix2::identity);
ok(1/$a*($a*$v)    == $v);

