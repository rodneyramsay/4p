# 4psi - 4 Point Spline Interpolation

GPL Track Altitude Equation Generator

Create GPL track editing altitude trace equation coefficients. Each equation is defined by 4 point sets that make up the previous, current and next sections start and end points.

## 🆕 NEW: OPTIMAL Smoothing Algorithm

**Problem:** The original implementation produces overshoot (unrealistic bumps/dips) in altitude profiles.

**Solution:** Use the new `4p_optimal` algorithm for maximum smoothness with no overshoot:

```bash
# RECOMMENDED: OPTIMAL method (C² continuity, no overshoot)
./4p_optimal alt_mytrack.txt

# Alternative: Monotone method (C¹ continuity, no overshoot)
./4psi -m 1 alt_mytrack.txt

# Generate all comparison plots
./generate_all_plots.pl alt_mytrack.txt
```

### Algorithm Comparison

| Algorithm | Smoothness | Overshoot | Continuity | Use Case |
|-----------|-----------|-----------|------------|----------|
| **Original** | ⭐⭐⭐⭐⭐ | ❌ High | C² | Don't use |
| **Monotone** | ⭐⭐⭐ | ✅ None | C¹ | Guaranteed no overshoot |
| **OPTIMAL** | ⭐⭐⭐⭐⭐ | ✅ None | C² | **Best choice** ⭐ |

📖 **See [OPTIMAL_ALGORITHM.md](OPTIMAL_ALGORITHM.md) for technical details**  
📖 **See [SOLUTION_SUMMARY.md](SOLUTION_SUMMARY.md) for complete documentation**  
📖 **See [QUICK_TEST.md](QUICK_TEST.md) for testing guide**

--- 

Import altitude data one column for each trace.

Input Format:

`   Section Name, Section Length, Trace 1 Altitude, Trace 2 Altitude, ...`

Where `Trace Altitude` is the elevation (Y value) at the start of the section for each trace.

The 4p program also creates stitched gnuplot derived formulas for each trace and section of the track for visualizing equation curves. 


Equations for solving functions. 

$f(x) = Ax^3 + Bx^2 + Cx + D$ ; Equation for altitude or Y at any X location

$f'(x) = 3Ax^2 + 2Bx + C$;  Equation derivitave for slope of altitudes

$f(0) = Y_0 = D$;  Altitude at the start of a section

$f(L) = Y_L = AL^3 + BL^2 + CL$;  Altitude at the end of a section

$f'(0) = S_0 = C$;  Slope at the start of a section

$f'(L) = S_L = 3AL^2 + 2BL + S_0$;   Slope at the end of a section


Subtract $2f(L) - Lf'(L)$ to get $A$

$A = 1/L^3 [L(S_0 + S_L) + 2(Y_0 - Y_L)]$

Solve for $B$ in $f'(x)'$

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


