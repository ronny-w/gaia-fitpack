      subroutine fpbspl(t,n,k,x,l,h)
c  ======================================================================
c  WARNING (fork doc, patch_06 — known limitation):
c  local arrays of size 6 impose a hard limit k<=5 (spline degree).
c  to support higher degrees, these fixed-size arrays must be generalized.
c  ======================================================================
c  subroutine fpbspl evaluates the (k+1) non-zero b-splines of
c  degree k at t(l) <= x < t(l+1) using the stable recurrence
c  relation of de boor and cox.
c  ..
c  ..scalar arguments..
      double precision x   ! DP: upgraded from REAL
      integer n,k,l
c  ..array arguments..
      double precision t(n),h(6)   ! DP: upgraded from REAL
c  ..local scalars..
      double precision f,one   ! DP: upgraded from REAL
      integer i,j,li,lj
c  ..local arrays..
      double precision hh(5)   ! DP: upgraded from REAL
c  ..
      one = 0.1D+01
      h(1) = one
      do 20 j=1,k
        do 10 i=1,j
          hh(i) = h(i)
  10    continue
        h(1) = 0.D0
        do 20 i=1,j
          li = l+i
          lj = li-j
          f = hh(i)/(t(li)-t(lj))
          h(i) = h(i)+f*(t(li)-x)
          h(i+1) = f*(x-t(lj))
  20  continue
      return
      end

