program test_S008
  ! patch_07 S008: SURFIT bivariate surface fitting.
  ! Fit z = x*y over a scattered grid on [0,1]^2 with a bicubic spline
  ! (a bicubic reproduces a bilinear function). Evaluate the fitted
  ! surface at the data grid (BISPEV) and check <1e-6.
  implicit none
  integer, parameter :: kx=3, ky=3
  integer, parameter :: ng=9, m=ng*ng
  integer, parameter :: nxest=2*kx+2+ng, nyest=2*ky+2+ng, nmax=nxest+nyest
  integer, parameter :: u=nxest-kx-1, v=nyest-ky-1
  integer, parameter :: km=max(kx,ky)+1, ne=max(nxest,nyest)
  integer, parameter :: bx=kx*v+ky+1, by=ky*u+kx+1
  integer, parameter :: b1=min(bx,by)
  integer, parameter :: b2=merge(b1+v-ky, b1+u-kx, bx.le.by)
  integer, parameter :: lwrk1=u*v*(2+b1+b2)+2*(u+v+km*(m+ne)+ne-kx-ky)+b2+1
  integer, parameter :: lwrk2=u*v*(b2+1)+b2
  integer, parameter :: kwrk=m+(nxest-2*kx-1)*(nyest-2*ky-1)
  integer, parameter :: nc=(nxest-kx-1)*(nyest-ky-1)
  double precision :: x(m),y(m),z(m),w(m)
  double precision :: tx(nmax),ty(nmax),c(nc)
  double precision :: wrk1(lwrk1),wrk2(lwrk2)
  double precision :: xb,xe,yb,ye,s,eps,fp
  double precision :: xe1(ng),ye1(ng),zev(ng,ng),wev(lwrk1),maxerr,tol
  integer :: iwrk(kwrk), iwev(kwrk)
  integer :: iopt,nx,ny,ier,i,j,idx
  idx=0
  do i=1,ng
     do j=1,ng
        idx=idx+1
        x(idx)=(i-1)/dble(ng-1)
        y(idx)=(j-1)/dble(ng-1)
        z(idx)=x(idx)*y(idx)
        w(idx)=1.0d0
     end do
  end do
  xb=0.0d0; xe=1.0d0; yb=0.0d0; ye=1.0d0
  iopt=0; s=1.0d-12; eps=1.0d-8
  call surfit(iopt,m,x,y,z,w,xb,xe,yb,ye,kx,ky,s,nxest,nyest, &
       nmax,eps,nx,tx,ny,ty,c,fp,wrk1,lwrk1,wrk2,lwrk2,iwrk,kwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S008 FAIL surfit ier=',ier; stop 1
  end if
  do i=1,ng
     xe1(i)=(i-1)/dble(ng-1)
     ye1(i)=(i-1)/dble(ng-1)
  end do
  call bispev(tx,nx,ty,ny,c,kx,ky,xe1,ng,ye1,ng,zev, &
              wev,lwrk1,iwev,kwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S008 FAIL bispev ier=',ier; stop 1
  end if
  maxerr=0.0d0
  do i=1,ng
     do j=1,ng
        maxerr=max(maxerr,dabs(zev(i,j)-xe1(i)*ye1(j)))
     end do
  end do
  tol=1.0d-6
  if (maxerr.lt.tol) then
     write(*,'(A,ES12.4)') 'test_S008 PASS  max_abs_err=',maxerr
  else
     write(*,'(A,ES12.4)') 'test_S008 FAIL  max_abs_err=',maxerr; stop 1
  end if
end program test_S008
