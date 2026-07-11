program test_S002
  ! patch_07 S002: SPLEV sorted-input requirement (behavioral check).
  ! Verifies (a) sorted x evaluates with ier=0, and (b) a strictly
  ! decreasing x is rejected with ier=10, per the patch_02 contract.
  implicit none
  integer, parameter :: m=20, k=3, nest=m+k+1
  integer, parameter :: lwrk=m*(k+1)+nest*(7+3*k)
  double precision :: x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
  double precision :: xe1(5),ye1(5),xe2(5),ye2(5),xb,xe,s,fp,pi
  integer :: iwrk(nest), iopt,n,ier,i
  logical :: ok
  pi=4.0d0*datan(1.0d0)
  do i=1,m
     x(i)=(i-1)*(2.0d0*pi)/(m-1); y(i)=dsin(x(i)); w(i)=1.0d0
  end do
  xb=x(1); xe=x(m); s=0.0d0; iopt=0
  call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
  ok=.true.
  do i=1,5
     xe1(i)=(i-1)*(2.0d0*pi)/4.0d0
  end do
  call splev(t,n,c,k,xe1,ye1,5,ier)
  if (ier.ne.0) then
     write(*,'(A,I0)') 'test_S002 note sorted-eval ier=',ier; ok=.false.
  end if
  do i=1,5
     xe2(i)=(6-i)*(2.0d0*pi)/6.0d0
  end do
  call splev(t,n,c,k,xe2,ye2,5,ier)
  if (ier.ne.10) then
     write(*,'(A,I0)') 'test_S002 FAIL decreasing-x not rejected ier=',ier
     stop 1
  end if
  if (ok) then
     write(*,'(A)') 'test_S002 PASS  sorted ier=0, decreasing ier=10'
  else
     write(*,'(A)') 'test_S002 FAIL'; stop 1
  end if
end program test_S002
