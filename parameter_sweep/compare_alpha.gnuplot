set terminal pngcairo size 1600,1000 enhanced font 'Arial,12'
set output 'parameter_sweep/alpha_comparison.png'

set multiplot layout 2,3 title "Harmonic Mean Method: Alpha Parameter Comparison (smoothing=8.0)"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each alpha value
alpha_values = "0.50 0.65 0.75 0.85 0.95"

do for [i=1:5] {
    a = word(alpha_values, i)
    filename = sprintf("parameter_sweep/method4_s8.0_a%s_plot.txt", a)
    set title sprintf("Alpha = %s", a)
    
    load filename
}

unset multiplot
