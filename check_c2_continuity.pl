#!/usr/bin/perl
#
# Check C² continuity at section boundaries
# Shows second derivative (curvature) at end of section N and start of section N+1
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
print "C² CONTINUITY CHECK - Second Derivative (Curvature) at Section Boundaries\n";
print "=" x 80 . "\n";
print "File: $file\n\n";

my @sections;
my $line_num = 0;

# Read all sections
while (my $line = <$fh>) {
    chomp $line;
    my @fields = split(',', $line);
    
    my $section_id = $fields[0];
    my $length_tics = $fields[1];
    
    # Extract first trace coefficients: d, a, b, c
    my $d = $fields[2];
    my $a = $fields[3];
    my $b = $fields[4];
    my $c = $fields[5];
    
    push @sections, {
        id => $section_id,
        length_tics => $length_tics,
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
# First derivative:  f'(x)  = 3*a*x² + 2*b*x + c
# Second derivative: f''(x) = 6*a*x + 2*b

my $TICS_PER_METER = 19685.0;

for (my $i = 0; $i < @sections - 1; $i++) {
    my $curr = $sections[$i];
    my $next = $sections[$i + 1];
    
    # Calculate second derivative at END of current section (x = length)
    my $x_end = $curr->{length_tics} / $TICS_PER_METER;  # Convert tics to meters
    my $f2_end = 6 * $curr->{a} * $x_end + 2 * $curr->{b};
    
    # Calculate second derivative at START of next section (x = 0)
    my $f2_start = 2 * $next->{b};  # At x=0, f''(x) = 2*b
    
    # Calculate difference
    my $diff = $f2_end - $f2_start;
    my $diff_pct = ($f2_start != 0) ? abs($diff / $f2_start) * 100 : 0;
    
    printf "Section %d -> %d:\n", $curr->{id}, $next->{id};
    printf "  End of section %d:   f''(x=%.6f) = %.10f\n", $curr->{id}, $x_end, $f2_end;
    printf "  Start of section %d: f''(x=0)      = %.10f\n", $next->{id}, $f2_start;
    printf "  Difference:          Δf'' = %.10f", $diff;
    
    if (abs($diff) < 1e-6) {
        print " ✓ C² CONTINUOUS\n";
    } else {
        printf " ✗ NOT C² (%.2f%% difference)\n", $diff_pct;
    }
    print "\n";
}

print "=" x 80 . "\n";
print "Summary:\n";
print "  C¹ continuity: f'(end of N) = f'(start of N+1) - slope matches\n";
print "  C² continuity: f''(end of N) = f''(start of N+1) - curvature matches\n";
print "  Differences > 1e-6 indicate C² discontinuity\n";
print "=" x 80 . "\n";
