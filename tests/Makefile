# patch_07: FITPACK fork regression test harness
# Builds the fitpack static library from ../src and each test driver,
# then runs all tests. Usage:  make test
FC      ?= gfortran
FFLAGS  ?= -O2 -Wall
F90FLAGS ?= -O2 -ffree-line-length-none
SRCDIR  = ../src
LIB     = ../libfitpack.a

TESTS = test_S001 test_S002 test_S003 test_S004 test_S005 \
        test_S006 test_S007 test_S008 test_S009 test_S010

.PHONY: all test clean lib

all: test

# Build the library from all fixed-form sources.
lib:
	$(FC) $(FFLAGS) -c $(SRCDIR)/*.f
	ar rcs $(LIB) *.o
	rm -f *.o

$(LIB): lib

%: %.f90 $(LIB)
	$(FC) $(F90FLAGS) $< $(LIB) -o $@

test: $(LIB) $(TESTS)
	@echo "======================================================"
	@echo " FITPACK fork regression suite"
	@echo "======================================================"
	@fail=0; \
	for t in $(TESTS); do \
	  if ./$$t; then :; else fail=1; fi; \
	done; \
	echo "======================================================"; \
	if [ $$fail -eq 0 ]; then \
	  echo " ALL TESTS PASSED"; \
	else \
	  echo " SOME TESTS FAILED"; exit 1; \
	fi

clean:
	rm -f $(TESTS) *.o $(LIB)
