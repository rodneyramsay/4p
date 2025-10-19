set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'split_section_comparison.png'
set multiplot layout 2,1 title 'Section Split Comparison'

# Define functions in original x-domain
# Original: f(x) = x³ - 15x - 4
f_original(x) = x**3 - 15*x - 4
# Transform to t-domain: t = x - (-5)
f1_t(t) = 1*t**3 + -15*t**2 + 60*t + -54
f2_t(t) = 1*(t-8)**3 + 9*(t-8)**2 + 12*(t-8) + -22
# Map back to x-domain
f1(x) = f1_t(x - (-5))
f2(x) = f2_t(x - (-5))

# Plot 1: All curves together
set title 'Original vs Split Sections (x³ - 15x - 4)'
set xlabel 'x'
set ylabel 'f(x)'
set grid
set key top left
plot [-5:5] f_original(x) with lines lw 3 lc rgb 'blue' title 'Original f(x)', \
     [-5:3] f1(x) with lines lw 2 lc rgb 'red' title 'Section 1: f₁(x)', \
     [3:5] f2(x) with lines lw 2 lc rgb 'green' title 'Section 2: f₂(x)'

# Plot 2: Error/difference
set title 'Difference: Split Sections - Original (should be zero)'
set xlabel 'x'
set ylabel 'Error'
set grid
set key top left
set format y '%.2e'
set xrange [-5:5]
plot [-5:3] f1(x) - f_original(x) with lines lw 2 lc rgb 'red' title 'Section 1 error', \
     [3:5] f2(x) - f_original(x) with lines lw 2 lc rgb 'green' title 'Section 2 error'

unset multiplot
