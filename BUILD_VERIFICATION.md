# Build & Test Verification

Generated on a clean Ubuntu 24 container with `gfortran` (GCC 13) and CMake.

## Commands run
    cmake -B build -DCMAKE_Fortran_COMPILER=gfortran
    cmake --build build -j4
    ctest --test-dir build --output-on-failure

## Result
    100% tests passed, 0 tests failed out of 10

## Per-unit status
| Kit | Unit | Files | Compile | Notes |
|-----|------|-------|---------|-------|
| 1 | Global DOUBLE PRECISION upgrade | 48 provided + 11 restored deps | 59/59 OK (`-Wall -O2`) | `fpgrid.f`/`fpheal.f` had no body in the kit and are not referenced; omitted. 2.eq./operator-dot literal ambiguity handled. |
| 2 | SPLEV sorted-input docs | splev, splder, splint | OK | documentation only; S002 confirms ier=10 on decreasing x |
| 3 | FPCURO double precision | fpcuro | OK | dsqrt/dabs/dcos/datan2/dsign; amax1→dmax1; ovfl + algorithm docs |
| 4 | SURFIT convergence tol | surfit(+curfit), fpsurf/fpregr/fpcurf | OK | internal `tol` 1e-3→1e-10; user `eps` arg unchanged (API) |
| 5 | SPHERE convergence tol | sphere, fpgrsp, fpopsp | OK | internal `tol` 1e-3→1e-10; user `eps` arg unchanged (API) |
| 6 | Limitation docs | fpbspl, fpader, fpintb, fppocu, evapol, fpcsin, fourco | OK | k<=5, evapol bicubic, fourco large-alpha warnings |
| 7 | Test harness | tests/test_S001..S010 + Makefile | 10/10 PASS | analytic / self-consistent checks |
| 8 | Build system | CMakeLists.txt, README.md | ctest 10/10 | gfortran + ifort; -O2; CTest integration |

## Deviations from the kits (and why)
- **`fpgrid.f`, `fpheal.f`**: listed for output but the kit embedded no
  source and nothing references them. Inventing spline routines could
  silently corrupt results, so they were omitted rather than fabricated.
- **`surfit`/`sphere` `eps`**: the kits said to set "eps=1.0D-10", but
  `eps` there is a user-supplied dummy argument constrained `0<eps<1`.
  Hardcoding it would break the signature/contract. The genuine
  single-precision convergence tolerance is the internal `tol`, which is
  what was changed. The user `eps` argument is untouched.
- **11 restored dependencies**: `fpbfou, fpadno, fpdeno, fporde, fpsysy,
  fpbacp, fpsphe, bispev, fpbisp, fprpsp` were referenced but never
  supplied; without them fourco/surfit/sphere cannot link. Restored from
  the public-domain Dierckx distribution and upgraded to double precision.
