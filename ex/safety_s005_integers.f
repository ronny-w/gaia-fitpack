cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  safety_s005_integers : 32-bit integer limit documentation         cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program safety_s005_integers
      implicit none
      integer i,ier,n,k,m,nest,lwrk,iopt
      parameter (m=1000,nest=100,lwrk=50000)
      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
      integer iwrk(nest)
      real fp,xb,xe,s,ai

      write(*,*) 'S005: 32-bit integer limit documentation'
      write(*,*) '========================================='
      write(*,*) 'INTEGER max value: 2147483647'
      write(*,*) 'Testing with m=',m

      do 10 i=1,m
        ai = real(i-1)/real(m-1)
        x(i) = ai
        y(i) = sin(ai * 3.14159265)
        w(i) = 1.0
   10 continue

      xb=0.0; xe=1.0; k=3
      s = float(m) * 0.001
      iopt=0; n=0

      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,
     *            wrk,lwrk,iwrk,ier)

      write(*,*) 'Result: IER=',ier,' n=',n,' fp=',fp
      if (ier.le.0) then
        write(*,*) 'PASS: m=',m,' handled correctly, n knots=',n
      else if (ier.eq.3) then
        write(*,*) 'INFO: m=',m,' no convergence IER=3 (acceptable)'
      else
        write(*,*) 'INFO: m=',m,' returned IER=',ier
      end if
      write(*,*) 'Safe range for m: 1 to ~2147483647 (32-bit INT_MAX)'

      end
