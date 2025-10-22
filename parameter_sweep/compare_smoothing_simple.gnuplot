set terminal pngcairo size 1800,1200 enhanced font 'Arial,14'
set output 'parameter_sweep/smoothing_comparison.png'

set multiplot layout 3,2 title "Harmonic Mean Method: Smoothing Factor Comparison (α=0.85)" font 'Arial,16'

set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set key off

# Smoothing = 2.0
set title "s = 2.0" font 'Arial,14'
load 'parameter_sweep/method4_s2.0_a0.85_plot.txt'

# Smoothing = 4.0
set title "s = 4.0" font 'Arial,14'
load 'parameter_sweep/method4_s4.0_a0.85_plot.txt'

# Smoothing = 6.0
set title "s = 6.0" font 'Arial,14'
load 'parameter_sweep/method4_s6.0_a0.85_plot.txt'

# Smoothing = 8.0
set title "s = 8.0" font 'Arial,14'
load 'parameter_sweep/method4_s8.0_a0.85_plot.txt'

# Smoothing = 10.0
set title "s = 10.0" font 'Arial,14'
load 'parameter_sweep/method4_s10.0_a0.85_plot.txt'

# Smoothing = 12.0
set title "s = 12.0" font 'Arial,14'
load 'parameter_sweep/method4_s12.0_a0.85_plot.txt'

unset multiplot
