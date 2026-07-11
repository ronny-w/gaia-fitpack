program test_S005
  ! patch_07 S005: SPROOT root finding.
  ! sin(x) has zeros at 0, pi, 2*pi. Fit a cubic spline and verify
  ! SPROOT locates interior zeros; check each root residual |s(root)|.
  implicit none
  integer, parameter :: m=60, k=3, nest=m+k+1, mest=20
  integer, parameter :: lwrk=m*(k+1)+nest*(7+3*k)
  double precision :: x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
  double precision :: zero(mest),sv(mest),xb,xe,s,fp,pi,maxres,tol
  integer :: iwrk(nest), iopt,n,ier,i,nz
  pi=4.0d0*datan(1.0d0)
  do i=1,m
     x(i)=(i-1)*(2.0d0*pi)/(m-1); y(i)=dsin(x(i)); w(i)=1.0d0
  end do
  xb=x(1); xe=x(m); s=0.0d0; iopt=0
  call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S005 FAIL curfit ier=',ier; stop 1
  end if
  call sproot(t,n,c,zero,mest,nz,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S005 FAIL sproot ier=',ier; stop 1
  end if
  if (nz.lt.1) then
     write(*,'(A)') 'test_S005 FAIL no roots found'; stop 1
  end if
  call splev(t,n,c,k,zero,sv,nz,ier)
  maxres=0.0d0
  do i=1,nz
     maxres=max(maxres,dabs(sv(i)))
  end do
  tol=1.0d-9
  if (maxres.lt.tol) then
     write(*,'(A,I0,A,ES12.4)') 'test_S005 PASS  nroots=',nz,'  max|s(root)|=',maxres
  else
     write(*,'(A,ES12.4)') 'test_S005 FAIL  max|s(root)|=',maxres; stop 1
  end if
end program test_S005
