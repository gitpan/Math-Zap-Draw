#!perl -w
#_ Draw _______________________________________________________________
# Draw triangles using Tk
# Perl licence
# PhilipRBrenan@yahoo.com, 2004
#______________________________________________________________________

package Math::Zap::Draw;
$VERSION=1.03;
use Math::Zap::Vector;
use Math::Zap::Vector2;
use Math::Zap::Triangle2;
use Math::Zap::Triangle;
use Math::Zap::Color;
use Tk;
use Carp;

use constant debug=>0;

#_ Draw _______________________________________________________________
# Exports 
#______________________________________________________________________

require Exporter;
use vars qw( @ISA $VERSION @EXPORT);

@ISA    = qw(Exporter);
@EXPORT = qw(draw);

#_ Draw _______________________________________________________________
# Check its a drawing 
#______________________________________________________________________

sub check(@)
 {if (debug)
   {for my $t(@_)
     {confess "$t is not a drawing" unless ref($t) eq __PACKAGE__;
     }
   } 
  return (@_)
 }

#_ Draw _______________________________________________________________
# Test its a drawing 
#______________________________________________________________________

sub is(@)
 {for my $t(@_)
   {return 0 unless ref($t) eq __PACKAGE__;
   }
  'draw';
 }

#_ Draw _______________________________________________________________
# Constructor
#______________________________________________________________________

sub draw() {bless {}}

#_ Draw _______________________________________________________________
# View point 
#______________________________________________________________________

sub from($$)
 {my ($d) =         check(@_[0..0]); # Drawing 
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector

  $d->{from} = $v;
  $d;
 }

#_ Draw _______________________________________________________________
# Viewing this point
#______________________________________________________________________

sub to($$)
 {my ($d) =         check(@_[0..0]); # Drawing 
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector

  $d->{to} = $v;
  $d;
 }

#_ Draw _______________________________________________________________
# Horizontal horizon
#______________________________________________________________________

sub horizon($$)
 {my ($d) =         check(@_[0..0]); # Drawing 
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector

  $d->{horizon} = $v;
  $d;
 }

#_ Draw _______________________________________________________________
# Light source position
#______________________________________________________________________

sub light($$)
 {my ($d) =         check(@_[0..0]); # Drawing 
  my ($v) = Math::Zap::Vector::check(@_[1..1]); # Vector

  $d->{light} = $v;
  $d;
 }

#_ Draw _______________________________________________________________
# With controls
#______________________________________________________________________

sub withControls($)
 {my ($d) =         check(@_[0..0]); # Drawing 

  $d->{withControls} = 1;
  $d;
 }

#_ Draw _______________________________________________________________
# Show fission fragments
#______________________________________________________________________

sub showFissionFragments($)
 {my ($d) =         check(@_[0..0]); # Drawing 

  $d->{showFissionFragments} = 1;
  $d;
 }

#_ Draw _______________________________________________________________
# Draw this object
#______________________________________________________________________

sub object($$$)
 {my ($d) = check(@_[0..0]); # Drawing 
  my ($o) =       @_[1..1];  # Object to be drawn
  my ($c) =       @_[2..2];  # Color of object's surfaces

  if ($o->can('triangulate'))
   {push @{$d->{triangles}}, $o->triangulate($c);
   }
  else
   {die "Cannot draw $o";
   }
  $d;
 }

#_ Draw _______________________________________________________________
# Draw the complete object list
#______________________________________________________________________

sub done($)
 {my ($d) = check(@_[0..0]); # Drawing 
  &fission($d);
  &new($d);
 }

#_ Draw _______________________________________________________________
# Print the complete object list as a triangles in a reusable manner.
#______________________________________________________________________

