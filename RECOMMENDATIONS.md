# fitpack-v1 — Implementation Recommendations

## Executive Summary
fitpack-v1 is a Fortran 77 spline fitting library (82 routines, 35 user-facing) that underpins SciPy's scipy.interpolate module and reaches 200+ downstream Python packages. The recommended path is a two-phase delivery: first an AI-maintained Fortran fork (v1.0, Q3 2026) that fixes confirmed safety issues CA001/CA003 and establishes a validated test baseline, followed by a clean Rust reimplementation with PyO3 Python bindings (v2.0, Q1 2027) that delivers thread safety, a context-object API, and drop-in SciPy compatibility.

## Current State Assessment

**Quality:** POOR — 0 of 35 entry points covered by validation suite; 45 open issues; two confirmed code defects (CA001 silent extrapolation in SPLEV, CA003 division by near-zero in 16 fp* routines); two unknowns (U001 thread safety, U002 warm-start behavior) unresolved. Fortran 77 codebase with no modular structure.

**Test Coverage:** Validation status FAIL — 0/35 entry points covered. A safety test S004 exists that confirms CA001. No functional regression suite, no thread-safety harness, no warm-start behavioral baseline documented.

**Performance:** Fortran 77 compiled with gfortran -O2 runs 29 tests in 5.0–10.1ms per test. No parallel or Python-binding performance baseline exists.


**Known Issues:**
- CA001: SPLEV silently extrapolates when x is outside knot range, returns IER=0 — confirmed by S004
- CA003: 16 internal fp* routines have no guards against division by near-zero values
- U001: Thread safety of CURFIT under concurrent calls with separate workspaces is unverified
- U002: Warm-start behavior (iopt=1 after modifying t[]) is undocumented and unspecified

## Implementation Avenues

### A1: Fortran Fork (v1.0)

**Description:** Create an AI-maintained fork of the existing Fortran 77 codebase. Fix CA001 by adding IER=-1 extrapolation signaling in SPLEV. Fix CA003 by inserting epsilon guards (using a fitpack_init() library epsilon constant) in all 16 affected fp* routines. Write threading test for U001 (4-thread CURFIT with separate workspaces). Document U002 warm-start behavior as a spec baseline. Achieve 35/35 entry-point coverage in the validation suite. Publish as gaia-fitpack v1.0.

**Target users:** Existing Fortran callers, SciPy f2py bridge maintainers, downstream packages that depend on current ABI behavior. Establishes the behavioral baseline for all subsequent avenues.

**Effort:** 6 weeks  |  **Risk:** LOW

**Pros:**
- Minimal risk to numerical correctness — same algorithm, same data layout, same calling conventions
- Fastest path to a shippable, validated release (Q3 2026 target)
- Fixes two confirmed safety defects (CA001, CA003) without architectural change
- Produces the authoritative behavioral baseline (including U001/U002) that Rust reimplementation must match
- Proves AI-assisted maintenance pipeline before higher-stakes Rust work begins

**Cons:**
- Does not resolve thread safety structurally — only verifies current behavior
- Fortran 77 codebase remains difficult to maintain long-term
- No clean API, no context objects — IER codes and workspace arrays persist
- f2py binding remains unmaintained; Python ergonomics unchanged

**Key Risks:**
- CA003 epsilon guard values may alter numerical results beyond 1e-10 tolerance if chosen incorrectly — must validate against baseline for all 29 test cases
- U002 warm-start behavior may be undefined in edge cases, making it impossible to fully specify before Rust work begins

**Prerequisites:**
- Establish full 29-test performance and numerical baseline from current Fortran -O2 build
- Confirm S004 test reproduces CA001 reliably across gfortran versions
- Define epsilon constant strategy for fitpack_init() before patching CA003 routines

**Requirements addressed:** REQ-SPLEV-001, REQ-CURFIT-001, REQ-SAFETY-001, REQ-SAFETY-003

### A2: Rust Clean API (v2.0) ⭐ RECOMMENDED

**Description:** Reimplement all 35 user-facing routines in Rust, organized into the 5 proposed modules (core_numerics, bspline_primitives, univariate_evaluation, knot_selection, univariate_fitting). Replace IER codes with Result<T, FitpackError>. Replace workspace arrays with context objects (e.g. CurveWorkspace, SurfaceWorkspace). Expose SPALDE, DBLINT, PROFIL, SPLEV, SPLINT as high-priority entry points first. Use PyO3 for Python bindings with NumPy ndarray compatibility. Must match Fortran baseline to within 1e-10 on all 29 test cases. Target Q1 2027.

**Target users:** New Python and Rust consumers wanting a safe, ergonomic API. SciPy maintainers evaluating a long-term replacement for the f2py bridge. Parallel data processing pipelines requiring thread safety.

