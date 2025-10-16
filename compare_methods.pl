#!/usr/bin/perl

# Script to compare different smoothing methods
# Generates plots comparing original vs improved methods

use strict;
use warnings;

my $input_file = $ARGV[0] || "alt_mytrack.txt";

unless(-f $input_file) {
   die "Usage: $0 <input_file>\n";
}

print "Comparing smoothing methods for: $input_file\n\n";

# Run each method
my @methods = (
   {name => "Original", cmd => "./4p $input_file > output_original.txt 2>&1", plot => "__do_plot_all.txt", csv => "__gtk_csv.TXT"},
   {name => "Monotone", cmd => "./4p_improved -m 1 $input_file > output_monotone.txt 2>&1", plot => "__do_plot_all_monotone.txt", csv => "__gtk_csv_monotone.TXT"},
   {name => "Catmull-Rom", cmd => "./4p_improved -m 2 -t 0.3 $input_file > output_catmull.txt 2>&1", plot => "__do_plot_all_catmull.txt", csv => "__gtk_csv_catmull.TXT"},
   {name => "Limited", cmd => "./4p_improved -m 3 $input_file > output_limited.txt 2>&1", plot => "__do_plot_all_limited.txt", csv => "__gtk_csv_limited.TXT"},
);

foreach my $method (@methods) {
   print "Running $method->{name} method...\n";
   system($method->{cmd});
   
   # Rename output files to avoid overwriting
   if(-f "__do_plot_all.txt") {
      system("cp __do_plot_all.txt $method->{plot}");
   }
   if(-f "__gtk_csv.TXT") {
      system("cp __gtk_csv.TXT $method->{csv}");
   }
}

# Create combined gnuplot script
open(my $fh, ">", "compare_all.gnuplot") or die "Cannot create compare_all.gnuplot: $!\n";

print $fh "set terminal png size 1600,1200\n";
print $fh "set output 'comparison.png'\n";
print $fh "set multiplot layout 2,2 title 'Altitude Smoothing Method Comparison'\n\n";

foreach my $method (@methods) {
   print $fh "# $method->{name}\n";
   print $fh "set title '$method->{name}'\n";
   
   if(-f $method->{plot}) {
      # Read and include the plot commands
      open(my $plot_fh, "<", $method->{plot}) or next;
      my $in_plot = 0;
      while(my $line = <$plot_fh>) {
         if($line =~ /^plot/) {
            $in_plot = 1;
         }
         if($in_plot && $line !~ /pause/) {
            print $fh $line;
         }
         if($line =~ /pause/) {
            last;
         }
      }
      close($plot_fh);
   }
   print $fh "\n";
}

print $fh "unset multiplot\n";
close($fh);

print "\nComparison complete!\n";
print "Generated files:\n";
foreach my $method (@methods) {
   print "  - $method->{plot}\n";
   print "  - $method->{csv}\n";
}
print "\nTo visualize: gnuplot compare_all.gnuplot\n";
print "This will create comparison.png with all methods side-by-side\n";
