# Altitude Smoothing Methods - Minimizing Overshoot

## Problem Overview

When generating cubic spline equations for altitude profiles, **overshoot** occurs when the interpolated curve goes beyond the range of the input altitude values. This creates unrealistic bumps and dips in the track profile.

## Available Methods

### Method 0: Original (Baseline)
**Command:** `./4p <input_file>` or `./4p_improved -m 0 <input_file>`

The original implementation uses a simple blending approach:
- Blends adjacent slopes using a smoothing factor (default 4.0)
- Can produce overshoot in areas with varying slopes
- Good for gentle, uniform terrain

**Pros:**
- Simple and fast
- Works well for smooth, gradual changes

**Cons:**
- Can overshoot significantly with sharp altitude changes
- No monotonicity guarantee

---

### Method 1: Monotone (Fritsch-Carlson) - **RECOMMENDED**
**Command:** `./4p_improved -m 1 <input_file>`

Implements the Fritsch-Carlson monotone cubic interpolation algorithm:
- **Prevents overshoot** by ensuring monotonicity between points
- Uses harmonic mean for slope calculation
- Applies constraints to limit slope magnitude (max 3x the segment slope)
- Sets slope to zero at local extrema

**Pros:**
- **No overshoot** - curve stays within altitude bounds
- Smooth and natural-looking transitions
- Preserves monotonicity (no false peaks/valleys)
- Best for realistic terrain profiles

**Cons:**
- Slightly less smooth than unconstrained methods
- May appear "flat" at transition points

**When to use:** This is the **default and recommended method** for most altitude profiles, especially with varied terrain.

---

### Method 2: Catmull-Rom with Tension
**Command:** `./4p_improved -m 2 -t <tension> <input_file>`

Uses Catmull-Rom splines with adjustable tension parameter:
- Tension = 0.0: Standard Catmull-Rom (smooth, may overshoot)
- Tension = 0.5: Moderate tension (balanced)
- Tension = 1.0: Maximum tension (nearly linear, no overshoot)

**Pros:**
- Highly adjustable via tension parameter
- Very smooth curves with low tension
- Can eliminate overshoot with high tension

**Cons:**
- Requires tuning the tension parameter
- Low tension can still overshoot
- High tension may look too linear

**When to use:** When you want fine control over smoothness vs. overshoot tradeoff.

**Example commands:**
```bash
./4p_improved -m 2 -t 0.0 input.txt  # Smooth, may overshoot
./4p_improved -m 2 -t 0.3 input.txt  # Balanced
./4p_improved -m 2 -t 0.7 input.txt  # Tight, minimal overshoot
```

---

### Method 3: Limited Slopes (Clamped)
**Command:** `./4p_improved -m 3 <input_file>`

Uses slope averaging with hard clamping:
- Averages adjacent slopes
- Clamps result to min/max of adjacent slopes
- Simple constraint-based approach

**Pros:**
- Reduces overshoot significantly
- Simple to understand
- Fast computation

**Cons:**
- Can create visible "kinks" at boundaries
- Less smooth than monotone method
- May still have minor overshoot

**When to use:** When you need a simple, fast method with reduced overshoot.

---

## Comparison and Recommendations

### For Different Terrain Types:

1. **Varied/Hilly Terrain** → **Method 1 (Monotone)**
   - Best prevents unrealistic bumps
   - Maintains natural-looking slopes

2. **Smooth/Gradual Terrain** → **Method 0 (Original)** or **Method 2 (Catmull-Rom, low tension)**
   - Smoother curves
   - Less constraint needed

3. **Mixed Terrain** → **Method 1 (Monotone)**
   - Safe default choice
   - Handles all cases well

4. **Fine-Tuning Required** → **Method 2 (Catmull-Rom with tension)**
   - Adjust tension to taste
   - Start with 0.3 and adjust

### Quick Start Guide:

```bash
# Make scripts executable
chmod +x 4p 4p_improved compare_methods.pl

# Try the recommended method (Monotone)
./4p_improved -m 1 alt_mytrack.txt

# Compare all methods visually
./compare_methods.pl alt_mytrack.txt
gnuplot compare_all.gnuplot
# View comparison.png

# Experiment with Catmull-Rom tension
./4p_improved -m 2 -t 0.3 alt_mytrack.txt  # Balanced
./4p_improved -m 2 -t 0.5 alt_mytrack.txt  # Tighter
./4p_improved -m 2 -t 0.7 alt_mytrack.txt  # Very tight
```

## Technical Details

### Overshoot Causes:
1. **Slope discontinuities** between sections
2. **Excessive curvature** from unconstrained cubic polynomials
3. **Poor slope estimation** at transition points

### How Methods Address Overshoot:

**Monotone (Method 1):**
- Detects sign changes in slopes → sets slope to 0
- Uses harmonic mean (weighted average that prevents extremes)
- Applies Fritsch-Carlson constraint: |slope| ≤ 3 × |segment_slope|

**Catmull-Rom (Method 2):**
- Tension parameter reduces curvature: `slope = (1-t) × standard_slope`
- Higher tension → flatter curves → less overshoot

**Limited (Method 3):**
- Hard clamps: `min(slope_left, slope_mid) ≤ slope ≤ max(slope_left, slope_mid)`
- Prevents slopes from exceeding adjacent segment slopes

## Output Files

All methods generate:
- `__do_plot_all.txt` - Gnuplot script for visualization
- `__gtk_csv.TXT` - CSV with normalized coefficients for GPL track format

## References

- Fritsch, F. N., & Carlson, R. E. (1980). "Monotone Piecewise Cubic Interpolation"
- Catmull, E., & Rom, R. (1974). "A Class of Local Interpolating Splines"
