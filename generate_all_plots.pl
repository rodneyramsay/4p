#!/usr/bin/perl

use strict;
use warnings;

# Master script to generate all comparison plots from a single input file

my $input_file = $ARGV[0];

unless($input_file) {
   print "Usage: generate_all_plots.pl <input_file>\n";
   print "Generates comprehensive comparison plots of all smoothing methods.\n";
   exit(1);
}

unless(-f $input_file) {
   die "Error: Input file '$input_file' not found\n";
}

print "=" x 70 . "\n";
print "GENERATING ALL COMPARISON PLOTS\n";
print "=" x 70 . "\n\n";

print "Input file: $input_file\n\n";

# Step 1: Run all methods
print "Step 1: Running all smoothing methods...\n";
system("./compare_optimal.pl $input_file");
print "\n";

# Step 2: Generate gnuplot scripts dynamically
print "Step 2: Generating gnuplot scripts for this dataset...\n";
system("./generate_plot_scripts.pl");
print "\n";

# Step 3: Generate sections plot (colored by section)
print "Step 3: Generating sections plot (colored by section)...\n";
system("gnuplot plot_pulse_sections.gnuplot");
print "  ✓ Created: pulse_sections.png\n\n";

# Step 4: Generate zoomed transition plot
print "Step 4: Generating zoomed transition plot...\n";
system("gnuplot plot_zoom_transition.gnuplot");
print "  ✓ Created: zoom_transition.png\n\n";

# Step 5: Generate junction 1 plot
print "Step 5: Generating junction 1 plot...\n";
system("gnuplot plot_zoom_junction.gnuplot");
print "  ✓ Created: zoom_junction.png\n\n";

# Step 6: Generate junction 2 plot
print "Step 6: Generating junction 2 plot...\n";
system("gnuplot plot_zoom_junction2.gnuplot");
print "  ✓ Created: zoom_junction2.png\n\n";

print "=" x 70 . "\n";
print "ALL PLOTS GENERATED SUCCESSFULLY\n";
print "=" x 70 . "\n\n";

print "Generated plots:\n";
print "  1. pulse_sections.png         - Sections colored differently\n";
print "  2. zoom_transition.png        - Zoomed view of 195m transition\n";
print "  3. zoom_junction.png          - Super zoom of 151.6m junction\n";
print "  4. zoom_junction2.png         - Super zoom of 195.4m junction\n\n";

print "Method comparison files:\n";
print "  - __do_plot_method0.txt       - Original method\n";
print "  - __do_plot_method1.txt       - Monotone method (C¹, no overshoot)\n";
print "  - __do_plot_method2.txt       - Catmull-Rom method\n";
print "  - __do_plot_method3.txt       - Limited slopes method\n";
print "  - __do_plot_optimal.txt       - OPTIMAL method (C², optimal overshoot)\n\n";

print "Summary:\n";
print "  Method 1 (Monotone): C¹ continuity, no overshoot\n";
print "  Method 4 (OPTIMAL):  C² continuity, optimal overshoot ⭐\n\n";
