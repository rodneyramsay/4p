# Quick Test Guide for Optimal Algorithm

## Quick Comparison Test

Run all three main algorithms and compare:

```bash
# 1. Old algorithm (overshoots)
./4p alt_mytrack.txt > /dev/null 2>&1
mv __gtk_csv.TXT __gtk_csv_OLD.TXT

# 2. Monotone algorithm (no overshoot, less smooth)
./4p_improved -m 1 alt_mytrack.txt > /dev/null 2>&1
mv __gtk_csv.TXT __gtk_csv_MONOTONE.TXT

# 3. NEW: Optimal algorithm (smooth + no overshoot)
./4p_optimal alt_mytrack.txt > /dev/null 2>&1
mv __gtk_csv.TXT __gtk_csv_OPTIMAL.TXT

echo "✓ All three algorithms completed"
echo "Compare the output files to see the differences"
```

## Visual Comparison

```bash
# Run comprehensive comparison with all methods
./compare_optimal.pl alt_mytrack.txt
gnuplot compare_optimal.gnuplot

# View the comparison image
# (comparison_optimal.png will show all 5 methods side-by-side)
```

## Test Different Alpha Values

```bash
# Maximum smoothness (may have slight overshoot)
./4p_optimal -a 0.5 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_0.5.TXT

# Balanced
./4p_optimal -a 0.75 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_0.75.TXT

# Near-optimal (default)
./4p_optimal -a 0.85 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_0.85.TXT

# Guaranteed no overshoot
./4p_optimal -a 1.0 alt_mytrack.txt
mv __gtk_csv.TXT __gtk_csv_alpha_1.0.TXT
```

## Expected Results

### Old Algorithm (4p)
- **Smoothness**: ⭐⭐⭐⭐⭐ Excellent
- **Overshoot**: ❌ Yes, can be significant
- **Use case**: Only for very gentle terrain

### Monotone (4p_improved -m 1)
- **Smoothness**: ⭐⭐⭐ Good but visible kinks
- **Overshoot**: ✅ None (guaranteed)
- **Use case**: When accuracy is critical

### Optimal (4p_optimal)
- **Smoothness**: ⭐⭐⭐⭐⭐ Excellent (C² continuity)
- **Overshoot**: ✅ None (with default alpha=0.85)
- **Use case**: **Best choice for most tracks** ⭐

## What to Look For

### In the CSV Files
Compare the coefficients (a, b, c, d) between methods:
- Old: May have large 'a' coefficients (high curvature)
- Monotone: Conservative coefficients, sometimes flat (a≈0, b≈0)
- Optimal: Balanced coefficients with smooth transitions

### In the Plots
- **Old**: Smooth curves but may exceed input altitudes
- **Monotone**: Stays within bounds but may have visible "corners"
- **Optimal**: Smooth curves that stay within bounds

## Recommended Workflow

1. **Start with default optimal**:
   ```bash
   ./4p_optimal alt_mytrack.txt
   ```

2. **If you see any issues**, adjust alpha:
   ```bash
   # Slightly less smooth, tighter constraint
   ./4p_optimal -a 0.9 alt_mytrack.txt
   
   # More smooth, looser constraint
   ./4p_optimal -a 0.8 alt_mytrack.txt
   ```

3. **For maximum smoothness**, increase smoothing factor:
   ```bash
   ./4p_optimal -s 12.0 -a 0.85 alt_mytrack.txt
   ```

4. **Compare visually**:
   ```bash
   ./compare_optimal.pl alt_mytrack.txt
   gnuplot compare_optimal.gnuplot
   ```

## Success Criteria

The optimal algorithm is working correctly if:

✅ Curves pass through all input altitude points  
✅ No visible overshoot (curves stay within altitude bounds)  
✅ Smooth transitions (no sharp corners or kinks)  
✅ Natural-looking peaks and valleys  
✅ C² continuity (smooth second derivatives)  

## Troubleshooting

### Issue: Curves still have minor overshoot
**Solution**: Increase alpha
```bash
./4p_optimal -a 0.95 alt_mytrack.txt
```

### Issue: Curves not smooth enough
**Solution**: Increase smoothing factor
```bash
./4p_optimal -s 12.0 alt_mytrack.txt
```

### Issue: Peaks look too flat
**Solution**: Decrease alpha slightly
```bash
./4p_optimal -a 0.75 alt_mytrack.txt
```

### Issue: Want to match old algorithm smoothness
**Solution**: Decrease alpha and increase smoothing
```bash
./4p_optimal -s 15.0 -a 0.6 alt_mytrack.txt
```
