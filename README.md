# 4psi - 4 Point Spline Interpolation

GPL Track Altitude Equation Generator

Create GPL track editing altitude trace equation coefficients. Each equation is defined by 4 point sets that make up the previous, current and next sections start and end points.

## Usage

**4psi** provides 5 smoothing methods for altitude profile generation:

```bash
# Method 0: Original blending (smooth, may overshoot)
./4psi -m 0 alt_mytrack.txt

# Method 1: Monotone (Fritsch-Carlson, no overshoot, C¹ continuity)
./4psi -m 1 alt_mytrack.txt

# Method 2: Catmull-Rom with tension (adjustable smoothness)
./4psi -m 2 -t 0.3 alt_mytrack.txt

# Method 3: Limited slopes (fast, minimal overshoot)
./4psi -m 3 alt_mytrack.txt

# Method 4: OPTIMAL (RECOMMENDED - maximum smoothness, no overshoot, C² continuity)
./4psi -m 4 alt_mytrack.txt

# Generate all comparison plots
./generate_all_plots.pl alt_mytrack.txt
```

## Algorithm Comparison

| Method | Algorithm | Smoothness | Overshoot | Continuity | Use Case |
|--------|-----------|-----------|-----------|------------|----------|
| **0** | Original | ⭐⭐⭐⭐⭐ | ❌ High | C² | Legacy only |
| **1** | Monotone | ⭐⭐⭐ | ✅ None | C¹ | Accuracy critical |
| **2** | Catmull-Rom | ⭐⭐⭐⭐ | ⚠️ Adjustable | C¹ | Fine control |
| **3** | Limited Slopes | ⭐⭐⭐ | ✅ Minimal | C² | Quick processing |
| **4** | OPTIMAL | ⭐⭐⭐⭐⭐ | ✅ None | C² | **Recommended** ⭐ |

📖 **See [OPTIMAL_ALGORITHM.md](OPTIMAL_ALGORITHM.md) for technical details**  
📖 **See [SOLUTION_SUMMARY.md](SOLUTION_SUMMARY.md) for complete documentation**  
📖 **See [QUICK_TEST.md](QUICK_TEST.md) for testing guide**

## Section Splitting Test

Test the cubic spline section splitting algorithm with `split_section_test.pl`:

```bash
# Run the split section test
perl split_section_test.pl

# Generate visualization
gnuplot split_section_plot.gnuplot
```

This demonstrates how a cubic function can be split at any point while maintaining:
- **C⁰ continuity**: Position matches at split point
- **C¹ continuity**: Slope matches at split point
- **Exact reconstruction**: Split sections perfectly reproduce the original function

**Current test:** `y = x³ - 15x - 4` from `[-5, 5]` split at `x = 3`

--- 

Import altitude data one column for each trace.

Input Format:

`   Section Name, Section Length, Trace 1 Altitude, Trace 2 Altitude, ...`

Where `Trace Altitude` is the elevation (Y value) at the start of the section for each trace.

The 4psi program also creates stitched gnuplot derived formulas for each trace and section of the track for visualizing equation curves. 


Equations for solving functions. 

$f(x) = Ax^3 + Bx^2 + Cx + D$ ; Equation for altitude or Y at any X location

$f'(x) = 3Ax^2 + 2Bx + C$;  Equation derivitave for slope of altitudes

$f(0) = Y_0 = D$;  Altitude at the start of a section

$f(L) = Y_L = AL^3 + BL^2 + CL$;  Altitude at the end of a section

$f'(0) = S_0 = C$;  Slope at the start of a section

$f'(L) = S_L = 3AL^2 + 2BL + S_0$;   Slope at the end of a section


Subtract $2f(L) - Lf'(L)$ to get $A$

$A = 1/L^3 [L(S_0 + S_L) + 2(Y_0 - Y_L)]$

Solve for $B$ in $f'(x)$

$B = 1/L^2 [(-2S_0 - S_L) - 3(Y_0 - Y_L)]$


Convert range from [0:L] to [0:1]

$A_{[0:1]} = L^3 A_{[0:L]}$

$B_{[0:1]} = L^2 B_{[0:L]}$

$C_{[0:1]} = L C_{[0:L]}$

$D_{[0:1]} = D_{[0:L]}$


**============================================================================**


### **$A = L(S_0 + S_L) + 2(Y_0 - Y_L)$**

### **$B = (-2S_0 - S_L) - 3(Y_0 - Y_L)$**

### **$C = LS_0$**

### **$D = Y_0$**


