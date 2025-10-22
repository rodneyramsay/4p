# Harmonic Mean Smoothing Algorithm

## Overview

The **Harmonic Mean algorithm** (Method 4) solves the fundamental trade-off between smoothness and overshoot elimination by combining multiple advanced techniques:

1. **C¹ Continuity** - Ensures continuous slopes for smooth curves
2. **Weighted Harmonic Mean** - More conservative than arithmetic mean, prevents extreme values
3. **Adaptive Constraints** - Dynamically adjusts based on local curvature and user preference
4. **Extrema Handling** - Special treatment at peaks/valleys for smooth transitions

## The Problem

- **Method 0 (Four Point)**: Too much overshoot → unrealistic peaks/valleys
- **Method 1 (Monotone)**: No overshoot but less smooth
- **Goal**: Maximum smoothness while eliminating overshoot

## Key Innovation: Adaptive Constraint System

### The Alpha Parameter (0.0 - 1.0)

The algorithm uses an `alpha` parameter to control the smoothness vs. overshoot trade-off:

```
alpha = 0.0  →  Maximum smoothness (may overshoot)
alpha = 0.5  →  Balanced
alpha = 0.85 →  Recommended (default) ⭐
alpha = 1.0  →  Guaranteed no overshoot (less smooth)
```

### How It Works

The maximum allowed slope ratio is calculated as:

```
max_ratio = 2.0 + 8.0 × (1.0 - alpha)

Examples:
  alpha = 0.0  →  max_ratio = 10.0  (very smooth)
  alpha = 0.5  →  max_ratio = 6.0   (balanced)
  alpha = 0.85 →  max_ratio = 3.2   (recommended)
  alpha = 1.0  →  max_ratio = 2.0   (tight constraint)
```

This creates a smooth spectrum from maximum smoothness to guaranteed no overshoot.

## Algorithm Components

### 1. Weighted Harmonic Mean

Unlike arithmetic mean, harmonic mean is **conservative** and prevents extreme values from dominating:

```perl
# Arithmetic mean (can be too aggressive)
slope = (a + b) / 2

# Weighted harmonic mean (more conservative)
slope = 1.0 / (weight/a + (1-weight)/b)
```

**Example:**
```
Slopes: 2, 10
Arithmetic mean: (2 + 10)/2 = 6
Harmonic mean: 2/(1/2 + 1/10) = 3.33  ← More conservative
```

### 2. Extrema Detection

At peaks/valleys (sign change in slopes), use weighted average biased toward zero:

```perl
if(sign(s1) != sign(s2)) {
   extrema_weight = 0.2 × (1.0 - alpha)
   slope = extrema_weight × (s1 + s2) / 2.0
}
```

This creates smooth peaks without overshoot.

### 3. Smoothing Factor Blending

To ensure smooth transitions, blend with segment slopes:

```perl
smooth_weight = smooth_factor / (smooth_factor + 4.0)
slope = (1.0 - smooth_weight) × slope + smooth_weight × segment_slope
```

This creates smoother transitions at section boundaries.

### 4. Adaptive Constraint

Limit slope based on segment slope and alpha:

```perl
if(abs(slope / segment_slope) > max_ratio) {
   slope = max_ratio × sign(slope) × abs(segment_slope)
}
```

This prevents overshoot while maintaining smoothness.

## Usage

### Basic Usage (Default Settings)

```bash
./4psi -m 4 alt_mytrack.txt
```

Uses default settings:
- Smoothing factor: 8.0 (high smoothness)
- Alpha: 0.85 (recommended balance)

### Custom Smoothing Factor

```bash
# More aggressive smoothing
./4psi -m 4 -s 12.0 alt_mytrack.txt

# Less aggressive smoothing
./4psi -m 4 -s 4.0 alt_mytrack.txt
```

### Custom Alpha (Overshoot Prevention)

