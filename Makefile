# Makefile for 4p altitude smoothing
# GNU-style with automatic dependency resolution
# Usage: make alt_mytrack.alt

# Default target
all: alt_mytrack.alt

# Main target: .alt file depends on all plots being generated
%.alt: %.txt
	@echo "========================================"
	@echo "Running complete flow for $<"
	@echo "========================================"
	@echo ""
	@echo "Step 1: Running all smoothing methods..."
	./compare_optimal.pl $<
	@echo ""
	@echo "Step 2: Creating comparison plot..."
	gnuplot compare_optimal.gnuplot
	@echo ""
	@echo "========================================"
	@echo "✓ Complete! Generated: comparison_optimal.png"
	@echo "========================================"
	@touch $@

# Special target for pulse test case with detailed analysis
alt_mytrack.alt: alt_mytrack.txt
	@echo "========================================"
	@echo "Running FULL analysis for pulse test case"
	@echo "========================================"
	@echo ""
	@echo "Step 1: Running all smoothing methods..."
	./compare_optimal.pl $<
	@echo ""
	@echo "Step 2: Generating detailed plot scripts..."
	./generate_plot_scripts.pl
	@echo ""
	@echo "Step 3: Creating all visualizations..."
	gnuplot compare_optimal.gnuplot
	gnuplot plot_pulse_sections.gnuplot
	gnuplot plot_zoom_transition.gnuplot
	gnuplot plot_zoom_junction.gnuplot
	gnuplot plot_zoom_junction2.gnuplot
	@echo ""
	@echo "========================================"
	@echo "✓ Complete! Generated files:"
	@echo "  - comparison_optimal.png"
	@echo "  - pulse_sections.png"
	@echo "  - zoom_transition.png"
	@echo "  - zoom_junction.png"
	@echo "  - zoom_junction2.png"
	@echo "========================================"
	@touch $@

# Convert KML to altitude file
alt_%.txt : %.kml
	@echo "Converting KML to altitude format..."
	./x_kml $< > $@
	@echo "✓ Created $@"

# Quick targets for convenience
plots: alt_mytrack.alt

optimal: alt_mytrack.txt
	@echo "Running OPTIMAL method only..."
	./4p_optimal $<
	@echo "✓ Done! View __do_plot_all.txt"

# Run a specific method (0-4)
# Usage: make method1 (or method0, method2, etc.)
method%: alt_mytrack.txt
	@echo "Running method $* on $<..."
	@if [ "$*" = "4" ]; then \
		./4p_optimal $<; \
	else \
		./4p_improved -m $* $<; \
	fi
	@echo "✓ Done!" 

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	-rm -f __do_plot_*.txt
	-rm -f __gtk_csv*.TXT
	-rm -f output_*.txt
	-rm -f *.png
	-rm -f *.gnuplot
	-rm -f *.alt
	@echo "Clean complete."

# Help target
help:
	@echo "4p Altitude Smoothing Makefile (GNU-style)"
	@echo ""
	@echo "Usage:"
	@echo "  make alt_mytrack.alt           - Run complete flow (default)"
	@echo "  make alt_<name>.alt            - Run for any altitude file"
	@echo "  make optimal                   - Run OPTIMAL method only"
	@echo "  make method0, method1, etc.    - Run specific method"
	@echo "  make clean                     - Remove generated files"
	@echo ""
	@echo "Examples:"
	@echo "  make alt_mytrack.alt           # Complete flow"
	@echo "  make alt_silverstone.alt       # For alt_silverstone.txt"
	@echo "  make optimal                   # OPTIMAL method only"
	@echo "  make method1                   # Monotone method only"
	@echo ""
	@echo "The Makefile automatically:"
	@echo "  - Converts .kml → alt_*.txt (if needed)"
	@echo "  - Runs all smoothing methods"
	@echo "  - Generates plot scripts"
	@echo "  - Creates all visualizations"
	@echo ""
	@echo "Methods:"
	@echo "  0 - Original (overshoots)"
	@echo "  1 - Monotone (no overshoot, C¹)"
	@echo "  2 - Catmull-Rom"
	@echo "  3 - Limited slopes"
	@echo "  4 - OPTIMAL (no overshoot, C²) ⭐"

.PRECIOUS: alt_%.txt
.PHONY: all plots optimal clean help
# Make all .alt targets always rebuild (for development)
.PHONY: $(shell ls alt_*.txt 2>/dev/null | sed 's/\.txt$$/.alt/')