sub print($)
 {my ($d) = check(@_[0..0]); # Drawing
  my $l = << 'END';
#!perl -w
use Math::Zap::Draw;
use Math::Zap::Color;
use Math::Zap::Triangle;
use Math::Zap::Vector;

draw
END
  $l .= '->from    ('. $d->{from}   ->print .")\n";
  $l .= '->to      ('. $d->{to}     ->print .")\n";
  $l .= '->horizon ('. $d->{horizon}->print .")\n";
  $l .= '->light   ('. $d->{light}  ->print .")\n";

  for my $p(@{$d->{triangles}}) # Triangulation
   {$l .= '  ->object('. $p->{triangle}->print .', \''. $p->{color}. "\')\n";
   }
  $l .= "->done;\n";
 }

#_ Draw _______________________________________________________________
# Fission the triangles that intersect
#______________________________________________________________________

sub fission($)
 {my ($d) = check(@_[0..0]);    # Drawing 
  my @P   = @{$d->{triangles}}; # Triangles to be fissoned
  my $tested;                   # Source triangles already tested

#_ Draw _______________________________________________________________
# Check each pair of triangles
#______________________________________________________________________

  L: for(;;)
   {for   (my $i = 0; $i < scalar(@P); ++$i)
     {my $p = $P[$i];
      next unless defined($p);

#_ Draw _______________________________________________________________
# Check against triangle 
#______________________________________________________________________

      for (my $j = $i+1; $j < scalar(@P); ++$j)
       {my $q = $P[$j];
        next unless defined($q);
        my ($t, @t, @T);

#_ Draw _______________________________________________________________
# Already tested
#______________________________________________________________________

        next if $tested->{$p->{plane}}{$q->{plane}};
        $tested->{$p->{plane}}{$q->{plane}} = 1;
        $tested->{$q->{plane}}{$p->{plane}} = 1;
        next if $p->{triangle}->parallel($q->{triangle});

#_ Draw _______________________________________________________________
# Divide intersecting triangles
#______________________________________________________________________

        @t = $p->{triangle}->divide($q->{triangle});
        @T = $q->{triangle}->divide($p->{triangle});

#_ Draw _______________________________________________________________
# Add divisions to list of triangles
#______________________________________________________________________

        next unless @t > 1 or @T > 1;
        delete $P[$i];
        delete $P[$j];

        push @P, {triangle=>$_, color=>$q->{color}, plane=>$q->{plane}} for(@t);
        push @P, {triangle=>$_, color=>$p->{color}, plane=>$p->{plane}} for(@T);
        next L;
       }
     }
    last;
   }

#_ Draw _______________________________________________________________
# Update list of triangles to be drawn
#______________________________________________________________________

  my @p;
  for my $p(@P)
   {push @p, $p if defined($p);
   } 
  $d->{triangles} = [@p];
 }

#_ Draw _______________________________________________________________
# New drawing
#______________________________________________________________________

sub new($)
 {my ($d) = check(@_[0..0]); # Drawing 
  &newCanvas ($d);
  &newControl($d);
  &drawing   ($d, 1);
  MainLoop;
 } 

#_ Draw _______________________________________________________________
# Canvas for drawing
#______________________________________________________________________

sub newCanvas($)
 {my ($d) = check(@_[0..0]); # Drawing 
  my $m = $d->{MainWindowCanvas}
        = new MainWindow;
  my $c = $d->{canvas}
        = $m->Canvas(-background=>'yellow')->pack(-expand=>1, -fill=>'both');

  $d->{canvas}{width}  = $c->cget(-width=>);
  $d->{canvas}{height} = $c->cget(-height=>);

  $c->CanvasBind('<Configure>' => [$d=>'configure', Ev('w'), Ev('h')]);
 }
 
#_ Draw _______________________________________________________________
# Controls for drawing
#______________________________________________________________________

