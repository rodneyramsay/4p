#!/usr/bin/perl
#
# Create visual comparison plots from parameter sweep results
# This script generates overlay plots to compare different parameter values
#

use strict;
use warnings;

if (@ARGV != 1) {
    print "Usage: $0 <sweep_directory>\n";
    print "Example: $0 parameter_sweep\n";
    exit 1;
}

my $sweep_dir = $ARGV[0];

unless (-d $sweep_dir) {
    die "Error: Directory '$sweep_dir' not found\n";
}

print "Creating comparison plots from: $sweep_dir\n\n";

# ============================================================================
# Extract data from GTK CSV files for plotting
# ============================================================================

sub extract_altitude_curve {
    my ($gtk_file, $num_points) = @_;
    $num_points //= 200;  # Default number of points to sample
    
    open(my $fh, '<', $gtk_file) or die "Cannot open $gtk_file: $!";
    
    my @sections;
    my $current_section = {};
    
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;
        
        # Parse CSV: section, length_tics, d, a, b, c, gradient_angle
        my @fields = split(/,/, $line);
        next unless @fields >= 6;
        
        my ($sec, $len, $d, $a, $b, $c) = @fields[0..5];
        
        # Skip header or invalid lines
        next unless $len =~ /^-?\d+\.?\d*$/;
        
        push @sections, {
            section => $sec,
            length => $len,
            d => $d,
            a => $a,
            b => $b,
            c => $c
        };
    }
    close($fh);
    
    # Generate points along the curve
    my @points;
    my $x_offset = 0;
    
    foreach my $sec (@sections) {
        my $L = $sec->{length};
        my $steps = int($num_points * $L / 10000) + 5;  # Scale by section length
        
        for (my $i = 0; $i <= $steps; $i++) {
            my $x = $i * $L / $steps;
            my $y = $sec->{a} * $x**3 + $sec->{b} * $x**2 + $sec->{c} * $x + $sec->{d};
            push @points, [$x_offset + $x, $y];
        }
        
        $x_offset += $L;
    }
    
    return \@points;
}

# ============================================================================
# Generate overlay comparison plots
# ============================================================================

# 1. Smoothing factor comparison
my @smoothing_vals = (2.0, 4.0, 6.0, 8.0, 10.0, 12.0);
my $alpha = 0.85;

print "Extracting data for smoothing comparison...\n";
my %smoothing_data;
foreach my $s (@smoothing_vals) {
    my $file = sprintf("$sweep_dir/method4_s%.1f_a%.2f_gtk.TXT", $s, $alpha);
    if (-f $file) {
        $smoothing_data{$s} = extract_altitude_curve($file);
        print "  Loaded: $file\n";
    }
}

# Write data files for gnuplot
foreach my $s (keys %smoothing_data) {
    my $datafile = sprintf("$sweep_dir/data_smooth_%.1f.dat", $s);
    open(my $fh, '>', $datafile) or die $!;
    foreach my $pt (@{$smoothing_data{$s}}) {
        printf $fh "%.6f %.6f\n", $pt->[0], $pt->[1];
    }
    close($fh);
}

# 2. Alpha parameter comparison
my @alpha_vals = (0.5, 0.65, 0.75, 0.85, 0.95);
my $smooth = 8.0;

print "\nExtracting data for alpha comparison...\n";
my %alpha_data;
foreach my $a (@alpha_vals) {
    my $file = sprintf("$sweep_dir/method4_s%.1f_a%.2f_gtk.TXT", $smooth, $a);
    if (-f $file) {
        $alpha_data{$a} = extract_altitude_curve($file);
        print "  Loaded: $file\n";
    }
}

# Write data files
foreach my $a (keys %alpha_data) {
    my $datafile = sprintf("$sweep_dir/data_alpha_%.2f.dat", $a);
    open(my $fh, '>', $datafile) or die $!;
    foreach my $pt (@{$alpha_data{$a}}) {
        printf $fh "%.6f %.6f\n", $pt->[0], $pt->[1];
    }
    close($fh);
}

# 3. Tension parameter comparison (Catmull-Rom)
my @tension_vals = (0.0, 0.2, 0.4, 0.6, 0.8, 1.0);
my $smooth_cr = 4.0;

print "\nExtracting data for tension comparison...\n";
my %tension_data;
foreach my $t (@tension_vals) {
    my $file = sprintf("$sweep_dir/method2_s%.1f_t%.2f_gtk.TXT", $smooth_cr, $t);
    if (-f $file) {
        $tension_data{$t} = extract_altitude_curve($file);
        print "  Loaded: $file\n";
    }
}

