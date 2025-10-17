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

# Run each method with different smoothing factors
my @methods = (
   {name => "Original (s=4)", cmd => "perl ./4p -s 4.0 $input_file > output_original_s4.txt 2>&1", plot => "__do_plot_all_orig_s4.txt", csv => "__gtk_csv_orig_s4.TXT"},
   {name => "Original (s=8)", cmd => "perl ./4p -s 8.0 $input_file > output_original_s8.txt 2>&1", plot => "__do_plot_all_orig_s8.txt", csv => "__gtk_csv_orig_s8.TXT"},
   {name => "Original (s=16)", cmd => "perl ./4p -s 16.0 $input_file > output_original_s16.txt 2>&1", plot => "__do_plot_all_orig_s16.txt", csv => "__gtk_csv_orig_s16.TXT"},
   {name => "Monotone (s=4)", cmd => "perl ./4p_improved -m 1 -s 4.0 $input_file > output_monotone_s4.txt 2>&1", plot => "__do_plot_all_monotone_s4.txt", csv => "__gtk_csv_monotone_s4.TXT"},
   {name => "Monotone (s=8)", cmd => "perl ./4p_improved -m 1 -s 8.0 $input_file > output_monotone_s8.txt 2>&1", plot => "__do_plot_all_monotone_s8.txt", csv => "__gtk_csv_monotone_s8.TXT"},
   {name => "Monotone (s=16)", cmd => "perl ./4p_improved -m 1 -s 16.0 $input_file > output_monotone_s16.txt 2>&1", plot => "__do_plot_all_monotone_s16.txt", csv => "__gtk_csv_monotone_s16.TXT"},
   {name => "Monotone (s=32)", cmd => "perl ./4p_improved -m 1 -s 32.0 $input_file > output_monotone_s32.txt 2>&1", plot => "__do_plot_all_monotone_s32.txt", csv => "__gtk_csv_monotone_s32.TXT"},
   {name => "Limited (s=4)", cmd => "perl ./4p_improved -m 3 -s 4.0 $input_file > output_limited_s4.txt 2>&1", plot => "__do_plot_all_limited_s4.txt", csv => "__gtk_csv_limited_s4.TXT"},
   {name => "Limited (s=16)", cmd => "perl ./4p_improved -m 3 -s 16.0 $input_file > output_limited_s16.txt 2>&1", plot => "__do_plot_all_limited_s16.txt", csv => "__gtk_csv_limited_s16.TXT"},
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

print $fh "set terminal png size 2400,1800\n";
print $fh "set output 'comparison.png'\n";
print $fh "set multiplot layout 3,3 title 'Altitude Smoothing Method Comparison'\n\n";

foreach my $method (@methods) {
   print $fh "# $method->{name}\n";
   print $fh "set title '$method->{name}'\n";
   
   if(-f $method->{plot}) {
      # Read and include function definitions AND plot commands
      open(my $plot_fh, "<", $method->{plot}) or next;
      my $in_plot = 0;
      while(my $line = <$plot_fh>) {
         # Include function definitions (lines starting with f_)
         if($line =~ /^f_/) {
            print $fh $line;
         }
         # Include set xrange
         if($line =~ /^set xrange/) {
            print $fh $line;
         }
         # Track when we hit plot command
         if($line =~ /^plot/) {
            $in_plot = 1;
         }
         # Include plot commands but skip pause
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
