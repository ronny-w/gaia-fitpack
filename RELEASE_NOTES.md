# gaia-fitpack Release Notes

## v1.0.0 — Double Precision Fork

### Why This Fork Exists

The original FITPACK library by Paul Dierckx uses single-precision arithmetic
throughout, providing approximately 7 significant decimal digits. This was
appropriate for the computing environment of the 1980s but creates limitations
for modern use:

- **Ill-conditioned problems** fail silently — spline fitting on large domains,
  tight smoothing parameters, or nearly-collinear data can produce wrong results
  due to catastrophic cancellation in single precision
- **Certification requirements** — IEC 61508, DO-178C, and ISO 26262 require
  numerical analysis of precision; single precision is increasingly difficult to
  certify for safety-critical applications
- **SciPy already uses double precision** — scipy.interpolate passes float64
  arrays to FITPACK via f2py with -fdefault-real-8; this fork makes that
  explicit and auditable

This fork upgrades all 59 routines to double precision, tightens internal
convergence tolerances, documents known behavioral limitations in-source,
and adds a regression test suite and CMake build system.

### What Changed

**Precision upgrade**
- All REAL declarations converted to DOUBLE PRECISION
- Single-precision literals (0.0, 1e-3) converted to D-form (0.0D0, 1.0D-3)
- FPCURO upgraded to use explicit double-precision intrinsics
- Numerical precision: ~7 digits (single) to ~15 digits (double)
- Every changed declaration carries an inline comment

**Convergence tolerances**
- Internal tolerance tol tightened from 1e-3 to 1e-10 in CURFIT, SURFIT, SPHERE
- User-facing eps argument unchanged (backward compatible)
- Effect: better solutions on well-conditioned problems; faster convergence
  failures on genuinely ill-conditioned problems

**Documentation additions**
- Sorted input requirement documented in SPLEV, SPLDER, SPLINT
- Silent extrapolation behavior documented in SPLEV (retained by design)
- Fixed degree limit k<=5 documented in FPBSPL, FPADER, FPINTB, FPPOCU
- Large-frequency accuracy warning in FOURCO / FPCSIN

**Test suite**
- 10 Fortran-90 regression drivers (S001-S010)
- Tests cover: curve fitting, evaluation, derivatives, integration, roots,
  Fourier integrals, parametric curves, surface fitting, spherical splines
- All pass with tolerance 1e-10

**Build system**
- CMakeLists.txt with CTest integration
- Supports gfortran and ifort
- Makefile for test-only builds

### Compatibility

**Backward compatible:**
- All 29 public subroutine signatures unchanged
- All argument counts unchanged
- All IER return values unchanged
- Existing callers work without modification when compiled with matching flags

**Compiler flags for existing callers:**
If your existing F77 code uses REAL declarations and calls this library,
compile with:
```
gfortran -fdefault-real-8 -fdefault-double-8 your_code.f -L. -ldierckx
```
This promotes all REAL to 8-byte double precision consistently.
Workspace array sizes (in element counts) do not need to change.

**Python/SciPy callers:**
Pass float64 (numpy.float64) arrays. The f2py signature file should declare
arguments as double precision. No change needed if already using float64.

**C callers:**
Pass double not float for all floating-point arguments. The ABI changes
from 4-byte to 8-byte floats.

**Pre-built libraries:**
Any existing compiled .a or .so of the original FITPACK must be rebuilt.
The dierckx.a in this repo is double precision.

### Known Limitations (Unchanged from Original)

- SPLEV extrapolates silently when x is outside knot range (IER=0, by design)
- Spline degree limited to k<=5 by fixed local array sizes
- EVAPOL is bicubic-only (hardcoded degree 3)
- FOURCO accuracy degrades for large alpha*(t(n-3)-t(4)) >> 1

### Provenance

FITPACK routines by Paul Dierckx, public domain.
Double precision conversion, test suite, and build system by gaia-fitpack contributors.
