program test_S001
  ! patch_07 S001: CURFIT curve fitting + SPLEV evaluation.
  ! Fit an interpolating cubic spline (s=0) to sin(x) on [0,2*pi] and
  ! verify SPLEV reproduces the sampled data to 1e-10 absolute.
  implicit none
  integer, parameter :: m=20, k=3, nest=m+k+1
  integer, parameter :: lwrk=m*(k+1)+nest*(7+3*k)
  double precision :: x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
  double precision :: yv(m),xb,xe,s,fp,pi,maxerr,tol
  integer :: iwrk(nest), iopt,n,ier,i
  pi = 4.0d0*datan(1.0d0)
  do i=1,m
     x(i) = (i-1)*(2.0d0*pi)/(m-1)
     y(i) = dsin(x(i))
     w(i) = 1.0d0
  end do
  xb=x(1); xe=x(m); s=0.0d0; iopt=0
  call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S001 FAIL  curfit ier=',ier; stop 1
  end if
  call splev(t,n,c,k,x,yv,m,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S001 FAIL  splev ier=',ier; stop 1
  end if
  maxerr=0.0d0
  do i=1,m
     maxerr=max(maxerr,dabs(yv(i)-y(i)))
  end do
  tol=1.0d-10
  if (maxerr.lt.tol) then
     write(*,'(A,ES12.4)') 'test_S001 PASS  max_abs_err=',maxerr
  else
     write(*,'(A,ES12.4)') 'test_S001 FAIL  max_abs_err=',maxerr; stop 1
  end if
end program test_S001
