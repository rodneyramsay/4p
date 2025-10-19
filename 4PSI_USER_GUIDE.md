# 4psi User Guide

**4psi** (4-Point Spline Interpolation) - A unified altitude profile smoothing tool with 5 different algorithms.

## Quick Start

```bash
# RECOMMENDED: Use OPTIMAL method for best results
./4psi -m 4 alt_mytrack.txt

# View the output
gnuplot __do_plot_all.txt
```

## Overview

4psi processes altitude profile data and generates smooth cubic spline curves using one of five different smoothing methods. Each method offers different trade-offs between smoothness and overshoot prevention.

## Command Line Usage

```bash
./4psi [options] <input_file>
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-m <method>` | Smoothing method (0-4) | 1 (Monotone) |
| `-s <factor>` | Smoothing factor | 4.0 (8.0 for method 4) |
| `-t <value>` | Tension (method 2) or alpha (method 4) | 0.0 (0.85 for method 4) |
| `-h` | Show help message | - |

## Smoothing Methods

### Method 0: Four Point

**Command:** `./4psi -m 0 alt_mytrack.txt`

**Characteristics:**
- ✅ Very smooth curves
- ⚠️ Can produce overshoot
- ✅ C² continuity

**Use case:** Smooth, gentle terrain where maximum smoothness is desired

**Parameters:**
- `-s <factor>` - Smoothing factor (default: 4.0, higher = smoother)

**Example:**
```bash
./4psi -m 0 -s 8.0 alt_mytrack.txt  # Maximum smoothness
```

---

### Method 1: Monotone (Fritsch-Carlson) ⭐ DEFAULT

**Command:** `./4psi -m 1 alt_mytrack.txt`

**Characteristics:**
- ✅ Guaranteed no overshoot
- ✅ Preserves monotonicity
- ⚠️ Less smooth (C¹ continuity only)
- ⚠️ May show visible "kinks" at transitions

**Use case:** When accuracy is critical and overshoot must be avoided

**Parameters:**
- `-s <factor>` - Smoothing factor (default: 4.0)

**Example:**
```bash
./4psi -m 1 alt_mytrack.txt  # Default method
```

---

### Method 2: Catmull-Rom with Tension

**Command:** `./4psi -m 2 -t <tension> alt_mytrack.txt`

**Characteristics:**
- ✅ Adjustable smoothness via tension parameter
- ✅ Good balance between smoothness and control
- ⚠️ May overshoot with low tension
- ⚠️ C¹ continuity only

**Use case:** When you want fine control over smoothness

**Parameters:**
- `-t <tension>` - Tension parameter (0.0-1.0, default: 0.0)
  - `0.0` = Standard Catmull-Rom (smooth, may overshoot)
  - `0.3` = Balanced (recommended)
  - `0.5` = Tight (less overshoot)
  - `1.0` = Linear interpolation (no overshoot, not smooth)

**Examples:**
```bash
./4psi -m 2 -t 0.0 alt_mytrack.txt  # Smooth, may overshoot
./4psi -m 2 -t 0.3 alt_mytrack.txt  # Balanced (recommended)
./4psi -m 2 -t 0.7 alt_mytrack.txt  # Tight, minimal overshoot
```

---

### Method 3: Limited Slopes (Clamped)

**Command:** `./4psi -m 3 alt_mytrack.txt`

**Characteristics:**
- ✅ Simple and fast
- ✅ Prevents extreme overshoot
- ✅ C² continuity
- ⚠️ Less sophisticated than other methods

**Use case:** Quick processing when you need basic overshoot prevention

**Parameters:**
- `-s <factor>` - Smoothing factor (default: 4.0)

**Example:**
```bash
./4psi -m 3 alt_mytrack.txt
```

---

### Method 4: OPTIMAL ⭐⭐⭐ RECOMMENDED

**Command:** `./4psi -m 4 alt_mytrack.txt`

**Characteristics:**
- ✅ Maximum smoothness (C² continuity)
- ✅ Adaptive overshoot prevention
- ✅ Closed-loop support (wraparound continuity)
- ✅ Weighted harmonic mean for conservative slopes
- ✅ Adjustable via alpha parameter

**Use case:** Best overall choice for most altitude profiles

**Parameters:**
- `-s <factor>` - Smoothing factor (default: 8.0, higher = smoother)
- `-t <alpha>` - Overshoot prevention (0.0-1.0, default: 0.85)
  - `0.0` = Maximum smoothness (may overshoot)
  - `0.85` = Optimal balance (recommended)
  - `1.0` = Maximum constraint (guaranteed no overshoot)

**Examples:**
```bash
./4psi -m 4 alt_mytrack.txt                    # Optimal defaults
./4psi -m 4 -s 10.0 -t 0.9 alt_mytrack.txt     # Extra smooth, tight constraint
./4psi -m 4 -s 6.0 -t 0.7 alt_mytrack.txt      # Less smooth, looser constraint
```

## Input File Format

The input file should be a CSV format with altitude data:

```
Section_Name, Length, Altitude_Trace1, Altitude_Trace2, ...
```

**Example:**
```
Sec0, 151.6, 1, 1
Sec1, 195.4, 1, 12
Sec2, 223.3, 12, 12
```

## Output Files

4psi generates two main output files:

### 1. `__do_plot_all.txt`

Gnuplot script containing:
- Function definitions for each section
- Plot commands with proper ranges
- Can be directly executed with gnuplot

**Usage:**
```bash
gnuplot __do_plot_all.txt
# Press Enter to view each section
```

### 2. `__gtk_csv.TXT`

CSV file with cubic spline coefficients:
```
section, length, d, a, b, c, gradient_angle, ...
```

