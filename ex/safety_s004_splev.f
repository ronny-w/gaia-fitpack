cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc  Covers: REQ-GEN-004, REQ-GEN-002
cc  safety_s004_splev : numerical robustness tests for SPLEV          cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      program safety_s004_splev
      implicit none
      integer ier,m,nn,k
      real t(8),c(8),x(5),y(5)

      write(*,*) 'S004: SPLEV numerical robustness tests'
      write(*,*) '======================================='

c  cubic spline on [0,1]: identity spline s(x)=x
      nn=8; k=3
      t(1)=0.; t(2)=0.; t(3)=0.; t(4)=0.
      t(5)=1.; t(6)=1.; t(7)=1.; t(8)=1.
      c(1)=0.; c(2)=0.333; c(3)=0.667; c(4)=1.
      c(5)=0.; c(6)=0.;    c(7)=0.;    c(8)=0.

c  test 1: evaluation at endpoints
      x(1)=0.0; x(2)=0.5; x(3)=1.0; m=3
      call splev(t,nn,c,k,x,y,m,ier)
      write(*,*) 'test1: eval [0,0.5,1], IER=',ier
      write(*,*) '  y(0.0)=',y(1),' y(0.5)=',y(2),' y(1.0)=',y(3)
      if (ier.eq.0) then
        write(*,*) 'PASS test1: evaluation succeeded'
      else
        write(*,*) 'FAIL test1: IER=',ier
      end if

c  test 2: x outside range (should give IER=10)
      x(1)=-0.001; m=1
      call splev(t,nn,c,k,x,y,m,ier)
      if (ier.eq.10) then
        write(*,*) 'PASS test2: x=-0.001 outside range gives IER=10'
      else
        write(*,*) 'INFO test2: x outside range gives IER=',ier,
     *            ' y=',y(1)
      end if

c  test 3: constant spline — c values all equal
      c(1)=5.;c(2)=5.;c(3)=5.;c(4)=5.
      x(1)=0.5; m=1
      call splev(t,nn,c,k,x,y,m,ier)
      if (abs(y(1)-5.0).lt.1.e-4.and.ier.eq.0) then
        write(*,*) 'PASS test3: constant spline y(0.5)=',y(1)
      else
        write(*,*) 'FAIL test3: constant spline gave y=',y(1),
     *            ' IER=',ier
      end if

      write(*,*) 'S004 SPLEV complete'
      end
