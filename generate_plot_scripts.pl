#!/usr/bin/perl

use strict;
use warnings;

# Generate all gnuplot scripts dynamically from method output files
# This allows plotting to work with any dataset

sub read_method_data {
   my ($filename) = @_;
   open(my $fh, '<', $filename) or return undef;
   
   my @funcs;
   my $xrange;
   my @plot_parts;
   
   while(<$fh>) {
      chomp;
      if(/^f_(\d+)_(\d+)\(x\) = (.+)$/) {
         push @funcs, {sec => $1, trace => $2, expr => $3};
      }
      elsif(/^set xrange \[([0-9.:]+)\]/) {
         $xrange = $1;
      }
      elsif(/^\s*\[([0-9.:]+)\]\s+f_(\d+)_(\d+)\(x-([0-9.]+)\)/) {
         push @plot_parts, {range => $1, sec => $2, trace => $3, offset => $4};
      }
   }
   close($fh);
   
   return {funcs => \@funcs, xrange => $xrange, parts => \@plot_parts};
}

# Read all method data
my %methods = (
   0 => {name => "Original", file => "__do_plot_method0.txt", color => "#FF0000"},
   1 => {name => "Monotone", file => "__do_plot_method1.txt", color => "#0000FF"},
   2 => {name => "Catmull-Rom", file => "__do_plot_method2.txt", color => "#00AA00"},
   4 => {name => "OPTIMAL", file => "__do_plot_optimal.txt", color => "#AA00AA"}
);

foreach my $num (keys %methods) {
   my $data = read_method_data($methods{$num}{file});
   $methods{$num}{data} = $data if $data;
}

# Generate plot_pulse_sections.gnuplot
print "Generating plot_pulse_sections.gnuplot...\n";
open(my $gp, '>', 'plot_pulse_sections.gnuplot') or die $!;

print $gp <<'HEADER';
# Plot showing sections in different colors for all methods in a 2x2 grid
set terminal pngcairo size 1800,1200 enhanced font 'Arial,12'
set output 'pulse_sections.png'

set multiplot layout 2,2 title "Altitude Pulse - Sections in Different Colors" font ",16"

# Common settings
set grid
HEADER

# Find xmax and yrange from first available method
my $xmax = 700;
my ($ymin, $ymax) = (0, 14);
foreach my $m (1, 2, 4, 0) {
   if($methods{$m}{data} && $methods{$m}{data}{xrange}) {
      my $xr = $methods{$m}{data}{xrange};
      if($xr =~ /\[0:([0-9.]+)\]/) {
         $xmax = $1;
      }
      # Calculate yrange from function constants (d parameter)
      if($methods{$m}{data}{funcs}) {
         foreach my $f (@{$methods{$m}{data}{funcs}}) {
            if($f->{expr} =~ /\+\s*([-0-9.]+)\s*$/) {
               my $y = $1;
               $ymin = $y if !defined($ymin) || $y < $ymin;
               $ymax = $y if !defined($ymax) || $y > $ymax;
            }
         }
      }
      last if $xmax != 700;
   }
}
# Add 10% padding to yrange
my $ypadding = ($ymax - $ymin) * 0.1;
$ymin -= $ypadding;
$ymax += $ypadding;
print $gp "set xrange [0:$xmax]\n";
print $gp "set yrange [$ymin:$ymax]\n";
print $gp "set xlabel \"Distance (m)\" font \",12\"\n";
print $gp "set ylabel \"Altitude (m)\" font \",12\"\n\n";

# Section colors
my @sec_colors = ("#FF0000", "#FF8800", "#FFFF00", "#00FF00", "#00FFFF", "#0088FF", "#FF00FF");

foreach my $num (0, 1, 2, 4) {
   next unless $methods{$num}{data};
   my $data = $methods{$num}{data};
   next unless $data->{parts} && @{$data->{parts}};  # Skip if no plot data
   
   my $star = $num == 4 ? " ⭐" : "";
   
   print $gp "# Method $num: $methods{$num}{name}\n";
   foreach my $f (@{$data->{funcs}}) {
      print $gp "f$num\_$f->{sec}_$f->{trace}(x) = $f->{expr}\n";
   }
   print $gp "\nset title \"Method $num: $methods{$num}{name}$star\" font \",14\"\n";
   print $gp "plot sample \\\n";
   
   my $first = 1;
   foreach my $p (@{$data->{parts}}) {
      print $gp ", \\\n" unless $first;
      $first = 0;
      my $color = $sec_colors[$p->{sec}] || "#888888";
      print $gp "  [$p->{range}] f$num\_$p->{sec}_$p->{trace}(x-$p->{offset}) with lines lw 3 lc rgb \"$color\" title \"Sec $p->{sec}\"";
   }
   print $gp "\n\n";
}