**Effort:** 4 months  |  **Risk:** MEDIUM

**Pros:**
- Structural thread safety — no global state, context objects are Send+Sync
- Memory safety guarantees eliminate entire classes of undefined behavior
- Clean API: context objects, Result errors, no workspace arrays — matches stated preference
- PyO3 binding is actively maintained and supports Python 3.8+ and NumPy ndarray natively
- Modular architecture (12 proposed modules) enables incremental testing and future extension

**Cons:**
- Highest implementation effort of all avenues
- Numerical parity with Fortran 77 at 1e-10 tolerance requires careful translation of EQUIVALENCE blocks, computed GOTOs, and implicit DO loops
- Requires A1 behavioral baseline (especially U002 warm-start) to be complete before starting
- Rust build toolchain adds complexity for platform support (macOS arm64, Linux x86_64, Linux arm64)

**Key Risks:**
- Fortran 77 idioms (EQUIVALENCE, computed GOTO, implicit typing) may introduce subtle numerical differences during translation — SPALDE and DBLINT are particularly complex
- FPRATI and FPSYSY involve iterative numerical procedures where convergence behavior may diverge from Fortran under different floating-point evaluation order
- PyO3 ABI stability across Python minor versions requires ongoing maintenance

**Prerequisites:**
- A1 must be complete and all 35 entry points validated with behavioral baselines including U001 and U002
- Define FitpackError enum covering all IER codes before starting any routine translation
- Establish cross-validation harness that runs Rust and Fortran side-by-side on identical inputs and asserts 1e-10 tolerance

**Requirements addressed:** REQ-SPLEV-001, REQ-SPALDE-001, REQ-DBLINT-001, REQ-PROFIL-001, REQ-SPLINT-001, REQ-SPROOT-001, REQ-BISPEV-001, REQ-CUALDE-001, REQ-THREAD-001, REQ-PYTHON-001, REQ-NUMPY-001, REQ-SAFETY-001, REQ-SAFETY-003

### A3: Python Compat Shim (v2.1)

**Description:** Build a drop-in Python compatibility layer over the Rust v2.0 API that exactly mirrors the scipy.interpolate calling conventions. Map numpy array inputs to Rust context objects transparently. Preserve 32-bit integer behavior for existing callers. Expose the same 16 routines currently accessible via scipy.interpolate. Shim must pass SciPy's own interpolate test suite without modification. Target Q2 2027.

**Target users:** The 200+ downstream Python packages that depend on scipy.interpolate FITPACK bindings. SciPy maintainers who want to swap the f2py backend without breaking the public API.

**Effort:** 6 weeks  |  **Risk:** MEDIUM

**Pros:**
- Zero migration cost for downstream consumers — drop-in replacement
- Unlocks thread safety and memory safety for all existing scipy.interpolate users transparently
- 32-bit integer compatibility shim satisfies legacy callers without polluting the clean Rust API
- Enables SciPy to deprecate f2py bridge on their own schedule

**Cons:**
- Depends on both A1 (behavioral baseline) and A2 (Rust API) being complete and stable
- SciPy's interpolate test suite is not under our control — any behavioral difference in edge cases will surface as failures
- Maintaining two Python API surfaces (clean PyO3 + compat shim) increases long-term maintenance burden

**Key Risks:**
- scipy.interpolate exposes undocumented IER code behaviors that the shim must replicate exactly — U002 warm-start is a known example
- 32-bit integer overflow edge cases in the compat shim may silently produce wrong results if not explicitly tested

**Prerequisites:**
- A2 Rust clean API must be complete and passing all 35-entry-point validation suite
- Obtain or reproduce SciPy interpolate test suite as an acceptance gate
- Document all 16 scipy-exposed routines' IER→exception mapping before shim implementation

**Requirements addressed:** REQ-PYTHON-001, REQ-NUMPY-001, REQ-COMPAT-001, REQ-32BIT-001

### A4: Incremental Rust-in-Fortran Hybrid

**Description:** Rather than a full Rust rewrite, replace individual high-priority routines (SPLEV, SPLINT, SPALDE, DBLINT, PROFIL) one at a time with Rust implementations called via C FFI from the existing Fortran shell. Each replaced routine is validated independently before the next begins. Allows partial delivery of thread-safe, safe-memory routines without waiting for full rewrite.

**Target users:** Teams that need incremental risk reduction and cannot wait for a full Rust rewrite. Useful if Q1 2027 Rust deadline is at risk.

**Effort:** 3 months  |  **Risk:** MEDIUM

**Pros:**
- Incremental delivery — each replaced routine ships independently
- Reduces risk of large-bang numerical regression across all 35 routines simultaneously
- High-priority routines (SPLEV, SPLINT, SPALDE, DBLINT, PROFIL) get safety fixes earliest