# Write data files
foreach my $t (keys %tension_data) {
    my $datafile = sprintf("$sweep_dir/data_tension_%.2f.dat", $t);
    open(my $fh, '>', $datafile) or die $!;
    foreach my $pt (@{$tension_data{$t}}) {
        printf $fh "%.6f %.6f\n", $pt->[0], $pt->[1];
    }
    close($fh);
}

# ============================================================================
# Create gnuplot scripts for overlay plots
# ============================================================================

print "\nGenerating gnuplot scripts...\n";

# Smoothing overlay
open(my $gp1, '>', "$sweep_dir/plot_smoothing_overlay.gnuplot") or die $!;
print $gp1 <<'GNUPLOT_END';
set terminal pngcairo size 1400,900 enhanced font 'Arial,11'
set output 'parameter_sweep/smoothing_overlay.png'

set title "Harmonic Mean Method: Smoothing Factor Comparison (α=0.85)" font 'Arial,14'
set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set key outside right

plot 'parameter_sweep/data_smooth_2.0.dat' with lines lw 2 title 'Smoothing = 2.0', \
     'parameter_sweep/data_smooth_4.0.dat' with lines lw 2 title 'Smoothing = 4.0', \
     'parameter_sweep/data_smooth_6.0.dat' with lines lw 2 title 'Smoothing = 6.0', \
     'parameter_sweep/data_smooth_8.0.dat' with lines lw 2 title 'Smoothing = 8.0', \
     'parameter_sweep/data_smooth_10.0.dat' with lines lw 2 title 'Smoothing = 10.0', \
     'parameter_sweep/data_smooth_12.0.dat' with lines lw 2 title 'Smoothing = 12.0'
GNUPLOT_END
close($gp1);

# Alpha overlay
open(my $gp2, '>', "$sweep_dir/plot_alpha_overlay.gnuplot") or die $!;
print $gp2 <<'GNUPLOT_END';
set terminal pngcairo size 1400,900 enhanced font 'Arial,11'
set output 'parameter_sweep/alpha_overlay.png'

set title "Harmonic Mean Method: Alpha Parameter Comparison (smoothing=8.0)" font 'Arial,14'
set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set key outside right

plot 'parameter_sweep/data_alpha_0.50.dat' with lines lw 2 title 'Alpha = 0.50', \
     'parameter_sweep/data_alpha_0.65.dat' with lines lw 2 title 'Alpha = 0.65', \
     'parameter_sweep/data_alpha_0.75.dat' with lines lw 2 title 'Alpha = 0.75', \
     'parameter_sweep/data_alpha_0.85.dat' with lines lw 2 title 'Alpha = 0.85', \
     'parameter_sweep/data_alpha_0.95.dat' with lines lw 2 title 'Alpha = 0.95'
GNUPLOT_END
close($gp2);

# Tension overlay
open(my $gp3, '>', "$sweep_dir/plot_tension_overlay.gnuplot") or die $!;
print $gp3 <<'GNUPLOT_END';
set terminal pngcairo size 1400,900 enhanced font 'Arial,11'
set output 'parameter_sweep/tension_overlay.png'

set title "Catmull-Rom Method: Tension Parameter Comparison (smoothing=4.0)" font 'Arial,14'
set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set key outside right

plot 'parameter_sweep/data_tension_0.00.dat' with lines lw 2 title 'Tension = 0.00', \
     'parameter_sweep/data_tension_0.20.dat' with lines lw 2 title 'Tension = 0.20', \
     'parameter_sweep/data_tension_0.40.dat' with lines lw 2 title 'Tension = 0.40', \
     'parameter_sweep/data_tension_0.60.dat' with lines lw 2 title 'Tension = 0.60', \
     'parameter_sweep/data_tension_0.80.dat' with lines lw 2 title 'Tension = 0.80', \
     'parameter_sweep/data_tension_1.00.dat' with lines lw 2 title 'Tension = 1.00'
GNUPLOT_END
close($gp3);

print "\n" . "=" x 70 . "\n";
print "Comparison plots created successfully!\n";
print "=" x 70 . "\n";
print "\nTo generate the plots, run:\n";
print "  gnuplot $sweep_dir/plot_smoothing_overlay.gnuplot\n";
print "  gnuplot $sweep_dir/plot_alpha_overlay.gnuplot\n";
print "  gnuplot $sweep_dir/plot_tension_overlay.gnuplot\n";
print "\nOutput images:\n";
print "  - $sweep_dir/smoothing_overlay.png\n";
print "  - $sweep_dir/alpha_overlay.png\n";
print "  - $sweep_dir/tension_overlay.png\n";
print "\n";
