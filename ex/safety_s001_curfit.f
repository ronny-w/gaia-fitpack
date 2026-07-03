cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  safety_s001_curfit : input validation tests for CURFIT           cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program safety_s001_curfit
      implicit none
      integer i,iopt,m,k,nest,n,lwrk,ier
      real x(10),y(10),w(10),t(20),c(20),wrk(200)
      integer iwrk(20)
      real fp,xb,xe,s

      write(*,*) 'S001: CURFIT input validation tests'
      write(*,*) '===================================='

c  test 1: m=0 (no data points)
      iopt=0; m=0; k=3; nest=20; s=1.0; lwrk=200
      xb=0.0; xe=1.0; n=0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test1: m=0 gives IER=10'
      else
        write(*,*) 'FAIL test1: m=0 gave IER=',ier,' expected 10'
      end if

c  test 2: k=0 (invalid degree)
      m=5; k=0; n=0
      do 10 i=1,m
        x(i) = real(i-1)/real(m-1)
        y(i) = x(i)*x(i)
        w(i) = 1.0
   10 continue
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test2: k=0 gives IER=10'
      else
        write(*,*) 'FAIL test2: k=0 gave IER=',ier,' expected 10'
      end if

c  test 3: k=6 (degree too high, max is 5)
      k=6; n=0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test3: k=6 gives IER=10'
      else
        write(*,*) 'FAIL test3: k=6 gave IER=',ier,' expected 10'
      end if

c  test 4: x not strictly ascending
      k=3; n=0
      x(1)=0.0; x(2)=0.5; x(3)=0.3; x(4)=0.8; x(5)=1.0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test4: unsorted x gives IER=10'
      else
        write(*,*) 'FAIL test4: unsorted x gave IER=',ier,' expected 10'
      end if

c  test 5: negative weight
      n=0
      x(1)=0.0; x(2)=0.25; x(3)=0.5; x(4)=0.75; x(5)=1.0
      w(3) = -1.0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test5: negative weight gives IER=10'
      else
        write(*,*) 'FAIL test5: negative weight gave IER=',ier,
     *            ' expected 10'
      end if

c  test 6: nest too small (need at least 2k+2=8 for k=3)
      w(3)=1.0; nest=4; n=0
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test6: nest<2k+2 gives IER=10'
      else
        write(*,*) 'FAIL test6: nest=4<8 gave IER=',ier,' expected 10'
      end if

      write(*,*) 'S001 CURFIT complete'
      end