sub newControl()
 {my ($d) = check(@_[0..0]);                   # Drawing 
  my  $m  = $d->{MainWindowControls} = new MainWindow;

  my $a11 = $d->{a11} = $m->Label(-text=>'View point');
  my $a12 = $d->{a12} = $m->Entry(-textvariable=>\$d->{from}->{x});
  my $a13 = $d->{a13} = $m->Entry(-textvariable=>\$d->{from}->{y});
  my $a14 = $d->{a14} = $m->Entry(-textvariable=>\$d->{from}->{z});
  my $a21 = $d->{a21} = $m->Label(-text=>'Looking to');
  my $a22 = $d->{a22} = $m->Entry(-textvariable=>\$d->{to}->{x});
  my $a23 = $d->{a23} = $m->Entry(-textvariable=>\$d->{to}->{y});
  my $a24 = $d->{a24} = $m->Entry(-textvariable=>\$d->{to}->{z});
  my $a31 = $d->{a31} = $m->Label(-text=>'Horizontal');
  my $a32 = $d->{a32} = $m->Entry(-textvariable=>\$d->{horizon}->{x});
  my $a33 = $d->{a33} = $m->Entry(-textvariable=>\$d->{horizon}->{y});
  my $a34 = $d->{a34} = $m->Entry(-textvariable=>\$d->{horizon}->{z});
  my $a41 = $d->{a41} = $m->Label(-text=>'Lit from');
  my $a42 = $d->{a42} = $m->Entry(-textvariable=>\$d->{light}->{x});
  my $a43 = $d->{a43} = $m->Entry(-textvariable=>\$d->{light}->{y});
  my $a44 = $d->{a44} = $m->Entry(-textvariable=>\$d->{light}->{z});
  my $a51 = $d->{a51} = $m->Button(-text=>'Redraw', -command=>sub{&drawing($d, 1)});
  my $a52 = $d->{a52} = $m->Button(-text=>'In');
  my $a53 = $d->{a53} = $m->Button(-text=>'Out');
  my $a54 = $d->{a54} = $m->Button(-text=>'Quit',   -command=>sub{exit(0)});

  $a11->grid($a12, $a13, $a14);
  $a21->grid($a22, $a23, $a24);
  $a31->grid($a32, $a33, $a34);
  $a41->grid($a42, $a43, $a44);
  $a51->grid($a52, $a53, $a54);
 }

#_ Draw _______________________________________________________________
# Configuration of canvas has been changed
#______________________________________________________________________

sub configure
 {my ($d)    = check(@_[0..0]);                # Drawing 
  my $c      = $d->{canvas};
  $d->{canvas}{width}  = $_[1];
  $d->{canvas}{height} = $_[2];
  &drawing($d, 0);
 } 

#_ Draw _______________________________________________________________
# New drawing of objects
#______________________________________________________________________

