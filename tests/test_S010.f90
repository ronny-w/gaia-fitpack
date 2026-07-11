program test_S010
  ! patch_07 S010: FPCURO cubic root finding.
  ! fpcuro solves a*x^3+b*x^2+c*x+d=0. Three configurations:
  !  (1) three distinct real roots (x-1)(x-2)(x-3)
  !  (2) one real root             x^3 - x^2 + x - 1
  !  (3) a repeated root           (x-2)^2 (x-5)
  ! Each returned root must satisfy |p(root)| < 1e-8 (residual).
  implicit none
  double precision :: xr(3),res,maxres,tol
  integer :: n,i,fails
  fails=0; tol=1.0d-8
  call fpcuro(1.0d0,-6.0d0,11.0d0,-6.0d0,xr,n)
  maxres=0.0d0
  do i=1,n
     res=xr(i)**3-6.0d0*xr(i)**2+11.0d0*xr(i)-6.0d0
     maxres=max(maxres,dabs(res))
  end do
  if (n.ne.3 .or. maxres.ge.tol) then
     write(*,'(A,I0,A,ES12.4)') 'test_S010 case1 FAIL n=',n,' maxres=',maxres
     fails=fails+1
  end if
  call fpcuro(1.0d0,-1.0d0,1.0d0,-1.0d0,xr,n)
  maxres=0.0d0
  do i=1,n
     res=xr(i)**3-xr(i)**2+xr(i)-1.0d0
     maxres=max(maxres,dabs(res))
  end do
  if (n.lt.1 .or. maxres.ge.tol) then
     write(*,'(A,I0,A,ES12.4)') 'test_S010 case2 FAIL n=',n,' maxres=',maxres
     fails=fails+1
  end if
  call fpcuro(1.0d0,-9.0d0,24.0d0,-20.0d0,xr,n)
  maxres=0.0d0
  do i=1,n
     res=xr(i)**3-9.0d0*xr(i)**2+24.0d0*xr(i)-20.0d0
     maxres=max(maxres,dabs(res))
  end do
  if (n.lt.1 .or. maxres.ge.tol) then
     write(*,'(A,I0,A,ES12.4)') 'test_S010 case3 FAIL n=',n,' maxres=',maxres
     fails=fails+1
  end if
  if (fails.eq.0) then
     write(*,'(A)') 'test_S010 PASS  all cubic root cases residual < 1e-8'
  else
     write(*,'(A,I0)') 'test_S010 FAIL  cases_failed=',fails; stop 1
  end if
end program test_S010
