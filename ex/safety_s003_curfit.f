cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  safety_s003_curfit : workspace size tests for CURFIT              cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program safety_s003_curfit
      implicit none
      integer i,iopt,m,k,nest,n,lwrk,ier
      real x(10),y(10),w(10),t(30),c(30),wrk(300)
      integer iwrk(30)
      real fp,xb,xe,s,ai

      write(*,*) 'S003: CURFIT workspace size tests'
      write(*,*) '=================================='

      m=10; k=3; nest=30; s=0.01; iopt=0
      xb=0.0; xe=1.0
      do 10 i=1,m
        ai = real(i-1)/real(m-1)
        x(i) = ai
        y(i) = ai*ai
        w(i) = 1.0
   10 continue

c  test 1: lwrk=10 — clearly too small
      n=0; lwrk=10
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test1: lwrk=10 gives IER=10'
      else
        write(*,*) 'INFO test1: lwrk=10 gave IER=',ier
      end if

c  test 2: lwrk=1
      n=0; lwrk=1
      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test2: lwrk=1 gives IER=10'
      else
        write(*,*) 'INFO test2: lwrk=1 gave IER=',ier
      end if

      write(*,*) 'S003 CURFIT complete'
      end
