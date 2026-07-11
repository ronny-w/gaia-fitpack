program test_S006
  ! patch_07 S006: FOURCO Fourier coefficients (small alpha).
  ! For s(x)=1 on [0,L]: resc=(1/a)*sin(a*L), ress=(1/a)*(1-cos(a*L)).
  implicit none
  integer, parameter :: m=40, k=3, nest=m+k+1
  integer, parameter :: lwrk=m*(k+1)+nest*(7+3*k)
  double precision :: x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk)
  double precision :: alfa(1),ress(1),resc(1),wrk1(nest),wrk2(nest)
  double precision :: xb,xe,s,fp,L,a,expc,exps,tol,errc,errs
  integer :: iwrk(nest), iopt,n,ier,i
  L=2.0d0
  do i=1,m
     x(i)=(i-1)*L/(m-1); y(i)=1.0d0; w(i)=1.0d0
  end do
  xb=x(1); xe=x(m); s=0.0d0; iopt=0
  call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,n,t,c,fp,wrk,lwrk,iwrk,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S006 FAIL curfit ier=',ier; stop 1
  end if
  a=0.5d0; alfa(1)=a
  call fourco(t,n,c,alfa,1,ress,resc,wrk1,wrk2,ier)
  if (ier.gt.0) then
     write(*,'(A,I0)') 'test_S006 FAIL fourco ier=',ier; stop 1
  end if
  expc=(1.0d0/a)*dsin(a*L)
  exps=(1.0d0/a)*(1.0d0-dcos(a*L))
  errc=dabs(resc(1)-expc); errs=dabs(ress(1)-exps)
  tol=1.0d-7
  if (errc.lt.tol .and. errs.lt.tol) then
     write(*,'(A,ES12.4,A,ES12.4)') 'test_S006 PASS  errc=',errc,' errs=',errs
  else
     write(*,'(A,ES12.4,A,ES12.4)') 'test_S006 FAIL  errc=',errc,' errs=',errs
     stop 1
  end if
end program test_S006
