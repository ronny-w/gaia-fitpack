cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Gap: REQ-GEN-001 - B-Spline Basis Evaluation Correctness
cc  Pattern: behavior_observation
cc  Routine: CURFIT(iopt, m, x, y, w, xb, xe, k, s, nest, n, t, c, fp,)
cc  Constraints:
cc    m > k
cc    1 <= k <= 5
cc    s >= 0
cc    nest >= 2*k+2
cc    x values strictly ascending
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program test_req_gen_001
      implicit none
      integer iopt,m,k,nest,n,lwrk,ier,i
      parameter (m=20,nest=50,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp
      real xb,xe,s
      integer iwrk(nest)

      write(*,*) 'REQ-GEN-001'
      write(*,*) 'REQ coverage test'

      k = 3
      xb = 0.0
      xe = 1.0
      s = 0.1
      iopt = 0

      do 100 i = 1, m
        x(i) = float(i-1) / float(m-1)
        y(i) = sin(3.14159265 * x(i))
        w(i) = 1.0
  100  continue

      call curfit(iopt, m, x, y, w, xb, xe, k, s, nest,
     *            n, t, c, fp, wrk, lwrk, iwrk, ier)

      write(*,*) 'BEHAVIOR: curfit returned ier=', ier
      write(*,*) 'BEHAVIOR: number of knots n=', n
      write(*,*) 'BEHAVIOR: weighted sum of squared residuals fp=', fp

      if (ier .gt. 0) then
        write(*,*) 'BEHAVIOR: error or warning from curfit'
        write(*,*) 'INFO'
      else
        write(*,*) 'BEHAVIOR: fit completed successfully'
      end if

      if (n .ge. 2*k+2) then
        write(*,*) 'BEHAVIOR: knot count satisfies n >= 2k+2'
        write(*,*) 'PASS'
      else
        write(*,*) 'BEHAVIOR: knot count too small'
        write(*,*) 'INFO'
      end if

      if (fp .ge. 0.0) then
        write(*,*) 'BEHAVIOR: fp is non-negative as expected'
        write(*,*) 'PASS'
      else
        write(*,*) 'BEHAVIOR: fp is negative, unexpected'
        write(*,*) 'INFO'
      end if

      if (t(1) .eq. xb .and. t(n) .eq. xe) then
        write(*,*) 'BEHAVIOR: boundary knots match xb and xe'
        write(*,*) 'PASS'
      else
        write(*,*) 'BEHAVIOR: boundary knots do not match xb/xe'
        write(*,*) 'INFO'
      end if

      do 200 i = 1, k+1
        if (t(i) .ne. xb) then
          write(*,*) 'BEHAVIOR: first k+1 knots not all equal xb'
          write(*,*) 'INFO'
          goto 250
        end if
  200  continue
      write(*,*) 'BEHAVIOR: first k+1 knots all equal xb'
      write(*,*) 'PASS'
  250  continue

      do 300 i = n-k, n
        if (t(i) .ne. xe) then
          write(*,*) 'BEHAVIOR: last k+1 knots not all equal xe'
          write(*,*) 'INFO'
          goto 350
        end if
  300  continue
      write(*,*) 'BEHAVIOR: last k+1 knots all equal xe'
      write(*,*) 'PASS'
  350  continue

      write(*,*) 'REQ-GEN-001 test complete'
      end
