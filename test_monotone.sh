#!/bin/bash

# Quick test script for monotone method
# Usage: ./test_monotone.sh [input_file]

INPUT=${1:-alt_mytrack.txt}

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    echo "Usage: $0 [input_file]"
    exit 1
fi

echo "=========================================="
echo "Testing Monotone Method (No Overshoot)"
echo "=========================================="
echo "Input: $INPUT"
echo ""

# Run monotone method
echo "Running: ./4p_improved -m 1 $INPUT"
./4p_improved -m 1 "$INPUT"

echo ""
echo "=========================================="
echo "Output files generated:"
echo "  - __gtk_csv.TXT (CSV coefficients)"
echo "  - __do_plot_all.txt (gnuplot script)"
echo ""
echo "To visualize:"
echo "  gnuplot __do_plot_all.txt"
echo ""
echo "To compare with other methods:"
echo "  ./compare_methods.pl $INPUT"
echo "=========================================="
