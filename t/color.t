#_ Color ______________________________________________________________
# Test colors    
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

use Math::Zap::Color;
use Test::Simple tests=>6;

ok(color('dark red')->normal eq '#8b0000');
ok(color('dark red')->light  eq '#c58080');
ok(color('red')->normal      eq '#ff0000');
ok(color('red')->light       eq '#ff8080');
ok(color('red')->dark        eq '#7f0000');
ok(color('red')->invert      eq '#00ffff');

