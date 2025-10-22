set terminal pngcairo size 1600,1200 enhanced font 'Arial,12'
set output 'parameter_sweep/method0_qfactor_comparison.png'

set multiplot layout 3,2 title "Four Point Method: Q-Factor Comparison"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each q-factor value
qfactor_values = "2.0 4.0 6.0 8.0 10.0 12.0"

do for [i=1:6] {
    q = word(qfactor_values, i)
    filename = sprintf("parameter_sweep/method0_q%s_plot.txt", q)
    set title sprintf("Q-Factor = %s", q)
    
    load filename
}

unset multiplot
