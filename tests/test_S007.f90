program test_S007
  ! patch_07 S007: PARCUR parametric curve fitting.
  ! Fit a parametric cubic spline to a 2D circle, then evaluate each
  ! coordinate spline at the data parameters and confirm reproduction.
  implicit none
  integer, parameter :: idim=2, m=40, k=3
  integer, parameter :: nest=m+k+1, mx=idim*m, nc=idim*nest
  integer, parameter :: lwrk=(k+1)*m+nest*(6+idim+3*k)
  double precision :: u(m),x(mx),w(m),t(nest),c(nc),wrk(lwrk)
  double precision :: ub,ue,s,fp,pi,th,cx(nest),cy(nest),ev(m)
  double precision :: maxerr,tol
  integer :: iwrk(nest), iopt,ipar,n,ier,i,j,nk1
  pi=4.0d0*datan(1.0d0)
  do i=1,m
     th=(i-1)*(2.0d0*pi)/(m-1)
     x(idim*(i-1)+1)=dcos(th)
     x(idim*(i-1)+2)=dsin(th)
     w(i)=1.0d0
  end do
  iopt=0; ipar=0; s=0.0d0; ub=0.0d0; ue=0.0d0
  call parcur(iopt,ipar,idim,m,u,mx,x,w,ub,ue,k,s,nest,n,t, &
              nc,c,fp,wrk,lwrk,iwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S007 FAIL parcur ier=',ier; stop 1
  end if
  nk1=n-k-1
  do j=1,nk1
     cx(j)=c(j)
     cy(j)=c(n+j)
  end do
  maxerr=0.0d0
  call splev(t,n,cx,k,u,ev,m,ier)
  do i=1,m
     maxerr=max(maxerr,dabs(ev(i)-x(idim*(i-1)+1)))
  end do
  call splev(t,n,cy,k,u,ev,m,ier)
  do i=1,m
     maxerr=max(maxerr,dabs(ev(i)-x(idim*(i-1)+2)))
  end do
  tol=1.0d-9
  if (maxerr.lt.tol) then
     write(*,'(A,ES12.4)') 'test_S007 PASS  max_abs_err=',maxerr
  else
     write(*,'(A,ES12.4)') 'test_S007 FAIL  max_abs_err=',maxerr; stop 1
  end if
end program test_S007
