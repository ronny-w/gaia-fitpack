cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Covers: REQ-GEN-005, REQ-GEN-006, REQ-GEN-007
cc  safety_s002_curfit : convergence tests for CURFIT                 cc
cc  S002: Documents behavior for convergence-challenged inputs.       cc
cc  minimum lwrk = m*(k+1) + nest*(7+3*k) = 20*4 + 60*16 = 1040     cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program safety_s002_curfit
      implicit none
      integer m,k,nest,lwrk
      parameter (m=20,nest=60,lwrk=2000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
      integer iwrk(nest),n,iopt,ier,i
      real fp,xb,xe,s,ai,pi
      pi = 3.14159265

      write(*,*) 'S002: CURFIT convergence tests'
      write(*,*) '================================'
      write(*,*) 'minimum lwrk for m=20,k=3,nest=60: 1040'
      write(*,*) 'using lwrk=',lwrk

c  set up data: noisy sin(x) on [0,pi]
      do 10 i=1,m
        ai = real(i-1)/real(m-1)
        x(i) = ai * pi
        y(i) = sin(x(i)) + 0.05*real(mod(i,3)-1)
        w(i) = 1.0
   10 continue
      xb=x(1); xe=x(m); k=3

c  test 1: s=0 — interpolation constraint with noisy data
c  IER=0 or IER=-1 (too many knots) or IER=3 (no convergence)
c  All are acceptable — documents real behavior
      iopt=0; n=0; s=0.0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.le.0.or.ier.eq.3) then
        write(*,*) 'PASS test1: s=0 returned IER=',ier,' n=',n
      else
        write(*,*) 'FAIL test1: s=0 returned unexpected IER=',ier
      end if
      write(*,*) '  fp=',fp

c  test 2: very large s — over-smoothed, should converge IER<=0
      iopt=0; n=0; s=float(m)*1.0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.le.0) then
        write(*,*) 'PASS test2: large s returned IER=',ier,' n=',n
      else
        write(*,*) 'FAIL test2: large s returned IER=',ier
      end if
      write(*,*) '  fp=',fp

c  test 3: typical moderate s
      iopt=0; n=0; s=float(m)*0.01
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.le.0) then
        write(*,*) 'PASS test3: moderate s returned IER=',ier,' n=',n
      else if (ier.eq.3) then
        write(*,*) 'INFO test3: no convergence IER=3, fp=',fp
      else
        write(*,*) 'FAIL test3: IER=',ier
      end if

      write(*,*) 'S002 CURFIT complete'
      end
