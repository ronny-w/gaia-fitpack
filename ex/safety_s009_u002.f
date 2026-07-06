cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Covers: REQ-STATE-001, REQ-STATE-002
cc  Gap: U002 - Unknown: Warm-start with modified state
cc  Pattern: warmstart_mutation
cc  Routine: CURFIT(iopt, m, x, y, w, xb, xe, k, s, nest, n, t, c, fp,)
cc  Constraints:
cc    m > k
cc    1 <= k <= 5
cc    s >= 0
cc    nest >= 2*k+2
cc    x values must be strictly ascending
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program test_u002
      implicit none
      integer iopt,m,k,nest,n,lwrk,ier,i
      parameter (m=20,nest=50,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp
      real xb,xe,s
      real fp0,fp1,fp2
      integer n0,ier0,ier1
      integer iwrk(nest)

      write(*,*) 'Gap U002: warm-start mutation behavior'
      write(*,*) '========================================'

c  Setup: generate valid data
      k=3; s=0.1; xb=0.0; xe=1.0; n=0
      do 10 i=1,m
        x(i) = real(i-1)/real(m-1)
        y(i) = sin(6.2831853*x(i))
        w(i) = 1.0
   10 continue

c  Step 1: initial call iopt=0
      iopt=0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,
     *    n,t,c,fp,wrk,lwrk,iwrk,ier)
      n0=n; fp0=fp; ier0=ier
      write(*,*) 'Step1 iopt=0: n=',n0,' fp=',fp0,' IER=',ier0
      if (ier0.gt.0) then
        write(*,*) 'FAIL: initial call failed, cannot test warm-start'
        stop
      end if

      DO 100 I = 1, 20
        X(I) = (I-1) / 19.0
        Y(I) = SIN(3.14159265 * X(I))
        W(I) = 1.0
  100  CONTINUE
      XB = 0.0
      XE = 1.0
      K = 3
      S = 0.1
      IOPT = 0
      CALL CURFIT(IOPT, 20, X, Y, W, XB, XE, K, S, 50, N, T, C,
     *            FP, WRK, 500, IWRK, IER)
      WRITE(*,*) 'STEP1 IER=', IER, ' N=', N, ' FP=', FP
      N0 = N
      FP0 = FP
      IF (IER .GT. 0) THEN
        WRITE(*,*) 'BEHAVIOR: iopt=0 failed, cannot test warmstart'
        WRITE(*,*) 'INFO'
        GOTO 998
      END IF
      WRITE(*,*) 'BEHAVIOR: iopt=0 succeeded, N=', N, ' FP=', FP
      DO 200 I = 1, N0
        WRITE(*,*) 'T(', I, ')=', T(I)
  200  CONTINUE
      T(K+2) = T(K+2) + 0.05
      WRITE(*,*) 'Modified T(K+2) to', T(K+2)
      IOPT = 1
      CALL CURFIT(IOPT, 20, X, Y, W, XB, XE, K, S, 50, N, T, C,
     *            FP, WRK, 500, IWRK, IER)
      WRITE(*,*) 'STEP2 IER=', IER, ' N=', N, ' FP=', FP
      IF (IER .EQ. 10) THEN
        WRITE(*,*) 'BEHAVIOR: iopt=1 after modifying T returned IER=10'
        WRITE(*,*) 'BEHAVIOR: routine rejected modified knot vector'
        WRITE(*,*) 'INFO'
      ELSE IF (IER .LT. 0) THEN
        WRITE(*,*) 'BEHAVIOR: iopt=1 after modifying T returned IER=',
     *             IER
        WRITE(*,*) 'BEHAVIOR: routine accepted modified knots, N=', N
        WRITE(*,*) 'INFO'
      ELSE IF (IER .EQ. 0) THEN
        WRITE(*,*) 'BEHAVIOR: iopt=1 after modifying T succeeded'
        WRITE(*,*) 'BEHAVIOR: FP changed from', FP0, ' to', FP
        WRITE(*,*) 'INFO'
      ELSE
        WRITE(*,*) 'BEHAVIOR: iopt=1 after modifying T gave IER=', IER
        WRITE(*,*) 'INFO'
      END IF
      DO 300 I = 1, N
        WRITE(*,*) 'T_AFTER(', I, ')=', T(I)
  300  CONTINUE
      IOPT = 0
      CALL CURFIT(IOPT, 20, X, Y, W, XB, XE, K, S, 50, N, T, C,
     *            FP, WRK, 500, IWRK, IER)
      WRITE(*,*) 'STEP3 fresh iopt=0 IER=', IER, ' N=', N
  998  CONTINUE

      write(*,*) 'U002 test complete'
      end
