# 4p (Work in Progress!)
Create GPL track editing altitude trace equation coefficients. Each equation is defned by 4 point sets. 

Import altitude data one column for each trace.

Input Format:

   Section Length, Track X, Trace 1 Altitude, Trace 2 Altitude, ...

Creates stitched gnuplot formulas for each trace and section of the track for visualizing equation curves. 


Equations for solving functions. 

$$f(x) = Ax^3 + Bx^2 + Cx + D$$

$$f'(x) = 3Ax^2 + 2Bx + C$$

$$f(0) = Y_0 = D$$

$$f(L) = Y_L = AL^3 + BL^2 + CL$$

$$f'(0) = S_0 = C$$

$$f'(L) = S_L = 3AL^2 + 2BL^2 + S_0$$


Subtract $2f(L) - Lf'(L)$ to get $A$

$$A = \frac{L(S_0 + S_L) + 2(Y_0 - Y_L)}{L^3}$$

Solve for $B$ in $f'(x)'$

$$B = \frac{(-2S_0 - S_L) - 3(Y_0 - Y_L)}{L^2}$$
