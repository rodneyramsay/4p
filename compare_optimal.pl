#!/usr/bin/perl

use strict;
use warnings;

# Script to compare all methods including the new optimal algorithm

my $input_file = $ARGV[0];

unless($input_file) {
   print "Usage: compare_optimal.pl <input_file>\n";
   print "Compares all smoothing methods including the new optimal algorithm.\n";
   exit(1);
}

unless(-f $input_file) {
   die "Error: Input file '$input_file' not found\n";
}

print "=" x 70 . "\n";
print "COMPARING ALL SMOOTHING METHODS\n";
print "=" x 70 . "\n\n";

# Method 0: Original (baseline)
print "Running Method 0: Original (baseline)...\n";
system("./4psi -m 0 $input_file > /dev/null 2>&1");
system("mv __do_plot_all.txt __do_plot_method0.txt");
system("mv __gtk_csv.TXT __gtk_csv_method0.TXT");
print "  ✓ Complete\n\n";

# Method 1: Monotone (Fritsch-Carlson)
print "Running Method 1: Monotone (no overshoot, less smooth)...\n";
system("./4psi -m 1 $input_file > /dev/null 2>&1");
system("mv __do_plot_all.txt __do_plot_method1.txt");
system("mv __gtk_csv.TXT __gtk_csv_method1.TXT");
print "  ✓ Complete\n\n";

# Method 2: Catmull-Rom (tension = 0.3)
print "Running Method 2: Catmull-Rom (tension=0.3)...\n";
system("./4psi -m 2 -t 0.3 $input_file > /dev/null 2>&1");
system("mv __do_plot_all.txt __do_plot_method2.txt");
system("mv __gtk_csv.TXT __gtk_csv_method2.TXT");
print "  ✓ Complete\n\n";

# Method 3: Limited slopes
print "Running Method 3: Limited slopes...\n";
system("./4psi -m 3 $input_file > /dev/null 2>&1");
system("mv __do_plot_all.txt __do_plot_method3.txt");
system("mv __gtk_csv.TXT __gtk_csv_method3.TXT");
print "  ✓ Complete\n\n";

# Method 4: Optimal (new - maximum smoothness, optimal overshoot)
print "Running Method 4: OPTIMAL (max smoothness, optimal overshoot)...\n";
system("./4psi -m 4 $input_file > /dev/null 2>&1");
system("mv __do_plot_all.txt __do_plot_optimal.txt");
system("mv __gtk_csv.TXT __gtk_csv_optimal.TXT");
print "  ✓ Complete\n\n";

# Create comprehensive comparison gnuplot script
open(my $gp, '>', 'compare_optimal.gnuplot') or die "Cannot create gnuplot script: $!\n";

print $gp <<'GNUPLOT_HEADER';
# Comprehensive comparison of all smoothing methods
set terminal pngcairo size 1800,1200 enhanced font 'Arial,10'
set output 'comparison_optimal.png'

set multiplot layout 3,2 title "Altitude Smoothing Methods Comparison" font ",14"

# Common settings
set grid
set key top left

GNUPLOT_HEADER

# Read the plot files to extract function definitions and plot commands
my @methods = (
   {num => 0, name => "Original (Overshoot)", file => "__do_plot_method0.txt", color => "red"},
   {num => 1, name => "Monotone (No Overshoot)", file => "__do_plot_method1.txt", color => "blue"},
   {num => 2, name => "Catmull-Rom (t=0.3)", file => "__do_plot_method2.txt", color => "green"},
   {num => 3, name => "Limited Slopes", file => "__do_plot_method3.txt", color => "orange"},
   {num => 4, name => "OPTIMAL (Smooth+No Overshoot)", file => "__do_plot_optimal.txt", color => "purple"}
);

