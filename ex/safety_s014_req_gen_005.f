cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Gap: REQ-GEN-005 - Evaluation Clamping at Domain Boundary
cc  Pattern: behavior_observation
cc  Routine: SPLEV(t, n, c, k, x, y, m, ier)
cc  Constraints:
cc    m >= 1
cc    x must be non-decreasing: x(i) <= x(i+1)
cc    t(k+1) <= x(i) <= t(n-k) for all i (clamped to boundary if outside)
cc    n >= 2*(k+1)
cc    h array is hardcoded to size 6, so k <= 5
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program test_req_gen_005
      implicit none
      integer iopt,m,k,nest,n,lwrk,ier,i
      parameter (m=20,nest=50,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp
      real xb,xe,s
      integer iwrk(nest)

      write(*,*) 'REQ-GEN-005'
      write(*,*) 'REQ coverage test'

      iopt = 0
      k = 3
      s = 0.1
      xb = 0.0
      xe = 1.0

      do 100 i = 1, 20
        x(i) = xb + (xe - xb) * (i - 1) / (20 - 1)
        y(i) = sin(3.14159265 * x(i))
        w(i) = 1.0
  100  continue

      call curfit(iopt, 20, x, y, w, xb, xe, k, s, 20,
     *            n, t, c, fp, wrk, lwrk, iwrk, ier)

      write(*,*) 'CURFIT IER = ', ier
      write(*,*) 'N = ', n

      if (ier .gt. 0) then
        write(*,*) 'SKIP: curfit failed, cannot test splev'
        stop
      end if

      x(1) = xb - 0.5
      x(2) = xb - 0.1
      x(3) = xb
      x(4) = xe
      x(5) = xe + 0.1
      x(6) = xe + 0.5

      call splev(t, n, c, k, x, y, 6, ier)

      write(*,*) 'SPLEV IER = ', ier
      write(*,*) 'BEHAVIOR: splev called with points outside domain'
      write(*,*) 'x(1)=xb-0.5, x(2)=xb-0.1, x(3)=xb (boundary)'
      write(*,*) 'x(4)=xe (boundary), x(5)=xe+0.1, x(6)=xe+0.5'
      write(*,*) 'y(1) = ', y(1)
      write(*,*) 'y(2) = ', y(2)
      write(*,*) 'y(3) = ', y(3)
      write(*,*) 'y(4) = ', y(4)
      write(*,*) 'y(5) = ', y(5)
      write(*,*) 'y(6) = ', y(6)

      if (ier .ne. 0) then
        write(*,*) 'FAIL: IER should be 0 for clamped points, got ',
     *             ier
        stop
      end if

      write(*,*) 'BEHAVIOR: IER=0, no error raised for out-of-range'

      if (abs(y(1) - y(3)) .lt. 1.0e-5) then
        write(*,*) 'BEHAVIOR: y(xb-0.5) == y(xb), clamped correctly'
      else
        write(*,*) 'FAIL: y(xb-0.5) != y(xb), clamping not applied'
        write(*,*) 'y(1)=', y(1), ' y(3)=', y(3)
        stop
      end if

      if (abs(y(2) - y(3)) .lt. 1.0e-5) then
        write(*,*) 'BEHAVIOR: y(xb-0.1) == y(xb), clamped correctly'
      else
        write(*,*) 'FAIL: y(xb-0.1) != y(xb), clamping not applied'
        write(*,*) 'y(2)=', y(2), ' y(3)=', y(3)
        stop
      end if

      if (abs(y(5) - y(4)) .lt. 1.0e-5) then
        write(*,*) 'BEHAVIOR: y(xe+0.1) == y(xe), clamped correctly'
      else
        write(*,*) 'FAIL: y(xe+0.1) != y(xe), clamping not applied'
        write(*,*) 'y(5)=', y(5), ' y(4)=', y(4)
        stop
      end if

      write(*,*) 'PASS'

      write(*,*) 'REQ-GEN-005 test complete'
      end
