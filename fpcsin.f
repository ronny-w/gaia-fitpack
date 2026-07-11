      subroutine fpcsin(a,b,par,sia,coa,sib,cob,ress,resc)
c  ======================================================================
c  WARNING (fork doc, patch_06 — known numerical limitation):
c  for large frequencies alpha, the trigonometric recurrence in fpcsin
c  may lose accuracy due to cancellation. accuracy degrades when
c  alpha*(t(n-3)-t(4)) >> 1. no fix is planned; users should validate
c  results for large alpha.
c  ======================================================================
c  fpcsin calculates the integrals ress=integral((b-x)**3*sin(par*x))
c  and resc=integral((b-x)**3*cos(par*x)) over the interval (a,b),
c  given sia=sin(par*a),coa=cos(par*a),sib=sin(par*b) and cob=cos(par*b)
c  ..
c  ..scalar arguments..
      double precision a,b,par,sia,coa,sib,cob,ress,resc   ! DP: upgraded from REAL
c  ..local scalars..
      integer i,j
      double precision ab,ab4,ai,alfa,beta,b2,b4,eps,fac,f1,f2,one,
     * quart,six,! DP: upgraded from REAL
     * three,two
c  ..function references..
      double precision abs   ! DP: upgraded from REAL
c  ..
      one = 0.1D+01
      two = 0.2D+01
      three = 0.3D+01
      six = 0.6D+01
      quart = 0.25D+0
      eps = 0.1D-09
      ab = b-a
      ab4 = ab**4
      alfa = ab*par
c the way of calculating the integrals ress and resc depends on
c the value of alfa = (b-a)*par.
      if(abs(alfa).le.one) go to 100
c integration by parts.
      beta = one/alfa
      b2 = beta**2
      b4 = six*b2**2
      f1 = three*b2*(one-two*b2)
      f2 = beta*(one-six*b2)
      ress = ab4*(coa*f2+sia*f1+sib*b4)
      resc = ab4*(coa*f1-sia*f2+cob*b4)
      go to 400
c ress and resc are found by evaluating a series expansion.
 100  fac = quart
      f1 = fac
      f2 = 0.D0
      i = 4
      do 200 j=1,5
        i = i+1
        ai = i
        fac = fac*alfa/ai
        f2 = f2+fac
        if(abs(fac).le.eps) go to 300
        i = i+1
        ai = i
        fac = -fac*alfa/ai
        f1 = f1+fac
        if(abs(fac).le.eps) go to 300
 200  continue
 300  ress = ab4*(coa*f2+sia*f1)
      resc = ab4*(coa*f1-sia*f2)
 400  return
      end