# Extract functions and plot commands from each method
foreach my $method (@methods) {
   open(my $fh, '<', $method->{file}) or next;
   my @funcs;
   my $xrange;
   my @plot_parts;
   
   while(<$fh>) {
      chomp;
      if(/^f_\d+_\d+\(x\) = /) {
         push @funcs, $_;
      }
      elsif(/^set xrange/) {
         $xrange = $_;
      }
      elsif(/^\s*\[([0-9.:]+)\]\s+(f_\d+_\d+\(x-[0-9.]+\))/) {
         # Extract range and function call
         push @plot_parts, "[$1] $2";
      }
   }
   close($fh);
   
   $method->{functions} = \@funcs;
   $method->{xrange} = $xrange;
   $method->{plot_parts} = \@plot_parts;
}

# Plot each method in its own subplot
foreach my $method (@methods) {
   # Skip if no data was loaded
   next unless $method->{plot_parts} && @{$method->{plot_parts}};
   
   print $gp "\n# Method $method->{num}: $method->{name}\n";
   print $gp "set title \"Method $method->{num}: $method->{name}\"\n";
   print $gp "set xlabel \"Distance (m)\"\n";
   print $gp "set ylabel \"Altitude (m)\"\n";
   print $gp $method->{xrange} if $method->{xrange};
   print $gp "\n";
   
   # Write function definitions
   foreach my $func (@{$method->{functions}}) {
      print $gp $func . "\n";
   }
   print $gp "\n";
   
   # Create plot command with proper ranges
   print $gp "plot ";
   my $first = 1;
   foreach my $part (@{$method->{plot_parts}}) {
      print $gp ", " unless $first;
      $first = 0;
      print $gp "$part with lines lw 2 lc rgb \"$method->{color}\" notitle";
   }
   print $gp "\n";
}

# Comparison plot - overlay all methods
print $gp "\n# Overlay comparison\n";
print $gp "set title \"All Methods Overlaid\"\n";
print $gp "set xlabel \"Distance (m)\"\n";
print $gp "set ylabel \"Altitude (m)\"\n";
# Find first method with xrange
foreach my $m (@methods) {
   if($m->{xrange}) {
      print $gp $m->{xrange};
      last;
   }
}
print $gp "\n";

# Write all function definitions with unique names
foreach my $method (@methods) {
   next unless $method->{functions};
   foreach my $func (@{$method->{functions}}) {
      my $newfunc = $func;
      $newfunc =~ s/^f_/f$method->{num}_/;
      print $gp $newfunc . "\n";
   }
}
print $gp "\n";

# Create overlay plot with proper ranges
print $gp "plot ";
my $first = 1;
foreach my $method (@methods) {
   next unless $method->{plot_parts} && @{$method->{plot_parts}};
   foreach my $part (@{$method->{plot_parts}}) {
      my $newpart = $part;
      $newpart =~ s/f_/f$method->{num}_/;
      print $gp ", " unless $first;
      $first = 0;
      print $gp "$newpart with lines lw 2 lc rgb \"$method->{color}\"";
      if($part eq $method->{plot_parts}->[0]) {
         # Add title only for first segment
         print $gp " title \"$method->{name}\"";
      } else {
         print $gp " notitle";
      }
   }
}
print $gp "\n";

print $gp "\nunset multiplot\n";
close($gp);

print "=" x 70 . "\n";
print "COMPARISON COMPLETE\n";
print "=" x 70 . "\n\n";

print "Generated files:\n";
print "  - comparison_optimal.gnuplot (gnuplot script)\n";
print "  - __do_plot_method0.txt (original)\n";
print "  - __do_plot_method1.txt (monotone)\n";
print "  - __do_plot_method2.txt (catmull-rom)\n";
print "  - __do_plot_method3.txt (limited)\n";
print "  - __do_plot_optimal.txt (OPTIMAL)\n\n";

print "To view the comparison:\n";
print "  gnuplot compare_optimal.gnuplot\n";
print "  (view comparison_optimal.png)\n\n";

print "Method Summary:\n";
print "  0: Original       - Smooth but overshoots\n";
print "  1: Monotone       - No overshoot but less smooth\n";
print "  2: Catmull-Rom    - Balanced with tension control\n";
print "  3: Limited        - Simple constraint-based\n";
print "  4: OPTIMAL        - Maximum smoothness + optimal overshoot ⭐\n\n";
