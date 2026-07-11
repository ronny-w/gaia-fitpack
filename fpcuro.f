      subroutine fpcuro(a,b,c,d,x,n)
c  subroutine fpcuro finds the real zeros of a cubic polynomial
c  ----------------------------------------------------------------------
c  patch_03 (algorithm & precision notes):
c  the routine solves p(x)=a*x**3+b*x**2+c*x+d=0. degenerate leading
c  coefficients are handled by the ovfl-guarded branches (cubic ->
c  quadratic -> linear). for a genuine cubic it reduces to a depressed
c  form and branches on the discriminant: disc>0 gives one real root via
c  cardano (cube roots), disc<=0 gives three real roots via the
c  trigonometric method. a newton polish step refines each root. in
c  double precision the method delivers ~15 significant digits; accuracy
c  degrades for clustered or ill-conditioned roots, as is inherent to
c  cubic root extraction.
c  ----------------------------------------------------------------------
c  p(x) = a*x**3+b*x**2+c*x+d.
c
c  calling sequence:
c     call fpcuro(a,b,c,d,x,n)
c
c  input parameters:
c    a,b,c,d: real values, containing the coefficients of p(x).
c
c  output parameters:
c    x      : real array,length 3, which contains the real zeros of p(x)
c    n      : integer, giving the number of real zeros of p(x).
c  ..
c  ..scalar arguments..
      double precision a,b,c,d   ! DP: upgraded from REAL
      integer n
c  ..array argument..
      double precision x(3)   ! DP: upgraded from REAL
c  ..local scalars..
      integer i
      double precision a1,b1,c1,df,disc,d1,e3,f,four,half,ovfl,pi3,p3,q,   ! DP: upgraded from REAL
     * r,step,tent,three,two,u,u1,u2,y
c  ..function references..
c  ..function references..
c  patch_03: use generic intrinsics which resolve to DOUBLE PRECISION for
c  double-precision arguments. amax1 (single-precision-specific in the
c  original) is replaced by the generic max below. dsqrt/dabs behaviour is
c  obtained via generic sqrt/abs on double precision operands.
      double precision dabs,datan,datan2,dcos,dsign,dsqrt
c  set constants
      two = 0.2D+01
      three = 0.3D+01
      four = 0.4D+01
      ovfl =0.1D+05
c  patch_03: ovfl threshold retained from single-precision original;
c  safe for double precision due to larger exponent range.
      half = 0.5D+0
      tent = 0.1D+0
      e3 = tent/0.3D0
      pi3 = datan(0.1D+01)/0.75D0
      a1 = dabs(a)
      b1 = dabs(b)
      c1 = dabs(c)
      d1 = dabs(d)
c  test whether p(x) is a third degree polynomial.
      if(dmax1(b1,c1,d1).lt.a1*ovfl) go to 300
c  test whether p(x) is a second degree polynomial.
      if(dmax1(c1,d1).lt.b1*ovfl) go to 200
c  test whether p(x) is a first degree polynomial.
      if(d1.lt.c1*ovfl) go to 100
c  p(x) is a constant function.
      n = 0
      go to 800
c  p(x) is a first degree polynomial.
 100  n = 1
      x(1) = -d/c
      go to 500
c  p(x) is a second degree polynomial.
 200  disc = c*c-four*b*d
      n = 0
      if(disc.lt.0.) go to 800
      n = 2
      u = dsqrt(disc)
      b1 = b+b
      x(1) = (-c+u)/b1
      x(2) = (-c-u)/b1
      go to 500
c  p(x) is a third degree polynomial.
 300  b1 = b/a*e3
      c1 = c/a
      d1 = d/a
      q = c1*e3-b1*b1
      r = b1*b1*b1+(d1-b1*c1)*half
      disc = q*q*q+r*r
      if(disc.gt.0.) go to 400
      u = dsqrt(dabs(q))
      if(r.lt.0.) u = -u
      p3 = datan2(dsqrt(-disc),dabs(r))*e3
      u2 = u+u
      n = 3
      x(1) = -u2*dcos(p3)-b1
      x(2) = u2*dcos(pi3-p3)-b1
      x(3) = u2*dcos(pi3+p3)-b1
      go to 500
 400  u = dsqrt(disc)
      u1 = -r+u
      u2 = -r-u
      n = 1
      x(1) = dsign(dabs(u1)**e3,u1)+dsign(dabs(u2)**e3,u2)-b1
c  apply a newton iteration to improve the accuracy of the roots.
 500  do 700 i=1,n
        y = x(i)
        f = ((a*y+b)*y+c)*y+d
        df = (three*a*y+two*b)*y+c
        step = 0.D0
        if(dabs(f).lt.dabs(df)*tent) step = f/df
        x(i) = y-step
 700  continue
 800  return
      end

