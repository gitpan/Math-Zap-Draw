#_ Vector _____________________________________________________________
# Test 3d vectors    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

use Math::Zap::Vector;
use Test::Simple tests=>7;

my ($x, $y, $z) = Math::Zap::Vector::units();

ok(!$x                            == 1);
ok(2*$x+3*$y+4*$z                 == Math::Zap::Vector::new( 2,  3,   4));
ok(-$x-$y-$z                      == Math::Zap::Vector::new(-1, -1,  -1));
ok((2*$x+3*$y+4*$z) + (-$x-$y-$z) == Math::Zap::Vector::new( 1,  2,   3));
ok((2*$x+3*$y+4*$z) * (-$x-$y-$z) == -9);  
ok($x*2                           == Math::Zap::Vector::new( 2,  0,   0));
ok($y/2                           == Math::Zap::Vector::new( 0,  0.5, 0));