Where the altitude function for each section is:
```
f(x) = a*x³ + b*x² + c*x + d
```

## Method Comparison

| Method | Smoothness | Overshoot | Continuity | Speed | Best For |
|--------|-----------|-----------|------------|-------|----------|
| **0 - Four Point** | ⭐⭐⭐⭐⭐ | ⚠️ High | C² | Fast | Smooth terrain |
| **1 - Monotone** | ⭐⭐⭐ | ✅ None | C¹ | Fast | Accuracy critical |
| **2 - Catmull-Rom** | ⭐⭐⭐⭐ | ⚠️ Adjustable | C¹ | Fast | Fine control needed |
| **3 - Limited** | ⭐⭐⭐ | ✅ Minimal | C² | Fast | Quick processing |
| **4 - OPTIMAL** ⭐ | ⭐⭐⭐⭐⭐ | ✅ None | C² | Medium | **All tracks** |

## Common Use Cases

### Racing/Competition (Accuracy Critical)
```bash
./4psi -m 4 alt_mytrack.txt
# or
./4psi -m 1 alt_mytrack.txt
```

### Visualization (Smooth Appearance)
```bash
./4psi -m 4 -s 10.0 alt_mytrack.txt
```

### Quick Processing
```bash
./4psi -m 3 alt_mytrack.txt
```

### Fine-Tuning
```bash
# Try different methods and compare
./4psi -m 1 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_monotone.TXT

./4psi -m 4 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_optimal.TXT

# Compare the results
```

## Troubleshooting

### "Too smooth, looks unrealistic"
**Solution:** Increase alpha (method 4) or tension (method 2)
```bash
./4psi -m 4 -t 0.95 alt_mytrack.txt
```

### "Still seeing bumps/overshoot"
**Solution:** Use monotone method or increase alpha
```bash
./4psi -m 1 alt_mytrack.txt
# or
./4psi -m 4 -t 1.0 alt_mytrack.txt
```

### "Not smooth enough, visible kinks"
**Solution:** Use OPTIMAL method with higher smoothing
```bash
./4psi -m 4 -s 12.0 alt_mytrack.txt
```

### "Need to see the difference between methods"
**Solution:** Use the comparison system
```bash
make alt_mytrack.alt  # Generates comparison plots
```

## Advanced Features

### Closed-Loop Tracks

Method 4 (OPTIMAL) automatically detects and handles closed-loop tracks (like race circuits) by ensuring slope continuity at the wraparound point.

**No special flags needed** - it just works!

### Multiple Traces

4psi supports multiple altitude traces in the input file. Each trace is processed independently with the same smoothing method.

### Integration with Make

Use the Makefile for convenient workflows:

```bash
# Run specific method
make method4

# Generate all comparison plots
make alt_mytrack.alt

# Clean generated files
make clean
```

## Technical Details

### C² Continuity (Methods 0, 3, 4)

The altitude function and its first two derivatives are continuous at all junction points:
- `f(x)` is continuous (position)
- `f'(x)` is continuous (slope/gradient)
- `f''(x)` is continuous (curvature)

This ensures visually smooth curves without abrupt changes in curvature.

### C¹ Continuity (Methods 1, 2)

Only the function and its first derivative are continuous:
- `f(x)` is continuous (position)
- `f'(x)` is continuous (slope/gradient)

May show slight "kinks" where curvature changes abruptly.

### Overshoot Prevention

**Overshoot** occurs when the smoothed curve exceeds the input altitude values, creating unrealistic peaks or valleys.

Methods 1, 3, and 4 use various techniques to prevent this:
- **Method 1:** Fritsch-Carlson monotonicity constraints
- **Method 3:** Slope clamping to adjacent segment range
- **Method 4:** Adaptive constraints with harmonic mean

## Performance

All methods are fast enough for interactive use:
- Small tracks (<100 sections): < 1 second
- Large tracks (>1000 sections): < 5 seconds

Method 4 is slightly slower due to the two-pass algorithm for closed-loop handling.

## Examples

### Example 1: Process a simple track
```bash
./4psi -m 4 alt_mytrack.txt
gnuplot __do_plot_all.txt
```

### Example 2: Compare multiple methods
```bash
# Generate comparison plots
make alt_mytrack.alt

# View the results
display comparison_optimal.png
display pulse_sections.png
```

### Example 3: Fine-tune OPTIMAL method
```bash
# Try different alpha values
./4psi -m 4 -t 0.7 alt_mytrack.txt   # More smooth
./4psi -m 4 -t 0.9 alt_mytrack.txt   # Less smooth
./4psi -m 4 -t 1.0 alt_mytrack.txt   # Maximum constraint
```

### Example 4: Batch processing
```bash
for file in alt_*.txt; do
    echo "Processing $file..."
    ./4psi -m 4 "$file"
    mv __gtk_csv.TXT "${file%.txt}_output.csv"
done
```

## Getting Help

```bash
# Show help message
./4psi -h

# View this guide
less 4PSI_USER_GUIDE.md

# Check the README
less README.md
```

## Version Information

**Current Version:** 2.0  
**Methods Available:** 5 (0-4)  
**Default Method:** 1 (Monotone)  
**Recommended Method:** 4 (OPTIMAL) ⭐

## See Also

- `README.md` - Project overview
- `OPTIMAL_ALGORITHM.md` - Technical details of method 4
- `Makefile` - Automated workflows
- `compare_optimal.pl` - Method comparison tool

---

**Pro Tip:** When in doubt, use method 4 (OPTIMAL) with default settings. It provides the best balance of smoothness and accuracy for most use cases.
