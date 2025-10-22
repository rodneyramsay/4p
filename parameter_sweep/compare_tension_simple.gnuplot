set terminal pngcairo size 1800,1200 enhanced font 'Arial,14'
set output 'parameter_sweep/tension_comparison.png'

set multiplot layout 3,2 title "Catmull-Rom Method: Tension Parameter Comparison (s=4.0)" font 'Arial,16'

set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set key off

# Tension = 0.00
set title "t = 0.00" font 'Arial,14'
load 'parameter_sweep/method2_s4.0_t0.00_plot.txt'

# Tension = 0.20
set title "t = 0.20" font 'Arial,14'
load 'parameter_sweep/method2_s4.0_t0.20_plot.txt'

# Tension = 0.40
set title "t = 0.40" font 'Arial,14'
load 'parameter_sweep/method2_s4.0_t0.40_plot.txt'

# Tension = 0.60
set title "t = 0.60" font 'Arial,14'
load 'parameter_sweep/method2_s4.0_t0.60_plot.txt'

# Tension = 0.80
set title "t = 0.80" font 'Arial,14'
load 'parameter_sweep/method2_s4.0_t0.80_plot.txt'

# Tension = 1.00
set title "t = 1.00" font 'Arial,14'
load 'parameter_sweep/method2_s4.0_t1.00_plot.txt'

unset multiplot