print $gp "unset multiplot\n";
close($gp);

# Generate plot_zoom_transition.gnuplot
print "Generating plot_zoom_transition.gnuplot...\n";
open($gp, '>', 'plot_zoom_transition.gnuplot') or die $!;

print $gp <<'HEADER';
# Zoomed-in plot of the rising transition (1m → 12m)
set terminal pngcairo size 1800,1200 enhanced font 'Arial,12'
set output 'zoom_transition.png'

set multiplot layout 2,2 title "Zoomed Transition: 1m → 12m (around 195m)" font ",16"

# Common settings - zoom in on the transition
set grid
set xrange [150:250]
set yrange [0:13]
set xlabel "Distance (m)" font ",12"
set ylabel "Altitude (m)" font ",12"

HEADER

foreach my $num (0, 1, 2, 4) {
   next unless $methods{$num}{data};
   my $data = $methods{$num}{data};
   next unless $data->{parts} && @{$data->{parts}};  # Skip if no plot data
   
   my $star = $num == 4 ? " ⭐" : "";
   
   print $gp "# Method $num: $methods{$num}{name}\n";
   # Load functions for first 3 sections (may need more than 3 functions)
   my %loaded_secs;
   for(my $i = 0; $i < @{$data->{funcs}} && keys(%loaded_secs) < 3; $i++) {
      my $f = $data->{funcs}[$i];
      print $gp "f$num\_$f->{sec}_$f->{trace}(x) = $f->{expr}\n";
      $loaded_secs{$f->{sec}} = 1;
   }
   
   print $gp "\nset title \"Method $num: $methods{$num}{name}$star\" font \",14\"\n";
   print $gp "plot sample \\\n";
   
   my $first = 1;
   for(my $i = 0; $i < 3 && $i < @{$data->{parts}}; $i++) {
      my $p = $data->{parts}[$i];
      print $gp ", \\\n" unless $first;
      $first = 0;
      my $color = $sec_colors[$i];
      my $label = $i == 0 ? "flat 1m" : $i == 1 ? "transition" : "flat 12m";
      print $gp "  [$p->{range}] f$num\_$p->{sec}_$p->{trace}(x-$p->{offset}) with lines lw 4 lc rgb \"$color\" title \"Sec $i ($label)\"";
   }
   print $gp "\n\n";
}

print $gp "unset multiplot\n";
close($gp);

# Generate plot_zoom_junction.gnuplot (junction at first transition)
print "Generating plot_zoom_junction.gnuplot...\n";
open($gp, '>', 'plot_zoom_junction.gnuplot') or die $!;

# Find the junction point (end of first section)
my $junction1 = 151.6;  # Default
if($methods{1}{data} && @{$methods{1}{data}{parts}} > 1) {
   my $range = $methods{1}{data}{parts}[1]{range};
   ($junction1) = split(/:/, $range);
} elsif($methods{0}{data} && @{$methods{0}{data}{parts}} > 1) {
   my $range = $methods{0}{data}{parts}[1]{range};
   ($junction1) = split(/:/, $range);
}

print $gp <<"HEADER";
# Super zoomed-in plot of the junction between Section 0 and Section 1
set terminal pngcairo size 1800,1200 enhanced font 'Arial,12'
set output 'zoom_junction.png'

set multiplot layout 2,2 title "Section Junction: Sec 0 → Sec 1 (at ${junction1}m)" font ",16"

# Common settings - super zoom on the junction
set grid
set xrange [@{[$junction1-6]}:@{[$junction1+8]}]
set yrange [0.5:2.5]
set xlabel "Distance (m)" font ",12"
set ylabel "Altitude (m)" font ",12"

HEADER

