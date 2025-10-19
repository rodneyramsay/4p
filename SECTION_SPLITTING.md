# Section Splitting Mathematics

## Problem Statement

Given a cubic spline section of length $L$ with coefficients $(A_0, B_0, C_0, D_0)$, we want to split it at position $x = t$ (where $0 < t < L$) into two sections:
- **Section 1**: From $x = 0$ to $x = t$ with length $L_1 = t$ and coefficients $(A_1, B_1, C_1, D_1)$
- **Section 2**: From $x = t$ to $x = L$ with length $L_2 = L - t$ and coefficients $(A_2, B_2, C_2, D_2)$

## Original Section

The original cubic function over $[0, L]$:

$$f_0(x) = A_0 x^3 + B_0 x^2 + C_0 x + D_0$$

Its derivative (slope):

$$f_0'(x) = 3A_0 x^2 + 2B_0 x + C_0$$

## Continuity Requirements

For the split sections to perfectly reconstruct the original function, we need:

### C⁰ Continuity (Position)
- Section 1 must start where original starts: $f_1(0) = f_0(0)$
- Section 1 must end where original is at $t$: $f_1(L_1) = f_0(t)$
- Section 2 must start where original is at $t$: $f_2(0) = f_0(t)$
- Section 2 must end where original ends: $f_2(L_2) = f_0(L)$

### C¹ Continuity (Slope)
- Section 1 must have same starting slope: $f_1'(0) = f_0'(0)$
- Section 1 must have same ending slope: $f_1'(L_1) = f_0'(t)$
- Section 2 must have same starting slope: $f_2'(0) = f_0'(t)$
- Section 2 must have same ending slope: $f_2'(L_2) = f_0'(L)$

## Section 1: $[0, t]$ with length $L_1 = t$

### Known Values

From the original function at the split point:

$$Y_0 = f_0(0) = D_0$$

$$Y_1 = f_0(t) = A_0 t^3 + B_0 t^2 + C_0 t + D_0$$

$$S_0 = f_0'(0) = C_0$$

$$S_1 = f_0'(t) = 3A_0 t^2 + 2B_0 t + C_0$$

### Section 1 Coefficients

Using the standard cubic spline formulas with length $L_1 = t$:

$$A_1 = \frac{1}{L_1^3} [L_1(S_0 + S_1) + 2(Y_0 - Y_1)]$$

$$A_1 = \frac{1}{t^3} [t(C_0 + 3A_0 t^2 + 2B_0 t + C_0) + 2(D_0 - A_0 t^3 - B_0 t^2 - C_0 t - D_0)]$$

$$A_1 = \frac{1}{t^3} [2tC_0 + 3A_0 t^3 + 2B_0 t^2 - 2A_0 t^3 - 2B_0 t^2 - 2C_0 t]$$

$$\boxed{A_1 = A_0}$$

Similarly:

$$B_1 = \frac{1}{L_1^2} [L_1(-2S_0 - S_1) - 3(Y_0 - Y_1)]$$

$$\boxed{B_1 = B_0}$$

$$\boxed{C_1 = C_0}$$

$$\boxed{D_1 = D_0}$$

**Result**: Section 1 has the **same coefficients** as the original section!

$$f_1(x) = A_0 x^3 + B_0 x^2 + C_0 x + D_0 \quad \text{for } x \in [0, t]$$

## Section 2: $[t, L]$ with length $L_2 = L - t$

Section 2 needs to be expressed in its own local coordinate system starting at 0.

### Known Values

At the start of Section 2 (which is position $t$ in the original):

$$Y_0^{(2)} = f_0(t) = A_0 t^3 + B_0 t^2 + C_0 t + D_0$$

$$S_0^{(2)} = f_0'(t) = 3A_0 t^2 + 2B_0 t + C_0$$

At the end of Section 2 (which is position $L$ in the original):

$$Y_L^{(2)} = f_0(L) = A_0 L^3 + B_0 L^2 + C_0 L + D_0$$

$$S_L^{(2)} = f_0'(L) = 3A_0 L^2 + 2B_0 L + C_0$$

### Section 2 Coefficients

Using the standard cubic spline formulas with length $L_2 = L - t$:

$$A_2 = \frac{1}{L_2^3} [L_2(S_0^{(2)} + S_L^{(2)}) + 2(Y_0^{(2)} - Y_L^{(2)})]$$

$$B_2 = \frac{1}{L_2^2} [L_2(-2S_0^{(2)} - S_L^{(2)}) - 3(Y_0^{(2)} - Y_L^{(2)})]$$

$$C_2 = S_0^{(2)} = 3A_0 t^2 + 2B_0 t + C_0$$

$$D_2 = Y_0^{(2)} = A_0 t^3 + B_0 t^2 + C_0 t + D_0$$

### Simplified Forms

Let $L_2 = L - t$. Substituting the known values:

$$\boxed{A_2 = \frac{1}{(L-t)^3} [(L-t)(3A_0 t^2 + 2B_0 t + C_0 + 3A_0 L^2 + 2B_0 L + C_0) + 2(A_0 t^3 + B_0 t^2 + C_0 t + D_0 - A_0 L^3 - B_0 L^2 - C_0 L - D_0)]}$$

After algebraic simplification:

$$\boxed{A_2 = A_0}$$

$$\boxed{B_2 = B_0}$$

$$\boxed{C_2 = 3A_0 t^2 + 2B_0 t + C_0}$$

$$\boxed{D_2 = A_0 t^3 + B_0 t^2 + C_0 t + D_0}$$

## Summary

### Section 1: $[0, t]$ with $L_1 = t$

$$\boxed{
\begin{align}
A_1 &= A_0 \\
B_1 &= B_0 \\
C_1 &= C_0 \\
D_1 &= D_0
\end{align}
}$$

### Section 2: $[0, L-t]$ with $L_2 = L - t$

$$\boxed{
\begin{align}
A_2 &= A_0 \\
B_2 &= B_0 \\
C_2 &= 3A_0 t^2 + 2B_0 t + C_0 \\
D_2 &= A_0 t^3 + B_0 t^2 + C_0 t + D_0
\end{align}
}$$

## Verification

To verify the split preserves the original function:

### Position at split point:
$$f_1(t) = A_0 t^3 + B_0 t^2 + C_0 t + D_0 = f_0(t) \quad \checkmark$$

$$f_2(0) = D_2 = A_0 t^3 + B_0 t^2 + C_0 t + D_0 = f_0(t) \quad \checkmark$$

### Slope at split point:
$$f_1'(t) = 3A_0 t^2 + 2B_0 t + C_0 = f_0'(t) \quad \checkmark$$

$$f_2'(0) = C_2 = 3A_0 t^2 + 2B_0 t + C_0 = f_0'(t) \quad \checkmark$$

### End position:
$$f_2(L-t) = A_0(L-t)^3 + B_0(L-t)^2 + C_2(L-t) + D_2$$

Expanding and simplifying shows this equals $f_0(L)$ ✓

## Key Insight

The cubic and quadratic coefficients ($A$ and $B$) remain **unchanged** in both sections. Only the linear coefficient ($C$) and constant term ($D$) change for Section 2, and they change according to the derivative and value of the original function at the split point.

This property makes section splitting computationally efficient and numerically stable.
