#!/usr/bin/perl

use strict;
use warnings;

# Given parameters
# Domain: [-5, 5], split at x=3
# Need to transform to [0, L] domain
my $x_start = -5;
my $x_split = 3;
my $x_end = 5;
my $L = $x_end - $x_start;  # 10
my $L_1 = $x_split - $x_start;  # 8
my $L_2 = $x_end - $x_split;  # 2

# Original function: f(x) = x³ - 15x - 4
# In transformed domain [0, L]: f(t) where t = x + 5, so x = t - 5
# f(t-5) = (t-5)³ - 15(t-5) - 4
# Expand: t³ - 15t² + 75t - 125 - 15t + 75 - 4
# = t³ - 15t² + 60t - 54
my $a = 1;
my $b = -15;
my $c = 60;
my $d = -54;

print "Original Section:\n";
print "  Domain: [0, $L]\n";
print "  f(x) = ${a}x³ + ${b}x² + ${c}x + $d\n\n";

# Calculate split point values
my $Y_split = $a * $L_1**3 + $b * $L_1**2 + $c * $L_1 + $d;
my $S_split = 3 * $a * $L_1**2 + 2 * $b * $L_1 + $c;

print "Split Point (x = $L_1):\n";
print "  Y_split = $Y_split\n";
print "  S_split = $S_split\n\n";

# Calculate end point values
my $Y_L = $a * $L**3 + $b * $L**2 + $c * $L + $d;
my $S_L = 3 * $a * $L**2 + 2 * $b * $L + $c;

print "End Point (x = $L):\n";
print "  Y_L = $Y_L\n";
print "  S_L = $S_L\n\n";

# Section 1: [0, L_1]
my $d_1 = $d;
my $c_1 = $c;
my $a_1 = (1.0 / $L_1**3) * ($L_1 * ($c + $S_split) + 2 * ($d - $Y_split));
my $b_1 = (1.0 / $L_1**2) * ($L_1 * (-2 * $c - $S_split) - 3 * ($d - $Y_split));

print "Section 1: [0, $L_1]\n";
print "  f₁(x) = ${a_1}x³ + ${b_1}x² + ${c_1}x + $d_1\n";
print "  a₁ = $a_1\n";
print "  b₁ = $b_1\n";
print "  c₁ = $c_1\n";
print "  d₁ = $d_1\n\n";

# Section 2: [L_1, L] (using local coordinate u = x - L_1)
my $d_2 = $Y_split;
my $c_2 = $S_split;
my $a_2 = (1.0 / $L_2**3) * ($L_2 * ($S_split + $S_L) + 2 * ($Y_split - $Y_L));
my $b_2 = (1.0 / $L_2**2) * ($L_2 * (-2 * $S_split - $S_L) - 3 * ($Y_split - $Y_L));

print "Section 2: [$L_1, $L] (local coordinate u = x - $L_1)\n";
print "  f₂(u) = ${a_2}u³ + ${b_2}u² + ${c_2}u + $d_2\n";
print "  a₂ = $a_2\n";
print "  b₂ = $b_2\n";
print "  c₂ = $c_2\n";
print "  d₂ = $d_2\n\n";

# Verify continuity at split point
my $f1_at_L1 = $a_1 * $L_1**3 + $b_1 * $L_1**2 + $c_1 * $L_1 + $d_1;
my $f2_at_0 = $d_2;
my $f1_prime_at_L1 = 3 * $a_1 * $L_1**2 + 2 * $b_1 * $L_1 + $c_1;
my $f2_prime_at_0 = $c_2;

print "Verification at split point (x = $L_1):\n";
print "  f₁($L_1) = $f1_at_L1\n";
print "  f₂(0) = $f2_at_0\n";
print "  Position continuous: " . (abs($f1_at_L1 - $f2_at_0) < 1e-10 ? "✓" : "✗") . "\n";
print "  f₁'($L_1) = $f1_prime_at_L1\n";
print "  f₂'(0) = $f2_prime_at_0\n";
print "  Slope continuous: " . (abs($f1_prime_at_L1 - $f2_prime_at_0) < 1e-10 ? "✓" : "✗") . "\n\n";

