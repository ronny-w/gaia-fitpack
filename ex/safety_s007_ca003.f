cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Gap: CA003 - Code finding: Division by near-zero in 16 internal
cc  Pattern: behavior_observation
cc  Routine: CURFIT(iopt, m, x, y, w, xb, xe, k, s, nest, n, t, c, fp,)
cc  Constraints:
cc    m > k
cc    1 <= k <= 5
cc    s >= 0
cc    nest >= 2*k+2
cc    x values must be strictly ascending
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program test_ca003
      implicit none
      integer iopt,m,k,nest,n,lwrk,ier,i
      parameter (m=20,nest=50,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp
      real xb,xe,s
      integer iwrk(nest)

      write(*,*) 'Gap CA003: Code finding: Division by near-zero in 1'
      write(*,*) '========================================'

      k = 3
      xb = 0.0
      xe = 1.0
      s = 0.1

      do 100 i = 1, m
        x(i) = float(i-1) / float(m-1)
        y(i) = sin(3.14159265 * x(i))
        w(i) = 1.0
  100  continue

      iopt = 0
      ier = 0

      call curfit(iopt, m, x, y, w, xb, xe, k, s, nest,
     *            n, t, c, fp, wrk, lwrk, iwrk, ier)

      write(*,*) 'BEHAVIOR: iopt=0 smoothing spline fit'
      write(*,*) 'IER=', ier
      write(*,*) 'N=', n
      write(*,*) 'FP=', fp
      if (ier .le. 0) then
        write(*,*) 'PASS'
      else
        write(*,*) 'INFO: unexpected ier'
      end if

      s = 0.0
      iopt = 0
      ier = 0

      call curfit(iopt, m, x, y, w, xb, xe, k, s, nest,
     *            n, t, c, fp, wrk, lwrk, iwrk, ier)

      write(*,*) 'BEHAVIOR: s=0 interpolating spline fit'
      write(*,*) 'IER=', ier
      write(*,*) 'N=', n
      write(*,*) 'FP=', fp
      if (ier .le. 0) then
        write(*,*) 'PASS'
      else
        write(*,*) 'INFO: s=0 ier nonzero'
      end if

      s = 1.0e-10
      iopt = 0
      ier = 0

      call curfit(iopt, m, x, y, w, xb, xe, k, s, nest,
     *            n, t, c, fp, wrk, lwrk, iwrk, ier)

      write(*,*) 'BEHAVIOR: near-zero s epsilon guard test'
      write(*,*) 'IER=', ier
      write(*,*) 'N=', n
      write(*,*) 'FP=', fp
      if (ier .le. 0) then
        write(*,*) 'PASS'
      else
        write(*,*) 'INFO: near-zero s ier nonzero'
      end if

      do 200 i = 1, m
        w(i) = 1.0e-10
  200  continue

      write(*,*) 'CA003 test complete'
      end
