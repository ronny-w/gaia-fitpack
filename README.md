# fitpack-fork (double precision)

A double-precision fork of the Dierckx **FITPACK** spline library (the
curve-, surface- and spherical-spline routines that underlie
`scipy.interpolate`). This fork converts the original single-precision
FORTRAN 77 sources to `DOUBLE PRECISION`, tightens the internal
convergence tolerances accordingly, documents several long-standing
behavioural limitations in-source, and adds a Fortran-90 regression test
harness plus a CMake build.

All public subroutine signatures, argument counts, and `ier` return codes
are unchanged, so existing callers keep working.

## What changed

### Precision upgrade (patch_01, patch_03)
Every routine was converted from single to double precision: bare `real`
declarations became `double precision`, single-precision literals
(`0.0`, `0.1e+01`, …) became D-form (`0.0D0`, `0.1D+01`, …), and cubic
root extraction in `fpcuro` now uses the explicit double-precision
intrinsics (`dsqrt`, `dabs`, `dcos`, `datan2`, `dsign`) with the
single-precision-specific `amax1` replaced by `dmax1`. Numerical
precision improves from roughly 7 to roughly 15 significant digits.
Every changed declaration carries an inline `! DP:` comment.

### Convergence tolerance (patch_04, patch_05)
The **internal** relative convergence tolerance `tol` (the test
`abs(fp-s)/s <= tol`) was tightened from the single-precision value
`0.1D-02` (1e-3) to `1.0D-10` — approximately `sqrt(DBL_EPSILON)` — in
`curfit`, `surfit`, and `sphere`, from which it propagates into
`fpcurf`, `fpsurf`, `fpregr`, `fpgrsp`, and `fpopsp`.

> **Note on `eps`.** The user-facing `eps` argument of `surfit`/`sphere`
> is a *rank-determination threshold* constrained to `0 < eps < 1`, a
> different quantity from the internal convergence tolerance. It is
> deliberately **left unchanged** to preserve backward compatibility.

### Documentation of known limitations (patch_02, patch_06)
Prominent in-source `WARNING` blocks were added:

- **Sorted input (`splev`, `splder`, `splint`).** `x` must be supplied in
  non-decreasing order; the sequential knot search silently produces
  wrong results otherwise. `splev` returns `ier=10` on a detected strict
  decrease, but no full sort validation is performed (documentation only,
  no behavioural change).
- **Silent extrapolation (`splev`).** `x` outside `[t(k+1), t(n-k)]` is
  clamped/extrapolated with `ier=0`. This is original Dierckx behaviour,
  retained by design.
- **Fixed degree limit `k<=5` (`fpbspl`, `fpader`, `fpintb`, `fppocu`).**
  Local arrays of size 6 hard-limit the spline degree. Supporting higher
  degrees would require generalizing those arrays.
- **Bicubic-only evaluation (`evapol`).** Hardcoded for degree-3
  evaluation via `wrk(8)` / `iwrk(2)`; cannot evaluate other degrees
  without modification.
- **Large-frequency accuracy (`fourco` / `fpcsin`).** For large `alpha`
  the trigonometric recurrence can lose accuracy to cancellation;
  accuracy degrades once `alpha*(t(n-3)-t(4)) >> 1`. No fix is planned —
  validate results for large `alpha`.

### Restored dependencies
Ten helper routines required at link time but absent from the original
patch set were restored from the public-domain Dierckx distribution and
upgraded to double precision to match: `fpbfou`, `fpadno`, `fpdeno`,
`fporde`, `fpsysy`, `fpbacp`, `fpsphe`, `bispev`, `fpbisp`, `fprpsp`.
Without these, `fourco`, `surfit`, and `sphere` could not link.

## Layout

```
.
├── CMakeLists.txt        # library + tests + CTest
├── README.md
├── src/                  # fixed-form FORTRAN 77 sources (double precision)
└── tests/                # Fortran-90 regression drivers + Makefile
    ├── test_S001.f90 ... test_S010.f90
    └── Makefile
```

## Building

### CMake (recommended)

```sh
cmake -B build -DCMAKE_Fortran_COMPILER=gfortran
cmake --build build -j4
ctest --test-dir build --output-on-failure
```

Expected result: `100% tests passed, 0 tests failed out of 10`.
`ifort` is also supported (`-DCMAKE_Fortran_COMPILER=ifort`). Optimization
defaults to `-O2`. The legacy library is compiled with implicit typing (as
the F77 sources require); `-fimplicit-none` / `-Wimplicit-interface`
strictness is applied to the `implicit none` test drivers instead.

### Make (tests only)

```sh
cd tests
make test
```

## Test suite

Each driver checks a routine against an analytic or self-consistent
reference and prints `PASS`/`FAIL` with the maximum absolute error
(numerical tolerance `1e-10` unless a looser bound is noted, reflecting
the conditioning of the specific operation).

| Test | Routine(s)        | Check |
|------|-------------------|-------|
| S001 | CURFIT + SPLEV    | interpolating fit of `sin(x)` reproduces data |
| S002 | SPLEV             | sorted input → `ier=0`; decreasing → `ier=10` |
| S003 | SPLDER            | spline derivative vs analytic `cos(x)` |
| S004 | SPLINT            | ∫₀^π sin = 2 |
| S005 | SPROOT            | spline zeros have small residual |
| S006 | FOURCO            | Fourier integrals vs closed form (small α) |
| S007 | PARCUR            | parametric circle fit reproduces points |
| S008 | SURFIT + BISPEV   | bicubic fit of `x*y` reproduces surface |
| S009 | SPHERE            | spherical spline fit returns valid `ier`/`fp` |
| S010 | FPCURO            | cubic roots (3 real / 1 real / repeated) |

## Provenance & license

The FITPACK routines are by Paul Dierckx and are in the public domain;
the restored helper routines were taken from a public-domain Dierckx
distribution. This fork adds precision conversions, in-source
documentation, tests, and build tooling on top of that public-domain base.