# Verify end point
my $f2_at_L2 = $a_2 * $L_2**3 + $b_2 * $L_2**2 + $c_2 * $L_2 + $d_2;
my $f2_prime_at_L2 = 3 * $a_2 * $L_2**2 + 2 * $b_2 * $L_2 + $c_2;

print "Verification at end point (x = $L):\n";
print "  f₂($L_2) = $f2_at_L2\n";
print "  Original f($L) = $Y_L\n";
print "  Position matches: " . (abs($f2_at_L2 - $Y_L) < 1e-10 ? "✓" : "✗") . "\n";
print "  f₂'($L_2) = $f2_prime_at_L2\n";
print "  Original f'($L) = $S_L\n";
print "  Slope matches: " . (abs($f2_prime_at_L2 - $S_L) < 1e-10 ? "✓" : "✗") . "\n\n";

# Create gnuplot script
open(my $gp, '>', 'split_section_plot.gnuplot') or die "Cannot create gnuplot file: $!";

print $gp "set terminal pngcairo size 1200,800 enhanced font 'Arial,12'\n";
print $gp "set output 'split_section_comparison.png'\n";
print $gp "set multiplot layout 2,1 title 'Section Split Comparison'\n\n";

print $gp "# Define functions in original x-domain\n";
print $gp "# Original: f(x) = x³ - 15x - 4\n";
print $gp "f_original(x) = x**3 - 15*x - 4\n";
print $gp "# Transform to t-domain: t = x - ($x_start)\n";
print $gp "f1_t(t) = $a_1*t**3 + $b_1*t**2 + $c_1*t + $d_1\n";
print $gp "f2_t(t) = $a_2*(t-$L_1)**3 + $b_2*(t-$L_1)**2 + $c_2*(t-$L_1) + $d_2\n";
print $gp "# Map back to x-domain\n";
print $gp "f1(x) = f1_t(x - ($x_start))\n";
print $gp "f2(x) = f2_t(x - ($x_start))\n\n";

print $gp "# Plot 1: All curves together\n";
print $gp "set title 'Original vs Split Sections (x³ - 15x - 4)'\n";
print $gp "set xlabel 'x'\n";
print $gp "set ylabel 'f(x)'\n";
print $gp "set grid\n";
print $gp "set key top left\n";
print $gp "plot [$x_start:$x_end] f_original(x) with lines lw 3 lc rgb 'blue' title 'Original f(x)', \\\n";
print $gp "     [$x_start:$x_split] f1(x) with lines lw 2 lc rgb 'red' title 'Section 1: f₁(x)', \\\n";
print $gp "     [$x_split:$x_end] f2(x) with lines lw 2 lc rgb 'green' title 'Section 2: f₂(x)'\n\n";

print $gp "# Plot 2: Error/difference\n";
print $gp "set title 'Difference: Split Sections - Original (should be zero)'\n";
print $gp "set xlabel 'x'\n";
print $gp "set ylabel 'Error'\n";
print $gp "set grid\n";
print $gp "set key top left\n";
print $gp "set format y '%.2e'\n";
print $gp "set xrange [$x_start:$x_end]\n";
print $gp "plot [$x_start:$x_split] f1(x) - f_original(x) with lines lw 2 lc rgb 'red' title 'Section 1 error', \\\n";
print $gp "     [$x_split:$x_end] f2(x) - f_original(x) with lines lw 2 lc rgb 'green' title 'Section 2 error'\n\n";

print $gp "unset multiplot\n";

close($gp);

print "Gnuplot script created: split_section_plot.gnuplot\n";
print "Run: gnuplot split_section_plot.gnuplot\n";
print "Output: split_section_comparison.png\n";
