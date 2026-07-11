program test_S003
  ! patch_07 S003: SPLDER derivative evaluation.
  ! Fit sin(x) with a quintic spline (k=5) and compare the spline's
  ! first derivative to the analytic cos(x) at interior points.
  implicit none
  integer, parameter :: m=60, k=5, nest=m+k+1
  integer, parameter :: lwrk=m*(k+1)+nest*(7+3*k)
  double precision :: x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
  double precision :: xe1(40),d1(40),dwrk(nest),xb,xe,s,fp,pi,maxerr,tol,xx
  integer :: iwrk(nest), iopt,n,ier,i,nu
  pi=4.0d0*datan(1.0d0)
  do i=1,m
     x(i)=(i-1)*(2.0d0*pi)/(m-1); y(i)=dsin(x(i)); w(i)=1.0d0
  end do
  xb=x(1); xe=x(m); s=0.0d0; iopt=0
  call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S003 FAIL curfit ier=',ier; stop 1
  end if
  nu=1
  do i=1,40
     xe1(i)=0.3d0+(i-1)*(2.0d0*pi-0.6d0)/39.0d0
  end do
  call splder(t,n,c,k,nu,xe1,d1,40,dwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S003 FAIL splder ier=',ier; stop 1
  end if
  maxerr=0.0d0
  do i=1,40
     xx=xe1(i)
     maxerr=max(maxerr,dabs(d1(i)-dcos(xx)))
  end do
  tol=1.0d-6
  if (maxerr.lt.tol) then
     write(*,'(A,ES12.4)') 'test_S003 PASS  max_abs_err=',maxerr
  else
     write(*,'(A,ES12.4)') 'test_S003 FAIL  max_abs_err=',maxerr; stop 1
  end if
end program test_S003
