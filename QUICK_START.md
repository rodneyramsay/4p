# Quick Start - Minimizing Altitude Overshoot

## TL;DR - Just want smooth altitude without overshoot?

```bash
./4p_improved -m 1 alt_mytrack.txt
```

This uses the **Monotone method** (Fritsch-Carlson), which prevents overshoot while maintaining smooth transitions.

---

## What's New?

I've created `4p_improved` with 4 different smoothing methods to minimize overshoot:

| Method | Command | Best For | Overshoot |
|--------|---------|----------|-----------|
| **Monotone** (Recommended) | `-m 1` | All terrain types | ✅ None |
| Catmull-Rom | `-m 2 -t 0.3` | Fine-tuning smoothness | ⚠️ Adjustable |
| Limited Slopes | `-m 3` | Simple/fast | ⚠️ Minimal |
| Original | `-m 0` or use `./4p` | Smooth gradual terrain | ❌ Can overshoot |

---

## Step-by-Step Usage

### 1. Test with your data
```bash
# Original method (for comparison)
./4p alt_mytrack.txt

# New monotone method (no overshoot)
./4p_improved -m 1 alt_mytrack.txt
```

### 2. Compare all methods visually
```bash
./compare_methods.pl alt_mytrack.txt
gnuplot compare_all.gnuplot
# Opens comparison.png showing all 4 methods side-by-side
```

### 3. Fine-tune if needed
```bash
# Adjust Catmull-Rom tension (0.0 = smooth, 1.0 = tight)
./4p_improved -m 2 -t 0.0 alt_mytrack.txt  # Smooth, may overshoot
./4p_improved -m 2 -t 0.3 alt_mytrack.txt  # Balanced
./4p_improved -m 2 -t 0.7 alt_mytrack.txt  # Tight, no overshoot
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

### 4p_improved Options:
```
-m <method>   Smoothing method:
              0 = Original blending
              1 = Monotone (Fritsch-Carlson) [DEFAULT]
              2 = Catmull-Rom with tension
              3 = Limited slopes

-s <factor>   Smoothing factor (default 4.0)
              Higher = smoother (original method only)

-t <tension>  Tension for Catmull-Rom (0.0-1.0, default 0.0)
              0.0 = smooth, may overshoot
              0.5 = balanced
              1.0 = tight, no overshoot

-h            Show help
```

### Examples:
```bash
# Default (monotone, no overshoot)
./4p_improved alt_mytrack.txt

# Original method with high smoothing
./4p_improved -m 0 -s 8.0 alt_mytrack.txt

# Catmull-Rom with moderate tension
./4p_improved -m 2 -t 0.4 alt_mytrack.txt

# Limited slopes (fast, simple)
./4p_improved -m 3 alt_mytrack.txt
```

---

## Output Files

Both `4p` and `4p_improved` generate:

1. **`__gtk_csv.TXT`** - CSV with altitude equation coefficients
   - Format: `section, length, d, a, b, c, gradient_angle` (repeated for each trace)
   - Used by GPL track editor

2. **`__do_plot_all.txt`** - Gnuplot script
   - Visualize altitude curves
   - Run: `gnuplot __do_plot_all.txt`

---

## Troubleshooting

### "Too smooth, looks flat"
→ Try Catmull-Rom with low tension: `./4p_improved -m 2 -t 0.2`

### "Still seeing small bumps"
→ Use monotone method: `./4p_improved -m 1`

### "Need maximum smoothness, don't care about overshoot"
→ Use original with high smoothing: `./4p_improved -m 0 -s 10.0`

### "Want to see the difference"
→ Run comparison: `./compare_methods.pl alt_mytrack.txt`

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
