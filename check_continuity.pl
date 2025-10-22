#!/usr/bin/perl
#
# Check C1 continuity at section boundaries
# Shows derivative values at end of section N and start of section N+1
#

use strict;
use warnings;

if (@ARGV != 1) {
    print "Usage: $0 <gtk_csv_file>\n";
    print "Example: $0 parameter_sweep/method0_s2.0_gtk.TXT\n";
    exit 1;
}

my $file = $ARGV[0];

open(my $fh, '<', $file) or die "Cannot open $file: $!";

print "=" x 80 . "\n";
print "C¹ CONTINUITY CHECK - Derivative at Section Boundaries\n";
print "=" x 80 . "\n";
print "File: $file\n\n";

my @sections;
my $line_num = 0;

# Read all sections
while (my $line = <$fh>) {
    chomp $line;
    my @fields = split(',', $line);
    
    my $section_id = $fields[0];
    my $length = $fields[1];
    
    # Extract first trace coefficients: d, a, b, c
    my $d = $fields[2];
    my $a = $fields[3];
    my $b = $fields[4];
    my $c = $fields[5];
    
    push @sections, {
        id => $section_id,
        length => $length,
        d => $d,
        a => $a,
        b => $b,
        c => $c
    };
    
    $line_num++;
    last if $line_num >= 10;  # Check first 10 sections
}

close($fh);

print "Checking first " . scalar(@sections) . " sections...\n";
print "-" x 80 . "\n\n";

# For cubic polynomial: f(x) = a*x³ + b*x² + c*x + d
# Derivative: f'(x) = 3*a*x² + 2*b*x + c

for (my $i = 0; $i < @sections - 1; $i++) {
    my $curr = $sections[$i];
    my $next = $sections[$i + 1];
    
    # Calculate derivative at END of current section (x = length)
    my $x_end = $curr->{length} / 19685.0;  # Convert tics to meters
    my $deriv_end = 3 * $curr->{a} * $x_end**2 + 2 * $curr->{b} * $x_end + $curr->{c};
    
    # Calculate derivative at START of next section (x = 0)
    my $deriv_start = $next->{c};  # At x=0, derivative = c
    
    # Calculate difference
    my $diff = $deriv_end - $deriv_start;
    my $diff_pct = ($deriv_start != 0) ? abs($diff / $deriv_start) * 100 : 0;
    
    printf "Section %d -> %d:\n", $curr->{id}, $next->{id};
    printf "  End of section %d:   f'(x=%.6f) = %.10f\n", $curr->{id}, $x_end, $deriv_end;
    printf "  Start of section %d: f'(x=0)      = %.10f\n", $next->{id}, $deriv_start;
    printf "  Difference:          Δf' = %.10f", $diff;
    
    if (abs($diff) < 1e-6) {
        print " ✓ C¹ CONTINUOUS\n";
    } else {
        printf " ✗ NOT C¹ (%.2f%% difference)\n", $diff_pct;
    }
    print "\n";
}

print "=" x 80 . "\n";
print "Summary:\n";
print "  C¹ continuity requires f'(end of section N) = f'(start of section N+1)\n";
print "  Differences > 1e-6 indicate C¹ discontinuity\n";
print "=" x 80 . "\n";
