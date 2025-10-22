# Quick Test Guide for Harmonic Mean Algorithm

## Quick Comparison Test

Run all three main algorithms and compare:

```bash
# 1. Old algorithm (overshoots)
./4psi -m 0 alt_mytrack.txt > /dev/null 2>&1
mv __gtk_csv.TXT __gtk_csv_OLD.TXT

# 2. Monotone algorithm (no overshoot, less smooth)
./4psi -m 1 alt_mytrack.txt > /dev/null 2>&1
mv __gtk_csv.TXT __gtk_csv_MONOTONE.TXT

# 3. NEW: Harmonic Mean algorithm (smooth + no overshoot)
./4psi -m 4 alt_mytrack.txt > /dev/null 2>&1
mv __gtk_csv.TXT __gtk_csv_Harmonic Mean.TXT

echo "✓ All three algorithms completed"
echo "Compare the output files to see the differences"
```

## Visual Comparison

```bash
# Run comprehensive comparison with all methods
./compare_harmonic mean.pl alt_mytrack.txt
gnuplot compare_harmonic mean.gnuplot

# View the comparison image
# (comparison_harmonic mean.png will show all 5 methods side-by-side)
```

## Test Different Alpha Values

```bash
# Maximum smoothness (may have slight overshoot)
./4psi -m 4 -t 0.5 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_0.5.TXT

# Balanced
./4psi -m 4 -t 0.75 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_0.75.TXT

# Near-harmonic mean (default)
./4psi -m 4 -t 0.85 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_0.85.TXT

# Guaranteed no overshoot
./4psi -m 4 -t 1.0 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_1.0.TXT
```

## Expected Results

### Method 0 (Original)
- **Smoothness**: ⭐⭐⭐⭐⭐ Excellent
- **Overshoot**: ❌ Yes, can be significant
- **Use case**: Only for very gentle terrain

### Method 1 (Monotone)
- **Smoothness**: ⭐⭐⭐ Good but visible kinks
- **Overshoot**: ✅ None (guaranteed)
- **Use case**: When accuracy is critical

### Method 4 (Harmonic Mean)
- **Smoothness**: ⭐⭐⭐⭐⭐ Excellent (C¹ continuity)
- **Overshoot**: ✅ None (with default alpha=0.85)
- **Use case**: **Best choice for most tracks** ⭐

## What to Look For

### In the CSV Files
Compare the coefficients (a, b, c, d) between methods:
- Old: May have large 'a' coefficients (high curvature)
- Monotone: Conservative coefficients, sometimes flat (a≈0, b≈0)
- Harmonic Mean: Balanced coefficients with smooth transitions

### In the Plots
- **Old**: Smooth curves but may exceed input altitudes
- **Monotone**: Stays within bounds but may have visible "corners"
- **Harmonic Mean**: Smooth curves that stay within bounds

## Recommended Workflow

1. **Start with default harmonic mean**:
   ```bash
   ./4psi -m 4 alt_mytrack.txt
   ```

2. **If you see any issues**, adjust alpha:
   ```bash
   # Slightly less smooth, tighter constraint
   ./4psi -m 4 -t 0.9 alt_mytrack.txt
   
   # More smooth, looser constraint
   ./4psi -m 4 -t 0.8 alt_mytrack.txt
   ```

3. **For maximum smoothness**, increase smoothing factor:
   ```bash
   ./4psi -m 4 -s 12.0 -t 0.85 alt_mytrack.txt
   ```

4. **Compare visually**:
   ```bash
   ./compare_harmonic mean.pl alt_mytrack.txt
   gnuplot compare_harmonic mean.gnuplot
   ```

## Success Criteria

The harmonic mean algorithm is working correctly if:

✅ Curves pass through all input altitude points  
✅ No visible overshoot (curves stay within altitude bounds)  
✅ Smooth transitions (no sharp corners or kinks)  
✅ Natural-looking peaks and valleys  
✅ C¹ continuity (continuous slopes)  

## Troubleshooting

### Issue: Curves still have minor overshoot
**Solution**: Increase alpha
```bash
./4psi -m 4 -t 0.95 alt_mytrack.txt
```

### Issue: Curves not smooth enough
**Solution**: Increase smoothing factor
```bash
./4psi -m 4 -s 12.0 alt_mytrack.txt
```

### Issue: Peaks look too flat
**Solution**: Decrease alpha slightly
```bash
./4psi -m 4 -t 0.75 alt_mytrack.txt
```

### Issue: Want to match old algorithm smoothness
**Solution**: Decrease alpha and increase smoothing
```bash
./4psi -m 4 -s 15.0 -t 0.6 alt_mytrack.txt
```
