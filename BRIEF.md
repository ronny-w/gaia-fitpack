# Project Brief — FITPACK

> Human-authored context for the recommendation tool.
> Edit this file to guide implementation recommendations.
> All sections are optional — leave blank if not applicable.

---

## Existing Usage

| Item | Description |
|---|---|
| Primary consumer | SciPy — wraps FITPACK via f2py in `scipy.interpolate` |
| Downstream reach | ~200+ Python packages depend on scipy's FITPACK bindings |
| Usage pattern | Called from Python data science workflows, often in loops over datasets |
| Current binding | f2py-generated Fortran→Python bridge, not maintained by us |
| Public API surface | 29 user-facing routines, 16 exposed via scipy.interpolate |
| Known usage context | Curve and surface fitting, spline evaluation, used in scientific computing |

---

## Constraints

| Constraint | Description | Priority |
|---|---|---|
| Numerical correctness | Results must match Fortran baseline to within 1e-10 | Must |
| Thread safety | Used in parallel data processing pipelines | Must |
| Python compatibility | Must support Python 3.8+ if Python binding is built | Must |
| NumPy interface | Array input/output must be compatible with NumPy ndarray | Must |
| Platform support | macOS arm64, Linux x86_64, Linux arm64 minimum | Must |
| Backward compatibility | Compatibility shim must be drop-in for existing Fortran callers | Should |
| No external deps | Core library must have no runtime dependencies beyond stdlib | Should |
| 32-bit clean | Compat shim must preserve 32-bit integer behavior for existing callers | Should |
| Double precision | Double precision throughout — no single precision variants needed now | Should |

---

## Preferences

| Preference | Description | Priority |
|---|---|---|
| Language for clean API | Rust preferred — memory safety, zero-cost abstractions, good C/Python FFI | Preferred |
| Python shim | Required — must expose clean API to Python callers | Required |
| Fortran fork first | AI-maintained Fortran fork is the v1.0 release — proves pipeline capability | Preferred |
| Clean API design | Context objects, no workspace arrays, exceptions not IER codes | Preferred |
| Test-driven | Every implementation avenue must pass the full safety + functional test suite | Required |

---

## Non-Goals

| Item | Reason |
|---|---|
| Fortran 90 modernization | Out of scope — clean API in Rust/Python is preferred over F90 |
| CUDA/GPU acceleration | Not needed for current use cases |
| Single precision variants | No known use case — defer to future request |
| Complex number support | Not in original FITPACK — out of scope |
| Arbitrary precision | Out of scope |
| JavaScript/WASM port | Not in roadmap |

---

## Timeline

| Phase | Target | Notes |
|---|---|---|
| Fortran fork (v1.0) | Q3 2026 | Fix CA001/CA003, publish to gaia-fitpack |
| Rust clean API (v2.0) | Q1 2027 | Full REQ compliance, Python bindings via PyO3 |
| Python compat shim | Q2 2027 | Drop-in replacement for scipy.interpolate callers |

---

## Known Issues in Current Code

| ID | Description | Severity |
|---|---|---|
| CA001 | SPLEV extrapolates silently outside knot range — IER=0, no warning | Medium |
| CA003 | Division by near-zero in 16 fp* internal routines — no epsilon guards | Low |

---

## Additional Context

- The original Dierckx FITPACK was written in Fortran 77 circa 1993.
  The numerical algorithms are mathematically proven — the goal is faithful
  reimplementation, not algorithmic improvement.

- SciPy's scipy.interpolate.UnivariateSpline and RectBivariateSpline are the
  primary public API that downstream users know. Any Python port should map
  cleanly to these interfaces.

- The iopt=1 warm-start mode is the most complex feature to port. It requires
  preserving internal state (n, t, wrk, iwrk) between calls. The clean API
  should encapsulate this in a context/result object.

- FOURCO (Fourier coefficients) and COCOSP/CONCON (constrained fitting) are
  not in scipy but are in the original library. Include them in any port —
  they have legitimate use cases in signal processing and constrained regression.

- Performance baseline: 7-16ms per test on macOS arm64 with gfortran -O2.
  This includes process startup overhead. Pure algorithm time is much less.
  A Rust implementation should target < 2x wall time on equivalent inputs.
