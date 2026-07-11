      subroutine fpgivs(piv,ww,cos,sin)
c  subroutine fpgivs calculates the parameters of a givens
c  transformation .
c  ..
c  ..scalar arguments..
      double precision piv,ww,cos,sin   ! DP: upgraded from REAL
c  ..local scalars..
      double precision dd,one,store   ! DP: upgraded from REAL
c  ..function references..
      double precision abs,sqrt   ! DP: upgraded from REAL
c  ..
      one = 0.1D+01
      store = abs(piv)
      if(store.ge.ww) dd = store*sqrt(one+(ww/piv)**2)
      if(store.lt.ww) dd = ww*sqrt(one+(piv/ww)**2)
      cos = ww/dd
      sin = piv/dd
      ww = dd
      return
      end

