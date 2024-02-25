# 4p (Work in Progress!)
Create GPL track editing altitude trace equation coefficients. Each equation is defned by 4 point sets that make up the previous, current and next sections start and end points. 

Import altitude data one column for each trace.

Input Format:

`   Section Name, Section Length, Trace 1 Altitude, Trace 2 Altitude, ...`

Where `Trace Altitude` is the elevation (Y value) at the start of the section for each trace.

The 4p program also creates stitched gnuplot derived formulas for each trace and section of the track for visualizing equation curves. 


Equations for solving functions. 

$f(x) = Ax^3 + Bx^2 + Cx + D  \textnormal{; Equation for altitude or Y at any X location}$

$f'(x) = 3Ax^2 + 2Bx + C  \textnormal{;  Equation derivitave for slope of altitudes}$

$f(0) = Y_0 = D  \textnormal{;  Altitude at the start of a section}$

$f(L) = Y_L = AL^3 + BL^2 + CL   \textnormal{;  Altitude at the end of a section}$

$f'(0) = S_0 = C   \textnormal{;  Slope at the start of a section}$

$f'(L) = S_L = 3AL^2 + 2BL^2 + S_0   \textnormal{;   Slope at the end of a section}$


Subtract $2f(L) - Lf'(L)$ to get $A$

$A = 1/L^3 [L(S_0 + S_L) + 2(Y_0 - Y_L)]$

Solve for $B$ in $f'(x)'$

$B = 1/L^2 [(-2S_0 - S_L) - 3(Y_0 - Y_L)]$


Convert range from [0:L] to [0:1]

$A_{[0:1]} = L^3 A_{[0:L]}$

$B_{[0:1]} = L^2 B_{[0:L]}$

$C_{[0:1]} = L C_{[0:L]}$

$D_{[0:1]} = D_{[0:L]}$

**
$A = L(S_0 + S_L) + 2(Y_0 - Y_L)$

$B = (-2S_0 - S_L) - 3(Y_0 - Y_L)$

$C = LS_0$

$D - Y_0$
**


