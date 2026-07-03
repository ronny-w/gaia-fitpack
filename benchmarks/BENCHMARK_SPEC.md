# FITPACK Benchmark Specification

All gaia-fitpack implementations must be measured on the same axes
using the same test inputs. This enables direct comparison across
language implementations.

## Measurement axes

### Required (all implementations)

| Axis | Unit | Description |
|------|------|-------------|
| `wall_sec` | seconds | Median wall clock time over 5 runs |
| `peak_kb` | kilobytes | Peak resident set size |
| `numerical_error_max` | absolute | Max deviation from Fortran F77 baseline |
| `passes_tests` | bool | All functional and safety tests pass |

### Required for concurrent implementations

| Axis | Unit | Description |
|------|------|-------------|
| `concurrent_throughput` | calls/sec | N=4 parallel calls, no locking |
| `thread_safe` | bool | No data corruption under concurrent use |

### Optional

| Axis | Unit | Description |
|------|------|-------------|
| `cpu_sec` | seconds | User + system CPU time |
| `allocations` | count | Heap allocation count per call |
| `cache_miss_rate` | ratio | L1/L2/L3 miss rate (perf/instruments) |
| `binary_size_kb` | kilobytes | Compiled library size |

## Acceptance criteria for a replacement implementation

1. `passes_tests` = true for all 29 functional + 5 safety tests
2. `numerical_error_max` < 1e-10 (double precision tolerance)
3. `wall_sec` <= 2x F77 baseline (must not be more than 2x slower)
4. `peak_kb` <= 2x F77 baseline
5. `thread_safe` = true (required improvement over F77)

## Running benchmarks

    ./run_perf_baseline.sh          # Fortran F77 baseline
    cd rust && cargo bench          # Rust (future)
    cd python && python -m pytest benchmarks/  # Python (future)
