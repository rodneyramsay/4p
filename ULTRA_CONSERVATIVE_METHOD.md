# Ultra-Conservative Smoothing Method (Method 4)

## Overview

Method 4 provides the **strictest overshoot prevention** by applying multiple aggressive constraints to minimize any altitude deviation from input data.

## Key Features

### 1. **Minimum Slope Selection**
Instead of averaging or blending slopes, always chooses the **smallest absolute slope**:
```perl
if(abs($slope_left) < abs($slope_mid)) {
   $slope = $slope_left;  # Use smaller slope
} else {
   $slope = $slope_mid;
}
```

### 2. **Stricter Fritsch-Carlson Constraint**
- **Standard monotone (method 1):** Limits slope to 3× segment slope
- **Ultra-conservative (method 4):** Limits slope to **2× segment slope**

```perl
if($alpha > 2.0) {  # Instead of 3.0
   $slope = 2.0 * sign($slope) * abs($slope_mid);
}
```

### 3. **Additional Damping**
Applies a **0.7× damping factor** to further reduce curvature:
```perl
$slope = $slope * 0.7;  # 30% reduction
```

### 4. **Aggressive Extrema Flattening**
Forces slope to **zero** at any sign change (peaks/valleys):
```perl
if(sign($slope_left) != sign($slope_mid)) {
   return 0;  # Completely flat at transition
}
```

## When to Use

### ✅ Use Ultra-Conservative When:
- **Maximum accuracy required** - GPS tracks, surveying data
- **Severe overshoot problems** - Even monotone method shows artifacts
- **Flat terrain with small bumps** - Need to preserve exact elevations
- **Critical applications** - Navigation, safety-critical systems
- **Sharp elevation changes** - Cliffs, stairs, sudden drops

### ❌ Don't Use When:
- **Smooth, gradual terrain** - Will look too flat/linear
- **Artistic/visual purposes** - May appear too rigid
- **Large-scale features** - Overkill for gentle hills
- **Speed is priority** - Same computation cost, but may need more sections

## Comparison with Other Methods

| Feature | Original (0) | Monotone (1) | Ultra-Conservative (4) |
|---------|-------------|--------------|------------------------|
| **Overshoot** | High | None | Absolutely None |
| **Smoothness** | Very High | High | Moderate |
| **Constraint** | None | 3× limit | 2× limit + damping |
| **Extrema Handling** | None | Harmonic mean | Forced flat |
| **Best For** | Smooth terrain | General use | Critical accuracy |

## Usage Examples

### Basic Usage
```bash
# Run with ultra-conservative method
./4p_improved -m 4 alt_mytrack.txt

# Generate plots
gnuplot __do_plot_all.txt
```

### Compare Methods
```bash
# Compare all methods including ultra-conservative
./compare_methods.pl alt_mytrack.txt
gnuplot compare_all.gnuplot
```

### Adjust Smoothing (if needed)
```bash
# Even more conservative (higher smoothing factor)
./4p_improved -m 4 -s 8.0 alt_mytrack.txt

# Less conservative (lower smoothing factor)
./4p_improved -m 4 -s 2.0 alt_mytrack.txt
```

## Visual Example

### Test Case: Sharp Peak (10m → 30m → 15m)

**Original (Method 0):**
```
35m |     *  ← Overshoots to 35m (+17%)
    |    / \
30m |   B   \
    |  /     \
15m | /       C
10m |A
```

**Monotone (Method 1):**
```
30m |   B---+  ← Perfect, no overshoot
    |  /     \
15m | /       C
10m |A
```

**Ultra-Conservative (Method 4):**
```
30m |   B----+  ← Even flatter at peak
    |  /      \
15m | /        C
10m |A
```

## Technical Details

### Slope Calculation Algorithm

```perl
sub ultra_conservative_slope {
   my ($slope_left, $slope_mid, $slope_right, $is_start) = @_;
   
   # Step 1: Check for extrema (sign change)
   if(sign($slope_left) != sign($slope_mid)) {
      return 0;  # Force flat
   }
   
   # Step 2: Choose minimum absolute slope
   if(abs($slope_left) < abs($slope_mid)) {
      $slope = $slope_left;
   } else {
      $slope = $slope_mid;
   }
   
   # Step 3: Apply 2× constraint (stricter than 3×)
   my $alpha = abs($slope / $slope_mid);
   if($alpha > 2.0) {
      $slope = 2.0 * sign($slope) * abs($slope_mid);
   }
   
   # Step 4: Apply damping (0.7× = 30% reduction)
   $slope = $slope * 0.7;
   
   return $slope;
}
```

### Why These Constraints Work

1. **Minimum slope** → Reduces curvature magnitude
2. **2× limit** → Prevents steep transitions
3. **0.7× damping** → Further flattens curves
4. **Zero at extrema** → Eliminates false peaks/valleys

Combined effect: **Maximum overshoot prevention** while maintaining continuity.

## Trade-offs

### Advantages ✅
- **Zero overshoot** - Guaranteed within input bounds
- **Predictable** - Always conservative
- **Accurate** - Preserves input data fidelity
- **Safe** - No surprises or artifacts

### Disadvantages ❌
- **Less smooth** - More linear appearance
- **May look flat** - Especially on gentle slopes
- **Reduced flow** - Less natural curvature
- **Potential corners** - At sharp transitions

## Recommendations

### For Best Results:
1. **Test first** - Compare with method 1 (monotone)
2. **Check visually** - Ensure it doesn't look too flat
3. **Adjust if needed** - Try lower smoothing factor (-s 2.0)
4. **Use selectively** - Only where overshoot is problematic

### Decision Guide:
```
Is overshoot still visible with method 1?
├─ YES → Try method 4 (ultra-conservative)
│  └─ Still too smooth? → Increase sections in input data
└─ NO → Stick with method 1 (monotone)
   └─ Want more smoothness? → Try method 2 (catmull-rom)
```

## Performance

- **Computation time:** Same as other methods (~O(n))
- **Memory usage:** Identical
- **Output size:** Same CSV/plot file sizes

## Summary

**Method 4 (Ultra-Conservative)** is the **nuclear option** for overshoot prevention:
- Applies **every constraint** available
- Prioritizes **accuracy over smoothness**
- Best for **critical applications** where overshoot is unacceptable

**Command:** `./4p_improved -m 4 input.txt`

**When in doubt:** Start with method 1, upgrade to method 4 only if needed.
