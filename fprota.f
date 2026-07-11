      subroutine fprota(cos,sin,a,b)
c  subroutine fprota applies a givens rotation to a and b.
c  ..
c  ..scalar arguments..
      double precision cos,sin,a,b   ! DP: upgraded from REAL
c ..local scalars..
      double precision stor1,stor2   ! DP: upgraded from REAL
c  ..
      stor1 = a
      stor2 = b
      b = cos*stor2+sin*stor1
      a = cos*stor1-sin*stor2
      return
      end

