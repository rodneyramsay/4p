set terminal pngcairo size 1800,1000 enhanced font 'Arial,14'
set output 'parameter_sweep/alpha_comparison.png'

set multiplot layout 2,3 title "Harmonic Mean Method: Alpha Parameter Comparison (s=8.0)" font 'Arial,16'

set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set key off

# Alpha = 0.50
set title "α = 0.50" font 'Arial,14'
load 'parameter_sweep/method4_s8.0_a0.50_plot.txt'

# Alpha = 0.65
set title "α = 0.65" font 'Arial,14'
load 'parameter_sweep/method4_s8.0_a0.65_plot.txt'

# Alpha = 0.75
set title "α = 0.75" font 'Arial,14'
load 'parameter_sweep/method4_s8.0_a0.75_plot.txt'

# Alpha = 0.85
set title "α = 0.85" font 'Arial,14'
load 'parameter_sweep/method4_s8.0_a0.85_plot.txt'

# Alpha = 0.95
set title "α = 0.95" font 'Arial,14'
load 'parameter_sweep/method4_s8.0_a0.95_plot.txt'

unset multiplot