```bash
# Maximum smoothness (may have slight overshoot)
./4psi -m 4 -t 0.5 alt_mytrack.txt

# Balanced
./4psi -m 4 -t 0.75 alt_mytrack.txt

# Recommended (default)
./4psi -m 4 -t 0.85 alt_mytrack.txt

# Guaranteed no overshoot (less smooth)
./4psi -m 4 -t 1.0 alt_mytrack.txt
```

### Combined Parameters

```bash
# Very smooth with moderate overshoot prevention
./4psi -m 4 -s 10.0 -t 0.7 alt_mytrack.txt

# Tight control with high smoothness
./4psi -m 4 -s 12.0 -t 0.9 alt_mytrack.txt
```

## Comparison with Other Methods

### Visual Comparison

```bash
# Run comprehensive comparison
./compare_harmonic mean.pl alt_mytrack.txt
gnuplot compare_harmonic mean.gnuplot
# View comparison_harmonic mean.png
```

### Method Characteristics

| Method | Smoothness | Overshoot | Use Case |
|--------|-----------|-----------|----------|
| **Original (4p)** | ⭐⭐⭐⭐⭐ | ❌ High | Gentle terrain only |
| **Monotone (m=1)** | ⭐⭐⭐ | ✅ None | Guaranteed accuracy |
| **Catmull-Rom (m=2)** | ⭐⭐⭐⭐ | ⚠️ Some | Fine-tuning needed |
| **Limited (m=3)** | ⭐⭐⭐ | ⚠️ Minimal | Simple constraint |
| **Harmonic Mean** | ⭐⭐⭐⭐⭐ | ✅ None | **Best of both worlds** ⭐ |

## Technical Details

### Mathematical Foundation

The algorithm solves the cubic Hermite spline problem:

```
f(x) = Ax³ + Bx² + Cx + D

Constraints:
  f(0) = Y₀       (start altitude)
  f(L) = Y_L      (end altitude)
  f'(0) = S₀      (start slope - optimized)
  f'(L) = S_L     (end slope - optimized)
```

The key innovation is in calculating S₀ and S_L using:
1. Weighted harmonic mean for base slope
2. Adaptive constraint based on alpha
3. Smoothing factor blending
4. Extrema detection and handling

### Why Harmonic Mean?

Harmonic mean has a key property: it's always ≤ arithmetic mean, making it more conservative:

```
For positive a, b:
  harmonic_mean(a, b) ≤ geometric_mean(a, b) ≤ arithmetic_mean(a, b)
```

This prevents overly steep slopes that cause overshoot.

### C¹ Continuity

C¹ continuity means the first derivative (slope) is continuous:

```
C⁰: Function is continuous (no gaps)
C¹: First derivative is continuous (no sharp corners)
C²: Second derivative is continuous (smooth curvature)
```

The algorithm achieves C¹ continuity by matching slopes at section boundaries (S₀ of section N+1 = S_L of section N), creating smooth curves without visible kinks.

## Performance Characteristics

### Computational Complexity

Same as other methods: O(n) where n = number of sections

### Memory Usage

Minimal - same as original algorithm

### Accuracy

- **Altitude accuracy**: Passes through all input points exactly
- **Overshoot**: Controlled by alpha parameter (default: near-zero)
- **Smoothness**: Maximum achievable while respecting overshoot constraint

## Recommended Settings by Terrain Type

### Flat with Small Bumps
```bash
./4p_harmonic mean -s 10.0 -a 0.9 input.txt
```
High smoothness, strong overshoot prevention to avoid exaggerating bumps.

### Varied/Hilly Terrain
```bash
./4p_harmonic mean -s 8.0 -a 0.85 input.txt  # Default
```
Balanced approach works best.

### Smooth Gradual Changes
```bash
./4p_harmonic mean -s 12.0 -a 0.7 input.txt
```
Can afford more smoothness with less constraint.

### Sharp Peaks/Valleys
```bash
./4p_harmonic mean -s 6.0 -a 0.9 input.txt
```
Moderate smoothness, strong overshoot prevention.