foreach my $num (0, 1, 2, 4) {
   next unless $methods{$num}{data};
   my $data = $methods{$num}{data};
   next unless $data->{parts} && @{$data->{parts}};  # Skip if no plot data
   
   my $star = $num == 4 ? " ⭐" : "";
   
   print $gp "# Method $num: $methods{$num}{name}\n";
   # Load functions for first 2 sections
   my %loaded_secs;
   for(my $i = 0; $i < @{$data->{funcs}} && keys(%loaded_secs) < 2; $i++) {
      my $f = $data->{funcs}[$i];
      print $gp "f$num\_$f->{sec}_$f->{trace}(x) = $f->{expr}\n";
      $loaded_secs{$f->{sec}} = 1;
   }
   
   print $gp "\nset title \"Method $num: $methods{$num}{name}$star\" font \",14\"\n";
   print $gp "plot sample \\\n";
   
   for(my $i = 0; $i < 2 && $i < @{$data->{parts}}; $i++) {
      my $p = $data->{parts}[$i];
      print $gp ", \\\n" if $i > 0;
      my $color = $sec_colors[$i];
      my $label = $i == 0 ? "flat 1m" : "rising";
      print $gp "  [$p->{range}] f$num\_$p->{sec}_$p->{trace}(x-$p->{offset}) with lines lw 5 lc rgb \"$color\" title \"Sec $i ($label)\"";
   }
   print $gp ", \\\n  $junction1 with lines lw 2 lc rgb \"black\" dt 2 title \"Junction at ${junction1}m\"\n\n";
}

print $gp "unset multiplot\n";
close($gp);

# Generate plot_zoom_junction2.gnuplot (junction at end of transition)
print "Generating plot_zoom_junction2.gnuplot...\n";
open($gp, '>', 'plot_zoom_junction2.gnuplot') or die $!;

# Find the junction point (end of transition section)
my $junction2 = 195.4;  # Default
if($methods{1}{data} && @{$methods{1}{data}{parts}} > 2) {
   my $range = $methods{1}{data}{parts}[2]{range};
   ($junction2) = split(/:/, $range);
} elsif($methods{0}{data} && @{$methods{0}{data}{parts}} > 2) {
   my $range = $methods{0}{data}{parts}[2]{range};
   ($junction2) = split(/:/, $range);
}

print $gp <<"HEADER";
# Super zoomed-in plot of the junction between Section 1 and Section 2
set terminal pngcairo size 1800,1200 enhanced font 'Arial,12'
set output 'zoom_junction2.png'

set multiplot layout 2,2 title "Section Junction: Sec 1 → Sec 2 (at ${junction2}m)" font ",16"

# Common settings - super zoom on the junction
set grid
set xrange [@{[$junction2-5]}:@{[$junction2+10]}]
set yrange [11:13]
set xlabel "Distance (m)" font ",12"
set ylabel "Altitude (m)" font ",12"

HEADER

foreach my $num (0, 1, 2, 4) {
   next unless $methods{$num}{data};
   my $data = $methods{$num}{data};
   next unless $data->{parts} && @{$data->{parts}};  # Skip if no plot data
   
   my $star = $num == 4 ? " ⭐" : "";
   
   print $gp "# Method $num: $methods{$num}{name}\n";
   # Load functions for sections 1 and 2
   my %loaded_secs;
   for(my $i = 0; $i < @{$data->{funcs}} && keys(%loaded_secs) < 3; $i++) {
      my $f = $data->{funcs}[$i];
      if($f->{sec} >= 1 && $f->{sec} <= 2) {
         print $gp "f$num\_$f->{sec}_$f->{trace}(x) = $f->{expr}\n";
         $loaded_secs{$f->{sec}} = 1;
      }
   }
   
   print $gp "\nset title \"Method $num: $methods{$num}{name}$star\" font \",14\"\n";
   print $gp "plot sample \\\n";
   
   for(my $i = 1; $i < 3 && $i < @{$data->{parts}}; $i++) {
      my $p = $data->{parts}[$i];
      print $gp ", \\\n" if $i > 1;
      my $color = $sec_colors[$i];
      my $label = $i == 1 ? "rising" : "flat 12m";
      print $gp "  [$p->{range}] f$num\_$p->{sec}_$p->{trace}(x-$p->{offset}) with lines lw 5 lc rgb \"$color\" title \"Sec $i ($label)\"";
   }
   print $gp ", \\\n  $junction2 with lines lw 2 lc rgb \"black\" dt 2 title \"Junction at ${junction2}m\"\n\n";
}

print $gp "unset multiplot\n";
close($gp);

print "\n✓ All gnuplot scripts generated successfully!\n";
print "  - plot_pulse_sections.gnuplot\n";
print "  - plot_zoom_transition.gnuplot\n";
print "  - plot_zoom_junction.gnuplot\n";
print "  - plot_zoom_junction2.gnuplot\n\n";
