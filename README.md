# 4p (Work in Progress!)
Create GPL track editing altitude trace equation coefficients. Each equation is defned by 4 point sets. 

Import altitude data one column for each trace.

Input Format:

`   Section Length, Track X, Trace 1 Altitude, Trace 2 Altitude, ...`

Where `Trace X` is the track length X value at the beginning of the section and `Trace Altitude` is the elevation (Y value) at the start of the section.

The 4p program creates stitched gnuplot formulas for each trace and section of the track for visualizing equation curves. 


Equations for solving functions. 

$f(x) = Ax^3 + Bx^2 + Cx + D  \textnormal{; Equation for altitude or Y at any X location}$

$f'(x) = 3Ax^2 + 2Bx + C  \textnormal{;  Equation derivitave for slope of altitudes}$

$f(0) = Y_0 = D  \textnormal{;  Altitude at the start of a section}$

$f(L) = Y_L = AL^3 + BL^2 + CL   \textnormal{;  Altitude at the end of a section}$

$f'(0) = S_0 = C   \textnormal{;  Slope at the start of a section}$

$f'(L) = S_L = 3AL^2 + 2BL^2 + S_0   \textnormal{;   Slope at the end of a section}$


Subtract $2f(L) - Lf'(L)$ to get $A$

$A = \frac{L(S_0 + S_L) + 2(Y_0 - Y_L)}{L^3}$

Solve for $B$ in $f'(x)'$

$B = \frac{(-2S_0 - S_L) - 3(Y_0 - Y_L)}{L^2}$