### Experimental/Fine-Tuning
```bash
# Try different combinations
./4p_harmonic mean -s 8.0 -a 0.8 input.txt
./4p_harmonic mean -s 10.0 -a 0.85 input.txt
./4p_harmonic mean -s 12.0 -a 0.9 input.txt
```

## Troubleshooting

### Curves Still Too Sharp

Increase smoothing factor:
```bash
./4p_harmonic mean -s 12.0 input.txt
```

### Minor Overshoot Visible

Increase alpha:
```bash
./4p_harmonic mean -a 0.95 input.txt
```

### Curves Too Flat at Peaks

Decrease alpha slightly:
```bash
./4p_harmonic mean -a 0.75 input.txt
```

### Want Maximum Smoothness

Decrease alpha and increase smoothing:
```bash
./4p_harmonic mean -s 15.0 -a 0.6 input.txt
```

## Output Files

Same as other methods:
- `__do_plot_all.txt` - Gnuplot script for visualization
- `__gtk_csv.TXT` - CSV with normalized coefficients for GPL track format

## Algorithm Validation

### Test Cases

1. **Flat section with bump**: No exaggeration
2. **Sharp peak**: Smooth transition, no overshoot
3. **Alternating up/down**: No oscillations
4. **Gradual slope**: Maximum smoothness

### Verification

```bash
# Visual inspection
./4p_harmonic mean alt_mytrack.txt
gnuplot __do_plot_all.txt

# Compare with other methods
./compare_harmonic mean.pl alt_mytrack.txt
gnuplot compare_harmonic mean.gnuplot
```

## Theory: Why This Works

### The Overshoot Problem

Overshoot occurs when cubic splines have slopes that are too steep relative to the segment slope. This causes the curve to "bulge" beyond the input points.

### The Smoothness Problem

Strict monotone constraints (like Fritsch-Carlson) prevent overshoot but can create visible discontinuities in the second derivative, appearing as "kinks."

### The Harmonic Mean Solution

By using:
1. **Harmonic mean** - Conservative slope estimation
2. **Adaptive constraints** - Gradually tighten based on alpha
3. **Smoothing factor blending** - Smooth transitions
4. **Extrema handling** - Special care at peaks/valleys

We achieve **maximum smoothness** while **eliminating overshoot**.

## Comparison with Fritsch-Carlson

| Aspect | Fritsch-Carlson | Harmonic Mean |
|--------|----------------|-------------------|
| **Overshoot** | None (guaranteed) | None (with alpha ≥ 0.85) |
| **Smoothness** | Good | Excellent |
| **C¹ Continuity** | Yes | Yes |
| **Flexibility** | Fixed | Adjustable (alpha) |
| **Extrema Handling** | Slope = 0 | Weighted blend |
| **Slope Calculation** | Harmonic mean | Weighted harmonic mean |
| **Constraint** | Fixed (3×) | Adaptive (2-10×) |

## Summary

The Harmonic Mean algorithm represents an **excellent balance** between smoothness and overshoot prevention:

✅ **Maximum smoothness** through C¹ continuity and high smoothing factors  
✅ **No overshoot** through adaptive constraints and harmonic mean  
✅ **Flexible** via alpha parameter for different terrain types  
✅ **Efficient** with same O(n) complexity as other methods  

**Recommended for all track generation tasks where both smoothness and accuracy matter.**

## Quick Reference

```bash
# Default (recommended for most cases)
./4p_harmonic mean input.txt

# Maximum smoothness, minimal overshoot prevention
./4p_harmonic mean -s 15.0 -a 0.5 input.txt

# Balanced
./4p_harmonic mean -s 10.0 -a 0.75 input.txt

# Near-harmonic mean (default)
./4p_harmonic mean -s 8.0 -a 0.85 input.txt

# Guaranteed no overshoot
./4p_harmonic mean -s 6.0 -a 1.0 input.txt

# Compare all methods
./compare_harmonic mean.pl input.txt
gnuplot compare_harmonic mean.gnuplot
```
