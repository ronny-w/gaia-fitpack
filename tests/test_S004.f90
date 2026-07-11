program test_S004
  ! patch_07 S004: SPLINT integration.
  ! Integral of sin(x) over [0,pi] is exactly 2. Fit sin with an
  ! interpolating spline and check SPLINT recovers 2 to high accuracy.
  implicit none
  integer, parameter :: m=80, k=3, nest=m+k+1
  integer, parameter :: lwrk=m*(k+1)+nest*(7+3*k)
  double precision :: x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
  double precision :: iwrk2(nest),xb,xe,s,fp,pi,val,err,tol,splint
  integer :: iwrk(nest), iopt,n,ier,i
  external splint
  pi=4.0d0*datan(1.0d0)
  do i=1,m
     x(i)=(i-1)*pi/(m-1); y(i)=dsin(x(i)); w(i)=1.0d0
  end do
  xb=x(1); xe=x(m); s=0.0d0; iopt=0
  call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S004 FAIL curfit ier=',ier; stop 1
  end if
  val=splint(t,n,c,k,0.0d0,pi,iwrk2)
  err=dabs(val-2.0d0)
  tol=1.0d-7
  if (err.lt.tol) then
     write(*,'(A,ES12.4,A,F14.10)') 'test_S004 PASS  abs_err=',err,'  I=',val
  else
     write(*,'(A,ES12.4)') 'test_S004 FAIL  abs_err=',err; stop 1
  end if
end program test_S004
