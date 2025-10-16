# Understanding Altitude Overshoot

## Visual Explanation

### What is Overshoot?

Imagine you have three altitude points on your track:

```
Point A: 100m
Point B: 120m  
Point C: 110m
```

### Bad (Original Method - Can Overshoot)

```
Altitude
  ^
130m|           *  ← OVERSHOOT! Curve peaks at 125m
    |          / \    (higher than any input point)
120m|    B----+   \
    |   /          \
110m|  /            C
    | /
100m|A
    +-------------------> Distance
```

The curve goes **above 120m** even though no input point is that high!

### Good (Monotone Method - No Overshoot)

```
Altitude
  ^
120m|    B-------+
    |   /         \
110m|  /           C
    | /
100m|A
    +-------------------> Distance
```

The curve stays **within the bounds** of the input points (100m-120m).

---

## Real-World Impact

### Example 1: Flat Section with Small Bump

**Input:**
```
Section 1: 50m altitude
Section 2: 52m altitude (small bump)
Section 3: 50m altitude
```

**Original Method (Overshoot):**
```
    55m |     *     ← Unrealistic peak!
        |    / \
    52m |   +   +   ← Actual input
        |  /     \
    50m |-+-------+-
```
Result: Exaggerated 5m bump instead of 2m

**Monotone Method (No Overshoot):**
```
    52m |   +---+   ← Stays at input level
        |  /     \
    50m |-+-------+-
```
Result: Accurate 2m bump

---

### Example 2: Downhill Section

**Input:**
```
Section 1: 100m
Section 2: 80m
Section 3: 60m
```

**Original Method (Overshoot):**
```
100m|+
    | \
 80m|  +
    |   \
 60m|    +
    |     \
 55m|      *  ← Dips below 60m!
```
Result: Unrealistic valley

**Monotone Method (No Overshoot):**
```
100m|+
    | \
 80m|  +
    |   \
 60m|    +
```
Result: Smooth descent, no false valley

---

## Why Does Overshoot Happen?

### Cubic Splines are Flexible

A cubic polynomial `f(x) = Ax³ + Bx² + Cx + D` can curve in complex ways:

```
    *  ← Can wiggle up
   / \
  /   \  ← And down
 /     *
```

### The Problem: Unconstrained Slopes

Original method calculates slopes without checking if they cause overshoot:

```perl
# Original: Just blends slopes
SL = slope_mid + (slope_right + slope_mid) / smooth;
```

This can create slopes that are **too steep**, causing the curve to overshoot.

---

## How Monotone Method Fixes It

### 1. Detect Extrema (Peaks/Valleys)

```perl
if(sign(slope_left) != sign(slope_mid)) {
   slope = 0;  # Flat at peak/valley
}
```

**Example:**
```
Slopes: +5, -3  ← Sign change!
Action: Set slope = 0 at transition
Result: Smooth peak, no overshoot
```

### 2. Use Harmonic Mean (Not Arithmetic)

**Arithmetic mean** (original):
```
slope = (5 + 10) / 2 = 7.5  ← Can be too steep
```

**Harmonic mean** (monotone):
```
slope = 2 / (1/5 + 1/10) = 6.67  ← More conservative
```

Harmonic mean **prevents extreme values** from dominating.

### 3. Apply Fritsch-Carlson Constraint

```perl
if(abs(slope / slope_mid) > 3.0) {
   slope = 3.0 * slope_mid;  # Limit to 3× segment slope
}
```

**Example:**
```
Segment slope: 2
Calculated slope: 8  ← Too steep!
Constrained slope: 6  ← Limited to 3×2
```

---

## Visual Comparison: All Methods

### Test Case: Sharp Peak

**Input Points:**
```
A: 10m, B: 30m, C: 15m
```

### Method 0: Original
```
35m |     *  ← Overshoots to 35m
    |    / \
30m |   B   \
    |  /     \
15m | /       C
10m |A
```
**Overshoot:** +5m (17% error)

