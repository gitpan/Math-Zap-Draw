#_ Rectangle __________________________________________________________
# Test 3d rectangles          
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

use Math::Zap::Rectangle;
use Math::Zap::Vector;
use Test::Simple tests=>3;

my ($a, $b, $c, $d) =
 (Math::Zap::Vector::new(0,    0, +1),
  Math::Zap::Vector::new(0, -1.9, -1),
  Math::Zap::Vector::new(0, -2.0, -1),
  Math::Zap::Vector::new(0, -2.1, -1)
 );

my $r = Math::Zap::Rectangle::new
 (Math::Zap::Vector::new(-1,-1, 0),
  Math::Zap::Vector::new( 2, 0, 0),
  Math::Zap::Vector::new( 0, 2, 0)
 );

ok($r->intersects($a, $b) == 1);
ok($r->intersects($a, $c) == 1);
ok($r->intersects($a, $d) == 0);

