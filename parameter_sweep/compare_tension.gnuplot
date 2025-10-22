set terminal pngcairo size 1600,1200 enhanced font 'Arial,12'
set output 'parameter_sweep/tension_comparison.png'

set multiplot layout 3,2 title "Catmull-Rom Method: Tension Parameter Comparison (smoothing=4.0)"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each tension value
tension_values = "0.00 0.20 0.40 0.60 0.80 1.00"

do for [i=1:6] {
    t = word(tension_values, i)
    filename = sprintf("parameter_sweep/method2_s4.0_t%s_plot.txt", t)
    set title sprintf("Tension = %s", t)
    
    load filename
}

unset multiplot
