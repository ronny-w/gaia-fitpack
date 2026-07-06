cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Covers: REQ-GEN-004
cc  Gap: CA001 - Code finding: Silent extrapolation in SPLEV
cc  Pattern: behavior_observation
cc  Routine: SPLEV(t, n, c, k, x, y, m, ier)
cc  Constraints:
cc    m >= 1
cc    x must be non-decreasing: x(i) <= x(i+1)
cc    t(k+1) <= x(i) <= t(n-k) for all i (points outside are clamped)
cc    n >= 2*(k+1)
cc    h array is hardcoded to size 6, so k <= 5
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program test_ca001
      implicit none
      integer iopt,m,k,nest,n,lwrk,ier,i
      parameter (m=20,nest=50,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp
      real xb,xe,s
      integer iwrk(nest)

      write(*,*) 'Gap CA001: Code finding: Silent extrapolation in SP'
      write(*,*) '========================================'

      iopt = 0
      k = 3
      s = 0.1
      xb = 0.0
      xe = 1.0
      do 100 i = 1, m
        x(i) = (i-1) * (xe - xb) / (m-1) + xb
        y(i) = sin(3.14159265 * x(i))
        w(i) = 1.0
  100  continue
      call curfit(iopt, m, x, y, w, xb, xe, k, s, nest, n,
     *            t, c, fp, wrk, lwrk, iwrk, ier)
      write(*,*) 'BEHAVIOR: curfit returned ier=', ier,
     *           ' n=', n
      if (ier .le. 0) then
        write(*,*) 'PASS: curfit succeeded'
      else
        write(*,*) 'INFO: curfit failed, ier=', ier
      end if
      if (ier .le. 0) then
        x(1) = -0.5
        call splev(t, n, c, k, x, y, 1, ier)
        write(*,*) 'BEHAVIOR: splev with x below range, ier=', ier
        write(*,*) 'BEHAVIOR: y value at x=-0.5 is', y(1)
        if (ier .eq. 0) then
          write(*,*) 'PASS: splev silently extrapolated, ier=0'
        else
          write(*,*) 'INFO: splev returned ier=', ier
        end if
        x(1) = 1.5
        call splev(t, n, c, k, x, y, 1, ier)
        write(*,*) 'BEHAVIOR: splev with x above range, ier=', ier
        write(*,*) 'BEHAVIOR: y value at x=1.5 is', y(1)
        if (ier .eq. 0) then
          write(*,*) 'PASS: splev silently extrapolated, ier=0'
        else
          write(*,*) 'INFO: splev returned ier=', ier
        end if
        x(1) = 0.5
        call splev(t, n, c, k, x, y, 1, ier)
        write(*,*) 'BEHAVIOR: splev with x inside range, ier=', ier
        write(*,*) 'BEHAVIOR: y value at x=0.5 is', y(1)
        if (ier .eq. 0) then
          write(*,*) 'PASS: splev inside range succeeded, ier=0'
        else
          write(*,*) 'INFO: splev returned ier=', ier
        end if
      end if

      write(*,*) 'CA001 test complete'
      end
