#!/usr/bin/perl
#
# Parameter Sweep for Method 0 (Four Point) - Smoothing Factor
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
print "METHOD 0 (FOUR POINT) Q-FACTOR PARAMETER SWEEP\n";
print "=" x 70 . "\n";
print "Input file: $input_file\n\n";

# Create output directory for sweep results
my $sweep_dir = "parameter_sweep";
mkdir $sweep_dir unless -d $sweep_dir;

# Sweep q-factor for Method 0
print "Sweeping Four Point method (0) - Q-factor...\n";
print "-" x 70 . "\n";

my @qfactor_values = (2.0, 4.0, 6.0, 8.0, 10.0, 12.0);

foreach my $q (@qfactor_values) {
    my $label = sprintf("method0_q%.1f", $q);
    print "  Running: method=0, q-factor=$q\n";
    
    system("./4psi -m 0 -q $q $input_file > /dev/null 2>&1");
    
    # Save outputs with descriptive names
    system("cp __gtk_csv.TXT $sweep_dir/${label}_gtk.TXT");
    system("cp __do_plot_all.txt $sweep_dir/${label}_plot.txt");
}

print "\n" . "=" x 70 . "\n";
print "SWEEP COMPLETE!\n";
print "=" x 70 . "\n";
print "\nResults saved in: $sweep_dir/\n";
print "Generated files: ${sweep_dir}/method0_q*\n\n";
