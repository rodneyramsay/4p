#!/usr/bin/perl
#
# Parameter Sweep Script for 4psi
# Generates plots comparing different smoothing and tension values
#

use strict;
use warnings;

# Check for input file
if (@ARGV != 1) {
    print "Usage: $0 <input_file>\n";
    print "Example: $0 alt_mytrack.txt\n";
    exit 1;
}

my $input_file = $ARGV[0];

unless (-f $input_file) {
    die "Error: Input file '$input_file' not found\n";
}

print "=" x 70 . "\n";
print "4PSI PARAMETER SWEEP\n";
print "=" x 70 . "\n";
print "Input file: $input_file\n\n";

# Create output directory for sweep results
my $sweep_dir = "parameter_sweep";
mkdir $sweep_dir unless -d $sweep_dir;

# ============================================================================
# SWEEP 1: Method 4 (Harmonic Mean) - Smoothing Factor
# ============================================================================
print "\n[1/3] Sweeping Harmonic Mean method (4) - Smoothing factor...\n";
print "-" x 70 . "\n";

my @smoothing_values = (2.0, 4.0, 6.0, 8.0, 10.0, 12.0);
my $alpha = 0.85;  # Keep alpha constant

foreach my $s (@smoothing_values) {
    my $label = sprintf("method4_s%.1f_a%.2f", $s, $alpha);
    print "  Running: method=4, smoothing=$s, alpha=$alpha\n";
    
    system("./4psi -m 4 -s $s -t $alpha $input_file > /dev/null 2>&1");
    
    # Save outputs with descriptive names
    system("cp __gtk_csv.TXT $sweep_dir/${label}_gtk.TXT");
    system("cp __do_plot_all.txt $sweep_dir/${label}_plot.txt");
}

# ============================================================================
# SWEEP 2: Method 4 (Harmonic Mean) - Alpha Parameter
# ============================================================================
print "\n[2/3] Sweeping Harmonic Mean method (4) - Alpha parameter...\n";
print "-" x 70 . "\n";

my @alpha_values = (0.5, 0.65, 0.75, 0.85, 0.95);
my $smoothing = 8.0;  # Keep smoothing constant

foreach my $a (@alpha_values) {
    my $label = sprintf("method4_s%.1f_a%.2f", $smoothing, $a);
    print "  Running: method=4, smoothing=$smoothing, alpha=$a\n";
    
    system("./4psi -m 4 -s $smoothing -t $a $input_file > /dev/null 2>&1");
    
    # Save outputs
    system("cp __gtk_csv.TXT $sweep_dir/${label}_gtk.TXT");
    system("cp __do_plot_all.txt $sweep_dir/${label}_plot.txt");
}

# ============================================================================
# SWEEP 3: Method 2 (Catmull-Rom) - Tension Parameter
# ============================================================================
print "\n[3/3] Sweeping Catmull-Rom method (2) - Tension parameter...\n";
print "-" x 70 . "\n";

my @tension_values = (0.0, 0.2, 0.4, 0.6, 0.8, 1.0);
my $smooth_cr = 4.0;  # Standard smoothing for Catmull-Rom

foreach my $t (@tension_values) {
    my $label = sprintf("method2_s%.1f_t%.2f", $smooth_cr, $t);
    print "  Running: method=2, smoothing=$smooth_cr, tension=$t\n";
    
    system("./4psi -m 2 -s $smooth_cr -t $t $input_file > /dev/null 2>&1");
    
    # Save outputs
    system("cp __gtk_csv.TXT $sweep_dir/${label}_gtk.TXT");
    system("cp __do_plot_all.txt $sweep_dir/${label}_plot.txt");
}

# ============================================================================
# Generate Comparison Gnuplot Script
# ============================================================================
print "\n" . "=" x 70 . "\n";
print "Generating comparison plots...\n";
print "=" x 70 . "\n";

# Create gnuplot script for smoothing factor comparison
open(my $gp1, '>', "$sweep_dir/compare_smoothing.gnuplot") or die $!;
print $gp1 <<'GNUPLOT';
set terminal pngcairo size 1600,1200 enhanced font 'Arial,12'
set output 'parameter_sweep/smoothing_comparison.png'

set multiplot layout 3,2 title "Harmonic Mean Method: Smoothing Factor Comparison (α=0.85)"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each smoothing value
smoothing_values = "2.0 4.0 6.0 8.0 10.0 12.0"

do for [i=1:6] {
    s = word(smoothing_values, i)
    filename = sprintf("parameter_sweep/method4_s%s_a0.85_plot.txt", s)
    set title sprintf("Smoothing = %s", s)
    
    # This will plot the first trace from the generated plot file
    # We'll need to extract the actual data plotting commands
    load filename
}

unset multiplot
GNUPLOT
close($gp1);

# Create gnuplot script for alpha comparison
open(my $gp2, '>', "$sweep_dir/compare_alpha.gnuplot") or die $!;
print $gp2 <<'GNUPLOT';
set terminal pngcairo size 1600,1000 enhanced font 'Arial,12'
set output 'parameter_sweep/alpha_comparison.png'

set multiplot layout 2,3 title "Harmonic Mean Method: Alpha Parameter Comparison (smoothing=8.0)"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each alpha value
alpha_values = "0.50 0.65 0.75 0.85 0.95"

do for [i=1:5] {
    a = word(alpha_values, i)
    filename = sprintf("parameter_sweep/method4_s8.0_a%s_plot.txt", a)
    set title sprintf("Alpha = %s", a)
    
    load filename
}

unset multiplot
GNUPLOT
close($gp2);

# Create gnuplot script for tension comparison
open(my $gp3, '>', "$sweep_dir/compare_tension.gnuplot") or die $!;
print $gp3 <<'GNUPLOT';
set terminal pngcairo size 1600,1200 enhanced font 'Arial,12'
set output 'parameter_sweep/tension_comparison.png'

set multiplot layout 3,2 title "Catmull-Rom Method: Tension Parameter Comparison (smoothing=4.0)"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each tension value
tension_values = "0.00 0.20 0.40 0.60 0.80 1.00"

do for [i=1:6] {
    t = word(tension_values, i)
    filename = sprintf("parameter_sweep/method2_s4.0_t%s_plot.txt", t)
    set title sprintf("Tension = %s", t)
    
    load filename
}

unset multiplot
GNUPLOT
close($gp3);

print "\n" . "=" x 70 . "\n";
print "PARAMETER SWEEP COMPLETE!\n";
print "=" x 70 . "\n";
print "\nResults saved in: $sweep_dir/\n\n";
print "Generated files:\n";
print "  - Individual outputs: ${sweep_dir}/*_gtk.TXT and *_plot.txt\n";
print "  - Comparison scripts: ${sweep_dir}/compare_*.gnuplot\n";
print "\nTo view comparison plots, run:\n";
print "  gnuplot $sweep_dir/compare_smoothing.gnuplot\n";
print "  gnuplot $sweep_dir/compare_alpha.gnuplot\n";
print "  gnuplot $sweep_dir/compare_tension.gnuplot\n";
print "\nOr view individual plots:\n";
print "  gnuplot $sweep_dir/method4_s8.0_a0.85_plot.txt\n";
print "\n";
