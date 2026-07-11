cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Gap: REQ-GEN-003 - Knot Vector Validity
cc  Pattern: behavior_observation
cc  Routine: CURFIT(iopt, m, x, y, w, xb, xe, k, s, nest, n, t, c, fp,)
cc  Constraints:
cc    m > k
cc    1 <= k <= 5
cc    s >= 0
cc    nest >= 2*k+2
cc    x values strictly ascending
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program test_req_gen_003
      implicit none
      integer iopt,m,k,nest,n,lwrk,ier,i
      parameter (m=20,nest=50,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp
      real xb,xe,s
      integer iwrk(nest)

      write(*,*) 'REQ-GEN-003'
      write(*,*) 'REQ coverage test'

      k = 3
      s = 0.1
      xb = 0.0
      xe = 1.0
      iopt = 0

      do 100 i = 1, m
        x(i) = (i-1) * 1.0 / (m-1)
        y(i) = sin(3.14159265 * x(i))
        w(i) = 1.0
  100  continue

      call curfit(iopt, m, x, y, w, xb, xe, k, s, nest,
     *            n, t, c, fp, wrk, lwrk, iwrk, ier)

      write(*,*) 'BEHAVIOR: curfit returned ier=', ier,
     *           ' n=', n, ' fp=', fp

      if (ier .gt. 0 .and. ier .ne. 1) then
        write(*,*) 'INFO: curfit returned error, skipping checks'
        goto 500
      end if

      write(*,*) 'Checking left boundary knots'
      do 200 i = 1, k+1
        if (abs(t(i) - xb) .gt. 1.0e-10) then
          write(*,*) 'FAIL: t(', i, ')=', t(i),
     *               ' not equal to xb=', xb
          goto 500
        end if
  200  continue
      write(*,*) 'PASS'

      write(*,*) 'Checking right boundary knots'
      do 300 i = n-k, n
        if (abs(t(i) - xe) .gt. 1.0e-10) then
          write(*,*) 'FAIL: t(', i, ')=', t(i),
     *               ' not equal to xe=', xe
          goto 500
        end if
  300  continue
      write(*,*) 'PASS'

      write(*,*) 'Checking interior knots strictly increasing'
      if (n-k-1 .ge. k+2) then
        do 400 i = k+1, n-k-1
          if (t(i) .ge. t(i+1)) then
            write(*,*) 'FAIL: interior knots not increasing'
            goto 500
          end if
  400  continue
      end if
      write(*,*) 'PASS'

  500  continue

      write(*,*) 'REQ-GEN-003 test complete'
      end