### Method 1: Monotone ⭐
```
30m |   B---+
    |  /     \
15m | /       C
10m |A
```
**Overshoot:** 0m (perfect)

### Method 2: Catmull-Rom (tension=0.3)
```
32m |    *  ← Small overshoot
    |   / \
30m |  B   \
    | /     \
15m |/       C
10m |A
```
**Overshoot:** +2m (7% error)

### Method 3: Limited
```
31m |    *  ← Minimal overshoot
    |   / \
30m |  B   \
    | /     \
15m |/       C
10m |A
```
**Overshoot:** +1m (3% error)

---

## When Does Overshoot Matter Most?

### High Impact Scenarios:
1. **Flat sections with small bumps** → Overshoot exaggerates bumps
2. **Sharp peaks/valleys** → Creates false extrema
3. **Alternating up/down** → Oscillations amplified
4. **Precise elevation data** → Accuracy is critical

### Low Impact Scenarios:
1. **Smooth, gradual terrain** → Overshoot is minimal
2. **Large-scale features** → Small overshoot is negligible
3. **Approximate data** → Already has error margin

---

## Choosing the Right Method

### Decision Tree:

```
Do you need guaranteed no overshoot?
├─ YES → Method 1 (Monotone) ⭐
└─ NO
   ├─ Want maximum smoothness?
   │  └─ YES → Method 0 (Original) or Method 2 (Catmull-Rom, low tension)
   └─ Want to fine-tune?
      └─ YES → Method 2 (Catmull-Rom, adjust tension)
```

### Quick Recommendations:

| Terrain Type | Recommended Method | Command |
|--------------|-------------------|---------|
| **Varied/Hilly** | Monotone | `./4p_improved -m 1` |
| **Smooth/Gradual** | Original or Catmull-Rom | `./4p` or `./4p_improved -m 2 -t 0.2` |
| **Mixed** | Monotone | `./4p_improved -m 1` |
| **Experimental** | Catmull-Rom | `./4p_improved -m 2 -t 0.3` |

---

## Testing for Overshoot

### Method 1: Visual Inspection
```bash
# Generate plots
./4p_improved -m 1 alt_mytrack.txt
gnuplot __do_plot_all.txt

# Look for:
# - Curves exceeding input points
# - Unrealistic bumps/dips
# - Oscillations
```

### Method 2: Compare Methods
```bash
# Run comparison
./compare_methods.pl alt_mytrack.txt
gnuplot compare_all.gnuplot

# View comparison.png
# Side-by-side comparison shows overshoot clearly
```

### Method 3: Check Extrema
```bash
# For each section, verify:
# - Maximum altitude ≤ max(input points)
# - Minimum altitude ≥ min(input points)
```

---

## Mathematical Proof (Monotone Method)

### Theorem (Fritsch-Carlson, 1980):
If slopes S₀ and S_L satisfy:
1. Sign consistency: `sign(S₀) = sign(S_L) = sign(slope_segment)`
2. Magnitude constraint: `|S₀| ≤ 3|slope_segment|` and `|S_L| ≤ 3|slope_segment|`

Then the cubic Hermite spline is **monotone** (no overshoot) between the endpoints.

### Why It Works:
The constraints ensure the cubic polynomial's derivative `f'(x) = 3Ax² + 2Bx + C` doesn't change sign within the interval, preventing local extrema.

---

## Summary

**Overshoot** = Curve exceeds input altitude bounds

**Causes:**
- Unconstrained cubic splines
- Poor slope estimation
- No monotonicity checking

**Solution:**
- Monotone method (Fritsch-Carlson)
- Harmonic mean for slopes
- Magnitude constraints
- Extrema detection

**Result:**
- Realistic altitude profiles
- No false peaks/valleys
- Smooth transitions
- Accurate elevation data

**Recommendation:** Use `./4p_improved -m 1` for guaranteed no overshoot!
