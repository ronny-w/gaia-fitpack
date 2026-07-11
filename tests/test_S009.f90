program test_S009
  ! patch_07 S009: SPHERE spherical spline fitting.
  ! Fit r=f(teta,phi) over the sphere with a smoothing spherical spline
  ! and confirm SPHERE returns ier<=0 with a finite, non-negative fp.
  ! Exercises the fpsphe/fpbacp/fprpsp dependency chain.
  implicit none
  integer, parameter :: nt=15, npnt=15, m=nt*npnt
  integer, parameter :: ntest=13, npest=13
  integer, parameter :: uu=ntest-7, vv=npest-7
  integer, parameter :: lwrk1=185+52*vv+10*uu+14*uu*vv+8*(uu-1)*vv*vv+8*m
  integer, parameter :: lwrk2=48+21*vv+7*uu*vv+4*(uu-1)*vv*vv
  integer, parameter :: kwrk=m+(ntest-7)*(npest-7)
  integer, parameter :: nc=(ntest-4)*(npest-4)
  double precision :: teta(m),phi(m),r(m),w(m)
  double precision :: tt(ntest),tp(npest),c(nc)
  double precision :: wrk1(lwrk1),wrk2(lwrk2)
  double precision :: s,eps,fp,pi
  integer :: iwrk(kwrk), iopt,ntk,npk,ier,i,j,idx
  pi=4.0d0*datan(1.0d0)
  idx=0
  do i=1,nt
     do j=1,npnt
        idx=idx+1
        teta(idx)=(i)*pi/(nt+1)
        phi(idx)=(j-1)*(2.0d0*pi)/npnt
        r(idx)=2.0d0+dcos(teta(idx))
        w(idx)=1.0d0
     end do
  end do
  iopt=0
  s=dble(m)*1.0d-4
  eps=1.0d-8
  call sphere(iopt,m,teta,phi,r,w,s,ntest,npest,eps, &
       ntk,tt,npk,tp,c,fp,wrk1,lwrk1,wrk2,lwrk2,iwrk,kwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S009 FAIL sphere ier=',ier; stop 1
  end if
  if (fp.lt.0.0d0) then
     write(*,'(A,ES12.4)') 'test_S009 FAIL negative fp=',fp; stop 1
  end if
  write(*,'(A,I0,A,ES12.4)') 'test_S009 PASS  ier=',ier,'  fp=',fp
end program test_S009
