set terminal pngcairo size 1800,600 enhanced font 'Arial,14'
set output 'parameter_sweep/method4_smoothing_zoom.png'

set multiplot layout 1,2 title "Method 4: Smoothing Factor Effect (Zoomed)" font 'Arial,16'

# Zoom on rising edge
set xlabel "Distance" font 'Arial,12'
set ylabel "Altitude" font 'Arial,12'
set grid
set title "Rising Edge Detail" font 'Arial,14'
set xrange [100:250]
set yrange [0:14]

plot 'parameter_sweep/method4_s2.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=2.0", \
     'parameter_sweep/method4_s4.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=4.0", \
     'parameter_sweep/method4_s8.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=8.0", \
     'parameter_sweep/method4_s12.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=12.0"

# Zoom on falling edge
set title "Falling Edge Detail" font 'Arial,14'
set xrange [400:550]
set yrange [0:14]

plot 'parameter_sweep/method4_s2.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=2.0", \
     'parameter_sweep/method4_s4.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=4.0", \
     'parameter_sweep/method4_s8.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=8.0", \
     'parameter_sweep/method4_s12.0_a0.85_gtk.TXT' using 1:4 with lines lw 2 title "s=12.0"

unset multiplot
