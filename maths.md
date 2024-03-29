Equations for solving functions.

Length of section $L$

Height at start of section $Y_0$

Height at end of section $Y_L$

Slope at start of section $S_0$

Slope at end of section $S_L$


$$f(x) = Ax^3 + Bx^2 + Cx + D$$

$$f'(x) = 3Ax^2 + 2Bx + C$$

$$f(0) = Y_0 = D$$

$$f(L) = Y_L = AL^3 + BL^2 + CL + D$$

$$f'(0) = S_0 = C$$

$$f'(L) = S_L = 3AL^2 + 2BL + S_0$$


Subtract $2f(L) - Lf'(L)$ to get $A$

$$A = \frac{L(S_0 + S_L) + 2(Y_0 - Y_L)}{L^3}$$

Solve for $B$ in $f'(x)'$

$$B = \frac{L(-2S_0 - S_L) - 3(Y_0 - Y_L)}{L^2}$$

$$C = S_0$$

$$D = Y_0$$


Convert range from $[0:L]$ to $[0:1]$

$$A_{[0:1]} = L^3A_{[0:L]}$$

$$B_{[0:1]} = L^2B_{[0:L]}$$

$$C_{[0:1]} = LC_{[0:L]}$$

$$D_{[0:1]} = D_{[0:L]}$$



==================================================================

**Altitude Function Parameters**

**$$A = L(S_0 + S_L) + 2(Y_0 - Y_L)$$**

**$$B = L(-2S_0 - S_L) - 3(Y_0 - Y_L)$$**

**$$C = LS_0$$**

**$$D = Y_0$$**