sub drawing($$)
 {my ($d)    = check(@_[0..0]);                # Drawing 
  my $zorder = shift;                          # Re-sort of zorder required?

#_ Draw _______________________________________________________________
# Locate background
#______________________________________________________________________

  my $from   = $d->{from};                     # View point
  my $lt     = $d->{light};                    # Light     
  my $to     = $d->{to};                       # View towards
  my $hz     = $d->{horizon};                  # Horizon  
  
  my $v = (($from-$to) x $hz)->norm;           # Vertical   in background plane
  my $h = ($v  x ($from-$to))->norm;           # Horizontal in background plane
  my $B = triangle($to, $to+$h, $to+$v);       # Background plane
  $d->{background} = $B;

  &zorder($d) if $zorder;                      # Partially order triangles from view point 
  $d->{canvas}->delete('all');                 # Clear canvas

#_ Draw _______________________________________________________________
# Dimensions of projected image
#______________________________________________________________________

  my ($mx, $Mx, $my, $My);
  for my $D(@{$d->{triangles}})
   {my $t = $B->project($D->{triangle}, $from); # Project onto background
    $D->{project} = $t;                         # Optimization - record for reuse

    my ($ax, $ay) = ($t->a->x, $t->a->y);
    my ($bx, $by) = ($t->b->x, $t->b->y);
    my ($cx, $cy) = ($t->c->x, $t->c->y);

    $mx = $ax if !defined($mx) or $mx > $ax;   
    $mx = $bx if !defined($mx) or $mx > $bx;   
    $mx = $cx if !defined($mx) or $mx > $cx;   
    $Mx = $ax if !defined($Mx) or $Mx < $ax;   
    $Mx = $bx if !defined($Mx) or $Mx < $bx;   
    $Mx = $cx if !defined($Mx) or $Mx < $cx;   

    $my = $ay if !defined($my) or $my > $ay;   
    $my = $by if !defined($my) or $my > $by;   
    $my = $cy if !defined($my) or $my > $cy;   
    $My = $ay if !defined($My) or $My < $ay;   
    $My = $by if !defined($My) or $My < $by;   
    $My = $cy if !defined($My) or $My < $cy;
   }

  my $cw = $d->{canvas}{width};
  my $ch = $d->{canvas}{height};

  my $sx = int($d->{canvas}{width} /($Mx-$mx));  
  my $sy = int($d->{canvas}{height}/($My-$my));
  my $s  = $d->{canvas}{scale} = ($sx < $sy ? $sx : $sy);

  my $dx = $d->{canvas}{dx} = -$mx * $s + ($cw - $s * ($Mx-$mx)) / 2;
  my $dy = $d->{canvas}{dy} =  $My * $s + ($ch - $s * ($My-$my)) / 2;

#_ Draw _______________________________________________________________
# Draw each triangle
#______________________________________________________________________

  for my $D(@{$d->{triangles}})
   {my $T     = $D->{triangle};
    my $color = $D->{color};
    my $p     = $D->{plane};
    my $t     = $D->{project};

# Coordinates of triangle to be drawn
    my @a = ($dx+$t->a->x*$s, $dy-$t->a->y*$s, 
             $dx+$t->b->x*$s, $dy-$t->b->y*$s,
             $dx+$t->c->x*$s, $dy-$t->c->y*$s,
             );
    push @a,  -outline=>'black' if defined($d->{showFissionFragments});

#_ Draw _______________________________________________________________
# Side towards/away from the light
#______________________________________________________________________

    my $fb = $T->frontInBehindZ($from, $lt);   

    if (!defined($fb) or $fb < 0)              # Towards light              
     {push @a, -fill=>$color;
      $d->{canvas}->createPolygon(@a);
      &shadows($d, $D);
     }
    else                                       # Away from light
     {$d->{canvas}->createPolygon(@a, -fill=>color($color)->dark);
     }                        
   }
 }

#_ Draw _______________________________________________________________
# Shadows from a point of illumination
#______________________________________________________________________

sub shadows($$)
 {my ($d)   = check(@_[0..0]);                           # Drawing 
  my ($p)   =      (@_[1..1]);                           # Current triangle to be drawn
  my $from  = $d->{from};                                # View point       
  my $to    = $d->{to};                                  # Look towards     
  my $light = $d->{light};                               # Position of light
  my $back  = $d->{background};                          # Background
  my $c     = $d->{canvas};                              # Canvas
  my $dx    = $d->{canvas}{dx};                          # Canvas center x
  my $dy    = $d->{canvas}{dy};                          # Canvas center y
  my $s     = $d->{canvas}{scale};                       # Scale factor

#_ Draw _______________________________________________________________
# Shadow each triangle
#______________________________________________________________________

  my @s;
  for my $q(@{$d->{triangles}})                                
   {next if $p == $q;                                    # Do not shadow self
    next if $p->{plane} == $q->{plane};                  # Do not shadow stuff in same plane
    my $t = $p->{triangle};                              # Shadowed  triangle
    my $T = $q->{triangle};                              # Shadowing triangle
#   next if $t->frontInBehindZ($from, $light) > 0;       # Check that plane view point and light

    my $b = $t->project($T, $light);                     # Project Shadowing triangle onto shadowed triangle
    my $d = Math::Zap::Triangle2::newnnc                            # Shadow in shadowed plane coordinates
     (vector2($b->a->x, $b->a->y),
      vector2($b->b->x, $b->b->y),
      vector2($b->c->x, $b->c->y)
     );
    my $D = Math::Zap::Triangle2::newnnc                            # Shadowed plane 
     (vector2(0,0),
      vector2(1,0),
      vector2(0,1)
     );
    return if $d->narrow();                              # Projected shadow  too narrow?
    return if $D->narrow();                              # Shadowed triangle too narrow?

    my @r = $d->ring($D);                                # Ring of common points 
    if (scalar(@r) > 2)                                  # Less than two - small intersection
     {my @a;
      for my $r(@r)                                      # Points of intersection current/shadowing triangle
       {my $sr = $t->convertPlaneToSpace($r);            # Convert intersection to space coords
        last if $T->frontInBehind($light, $sr) == 1;     # $t gives back of shadowing plane
        my $sb = $back->intersectionInPlane($from, $sr); # Project from view point onto background
        push @a, $dx+$sb->x*$s, $dy-$sb->y*$s;           # Save coordinates
       }

#_ Draw _______________________________________________________________
# Draw shadow
#______________________________________________________________________

      push @a, -outline=>color($p->{color})->dark, -fill=>color($p->{color})->dark;
      $c->createPolygon(@a);
     }
   } 
 }

