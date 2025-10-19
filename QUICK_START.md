# Quick Start - Minimizing Altitude Overshoot

## TL;DR - Just want smooth altitude without overshoot?

```bash
./4psi -m 4 alt_mytrack.txt
```

This uses the **OPTIMAL method**, which provides maximum smoothness with no overshoot.

---

## What's Available?

**4psi** provides 5 different smoothing methods to minimize overshoot:

| Method | Command | Best For | Overshoot |
|--------|---------|----------|-----------|
| **OPTIMAL** (Recommended) | `-m 4` | All terrain types | ✅ None |
| Monotone | `-m 1` | Accuracy critical | ✅ None |
| Catmull-Rom | `-m 2 -t 0.3` | Fine-tuning smoothness | ⚠️ Adjustable |
| Limited Slopes | `-m 3` | Simple/fast | ⚠️ Minimal |
| Four Point | `-m 0` | Smooth terrain | ⚠️ High |

---

## Step-by-Step Usage

### 1. Test with your data
```bash
# OPTIMAL method (recommended)
./4psi -m 4 alt_mytrack.txt

# Monotone method (alternative)
./4psi -m 1 alt_mytrack.txt
```

### 2. Compare all methods visually
```bash
./generate_all_plots.pl alt_mytrack.txt
# Generates comparison plots for all methods
```

### 3. Fine-tune if needed
```bash
# Adjust OPTIMAL method alpha (0.0 = smooth, 1.0 = tight)
./4psi -m 4 -t 0.7 alt_mytrack.txt   # More smooth
./4psi -m 4 -t 0.85 alt_mytrack.txt  # Balanced (default)
./4psi -m 4 -t 1.0 alt_mytrack.txt   # Maximum constraint
```

---

## Understanding Overshoot

**Overshoot** = When the altitude curve goes higher/lower than your input points

### Example:
```
Input points:  10m → 20m → 15m
Bad (overshoot):  10m → 22m → 15m  ❌ (peaks at 22m!)
Good (monotone):  10m → 20m → 15m  ✅ (stays within bounds)
```

### Why it matters:
- Unrealistic bumps in flat sections
- Unexpected dips/peaks
- Poor driving feel in simulators
- Inaccurate elevation profiles

---

## Command Reference

### 4psi Options:
```
-m <method>   Smoothing method:
              0 = Four Point
              1 = Monotone (Fritsch-Carlson)
              2 = Catmull-Rom with tension
              3 = Limited slopes
              4 = OPTIMAL [DEFAULT]

-s <factor>   Smoothing factor (default 4.0, 8.0 for method 4)
              Higher = smoother

-t <value>    Tension (method 2) or alpha (method 4)
              Method 4: 0.0-1.0, default 0.85

-h            Show help
```

### Examples:
```bash
# Default (OPTIMAL, no overshoot)
./4psi -m 4 alt_mytrack.txt

# Monotone method
./4psi -m 1 alt_mytrack.txt

# Catmull-Rom with moderate tension
./4psi -m 2 -t 0.4 alt_mytrack.txt

# Limited slopes (fast, simple)
./4psi -m 3 alt_mytrack.txt
```

---

## Output Files

**4psi** generates:

1. **`__gtk_csv.TXT`** - CSV with altitude equation coefficients
   - Format: `section, length, d, a, b, c, gradient_angle` (repeated for each trace)
   - Used by GPL track editor

2. **`__do_plot_all.txt`** - Gnuplot script
   - Visualize altitude curves
   - Run: `gnuplot __do_plot_all.txt`

---

## Troubleshooting

### "Too smooth, looks flat"
→ Try lower alpha: `./4psi -m 4 -t 0.7`

### "Still seeing small bumps"
→ Use monotone method: `./4psi -m 1`

### "Need maximum smoothness for gentle terrain"
→ Use Four Point with high smoothing: `./4psi -m 0 -s 10.0`

### "Want to see the difference"
→ Run comparison: `./generate_all_plots.pl alt_mytrack.txt`

---

## Technical Notes

### Monotone Method (Method 1)
- Based on Fritsch-Carlson algorithm (1980)
- Guarantees no overshoot between points
- Uses harmonic mean for slope calculation
- Constrains slopes to ≤3× segment slope
- Sets slope to 0 at local extrema

### Why it works:
1. Detects when slopes change sign → prevents false peaks/valleys
2. Limits slope magnitude → prevents excessive curvature
3. Preserves monotonicity → curve stays within bounds

---

## Need More Info?

See `SMOOTHING_METHODS.md` for detailed technical documentation.
