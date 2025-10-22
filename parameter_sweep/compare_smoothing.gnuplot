set terminal pngcairo size 1600,1200 enhanced font 'Arial,12'
set output 'parameter_sweep/smoothing_comparison.png'

set multiplot layout 3,2 title "Harmonic Mean Method: Smoothing Factor Comparison (α=0.85)"

set xlabel "Distance"
set ylabel "Altitude"
set grid

# Plot for each smoothing value
smoothing_values = "2.0 4.0 6.0 8.0 10.0 12.0"

do for [i=1:6] {
    s = word(smoothing_values, i)
    filename = sprintf("parameter_sweep/method4_s%s_a0.85_plot.txt", s)
    set title sprintf("Smoothing = %s", s)
    
    # This will plot the first trace from the generated plot file
    # We'll need to extract the actual data plotting commands
    load filename
}

unset multiplot