#_ Draw _______________________________________________________________
# Z-order: order the fission triangles from the back ground to the
# point of view by:
# Compare each triangle with every other, recording for each triangle
# which triangles are behind it .
# Place all triangles with no triangles behind them with at the start of
# the order.  Reprocess the remainder until none left (success)
# or a cycle is detected (bad algorithm).
# The two triangles to be compared are projected on to the background:
# if their projections have no points in common they are unordered,
# otherwise use the distance to each triangle from the view point
# towards the common point as a measure of which is first.  fission()
# guarantees that no two triangles intersect, this algorithm should
# correctly order each pair of triangles.  
#______________________________________________________________________

sub zorder($)
 {my ($d) = check(@_[0..0]);       # Drawing

  my $from = $d->{from};           # View point
  my $back = $d->{background};     # Background
  my @P    = @{$d->{triangles}};   # Triangles to be drawn 

#_ Draw _______________________________________________________________
# Filter for useful triangles
#______________________________________________________________________

  my @o;
  for(my $ip = 0; $ip < @P; ++$ip)
   {my $t = $P[$ip]{triangle};
#   next unless $t->area > .1;     # Ignore small triangles
#   next if $t->narrow(0);

    $o{$ip} = {};
    push @o, $ip;
   }

#_ Draw _______________________________________________________________
# Relationship
#______________________________________________________________________

  for my $ip(@o)
   {my $t = $P[$ip]{triangle};

    for my $jp(@o)
     {next unless $ip < $jp;
      my $T = $P[$jp]{triangle};
      my $i = $back->project($t, $from);
      my $I = $back->project($T, $from);

      my $i2 = Math::Zap::Triangle2::newnnc(vector2($i->a->x, $i->a->y), vector2($i->b->x, $i->b->y), vector2($i->c->x, $i->c->y));
      my $I2 = Math::Zap::Triangle2::newnnc(vector2($I->a->x, $I->a->y), vector2($I->b->x, $I->b->y), vector2($I->c->x, $I->c->y));
#      next if $i2->narrow(0);
#      next if $I2->narrow(0);

      my @c = $i2->pointsInCommon($I2);
      next unless scalar(@c);

      for my $c(@c)
       {my $C = $back->convertPlaneToSpace($c);
        my $d = $t->distanceToPlaneAlongLine($from, $C);
        my $D = $T->distanceToPlaneAlongLine($from, $C);
        next if abs($d-$D) < 0.1;  # Points to close in space to disambiguate

        $o{$ip}{$jp} = 1 if $d < $D;  # Assumes order does not matter for coplanar triangles
        $o{$jp}{$ip} = 1 if $d > $D;  # Assumes order does not matter for coplanar triangles
        last;
       }
     } 
   }

#_ Draw _______________________________________________________________
# Order by relationship
#______________________________________________________________________

  my @p;
  for(;;)
   {my $n = 0;
    for my $i(sort(keys(%o)))
     {unless (keys(%{$o{$i}}))
       {push @p, $P[$i];
        delete $o{$i};
        ++$n; 
        for my $j(keys(%o))
         {delete $o{$j}{$i};
         }
       }
     }
    last unless $n;
   }
  keys(%o) == 0 or warn "Cycle present??";
  $d->{triangles} = [@p];
 }

#_ Draw _______________________________________________________________
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