**Cons:**
- Fortran-to-C-to-Rust FFI boundary introduces calling convention complexity and potential ABI mismatches
- Hybrid codebase is harder to maintain than either pure Fortran or pure Rust
- Does not deliver clean API or context objects — IER codes and workspace arrays persist in the Fortran shell
- Thread safety is only partial until all routines are replaced

**Key Risks:**
- Fortran COMMON blocks and EQUIVALENCE in internal fp* routines make clean FFI boundaries difficult to define
- Partial replacement may create inconsistent numerical behavior between replaced and unreplaced routines sharing internal state

**Prerequisites:**
- A1 Fortran fork must be complete to establish clean baseline before any routine is replaced
- Define C FFI calling convention for array passing (column-major Fortran vs row-major C) before first routine replacement

**Requirements addressed:** REQ-SPLEV-001, REQ-SPALDE-001, REQ-DBLINT-001, REQ-PROFIL-001, REQ-SPLINT-001, REQ-SAFETY-001, REQ-SAFETY-003

## Comparison Table

| Avenue | Effort | Risk | Recommended |
|---|---|---|---|
| A1: Fortran Fork (v1.0) | 6 weeks | LOW | No |
| A2: Rust Clean API (v2.0) | 4 months | MEDIUM | ✅ Yes |
| A3: Python Compat Shim (v2.1) | 6 weeks | MEDIUM | No |
| A4: Incremental Rust-in-Fortran Hybrid | 3 months | MEDIUM | No |

## Recommended Sequence

A1: Fortran Fork (v1.0) → A2: Rust Clean API (v2.0) → A3: Python Compat Shim (v2.1)

A1 (Fortran Fork) must come first because it fixes confirmed safety defects CA001 and CA003, establishes the 35/35 entry-point behavioral baseline including U001 thread-safety verification and U002 warm-start documentation, and proves the AI-assisted maintenance pipeline at low risk. Without A1's validated baseline, A2 has no authoritative reference to match at 1e-10 tolerance. A2 (Rust Clean API) is the recommended primary avenue because it delivers structural thread safety, memory safety, and the clean context-object API required by the stated preferences and Must constraints — it should begin immediately after A1 ships. A3 (Python Compat Shim) is sequenced last because it depends on A2's stable API and is the mechanism by which the 200+ downstream scipy.interpolate consumers receive the benefits of A2 without any migration cost. A4 (Hybrid) is held in reserve as a contingency if A2 timeline slips past Q1 2027.

## Open Questions

- U001: Does CURFIT with separate workspaces pass a 4-thread concurrent call test? If global state is found, the Fortran fork scope expands significantly before A2 can claim thread safety.
- U002: What is the exact behavior of CURFIT iopt=1 after caller modifies t[] between calls? This must be documented as a spec baseline in A1 before A2 can implement warm-start correctly.
- CA003: What epsilon constant value should fitpack_init() expose for the 16 fp* division guards? Using machine epsilon directly may change convergence behavior in FPRATI and FPSYSY — needs numerical analysis before patching.
- What is the acceptable IER→FitpackError mapping for the 16 scipy-exposed routines? Specifically, should CA001-style silent extrapolation become a warning, an error, or a new IER value in the Rust API?
- Does the SciPy f2py bridge expose any of the 16 non-user-facing fp* routines directly? If so, the compat shim scope in A3 expands beyond the documented 29 user-facing routines.
- Are there any callers of the Fortran fork that depend on the current CA001 silent extrapolation behavior (IER=0 on out-of-range x)? Breaking this in A1 may require a deprecation notice.

## Immediate Next Steps

1. Run the existing 29-test suite under gfortran -O2 and record per-routine numerical outputs as the authoritative baseline reference file — this is the 1e-10 tolerance target for all subsequent avenues
2. Write and execute the U001 threading test: call CURFIT from 4 threads with separate workspaces, confirm PASS or document any global state found, and update A1 scope accordingly
3. Write the U002 warm-start test: call CURFIT iopt=0, modify t[], call iopt=1, record actual behavior as spec baseline — this must be documented before A2 begins
4. Implement CA001 fix in SPLEV: add IER=-1 return when x is outside knot range, confirm S004 safety test now passes, and verify no regression in the 29-test numerical baseline
5. Implement CA003 epsilon guards in all 16 fp* routines using a fitpack_init() epsilon constant, validate all 29 tests remain within 1e-10 of baseline, and publish gaia-fitpack v1.0 Fortran fork
6. Define the FitpackError enum and context object interfaces (CurveWorkspace, SurfaceWorkspace) for the Rust API, targeting SPALDE, DBLINT, PROFIL, SPLEV, SPLINT as the first five routines to implement in A2