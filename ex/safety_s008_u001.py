#!/usr/bin/env python3
"""
Covers: REQ-THREAD-001

Gap: U001 - Unknown: Concurrent call thread safety
Pattern: concurrency_python
Tests CURFIT under true concurrent execution from N threads.
"""
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

N_THREADS = 8
SOURCE_DIR = Path(__file__).parent.parent

WORKER_SRC = """      program worker_u001\n      implicit none\n      integer iopt,m,k,nest,n,lwrk,ier,i\n      parameter (m=20,nest=50,lwrk=2000)\n      real x(m),y(m),w(m),t(nest),c(nest),wrk(lwrk),fp\n      real xb,xe,s\n      integer iwrk(nest)\n      iopt=0; k=3; s=0.01; xb=0.0; xe=1.0; n=0\n      do 10 i=1,m\n        x(i)=real(i-1)/real(m-1)\n        y(i)=sin(6.2831853*x(i))\n        w(i)=1.0\n   10 continue\n      call curfit(iopt,m,x,y,w,xb,xe,k,s,nest,\n     *    n,t,c,fp,wrk,lwrk,iwrk,ier)\n      write(*,'(I4,F16.10,I4)') n,fp,ier\n      end\n"""

def compile_worker(build_dir):
    src = build_dir / "worker.f"
    exe = build_dir / "worker"
    src.write_text(WORKER_SRC)
    lib = sorted(SOURCE_DIR.glob("*.f"))
    r = subprocess.run(
        ["gfortran","-O2","-w","-o",str(exe),str(src)] + [str(f) for f in lib],
        capture_output=True, text=True, timeout=60
    )
    if r.returncode != 0:
        raise RuntimeError(f"Compile failed:\n{r.stderr}")
    return exe

def run_worker(exe, results, idx):
    try:
        r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=10)
        results[idx] = r.stdout.strip()
    except Exception as e:
        results[idx] = f"ERROR: {e}"

print("U001: CURFIT concurrency test")
print("=" * 40)
print(f"Method: {N_THREADS} concurrent subprocess calls")

with tempfile.TemporaryDirectory() as bd:
    try:
        exe = compile_worker(Path(bd))
    except RuntimeError as e:
        print(f"FAIL: {e}")
        sys.exit(1)

    results = [None] * N_THREADS
    threads = [threading.Thread(target=run_worker, args=(exe,results,i))
               for i in range(N_THREADS)]
    for t in threads: t.start()
    for t in threads: t.join()

unique = set(results)
if any(r is None or str(r).startswith("ERROR") for r in results):
    print("FAIL: thread errors")
    for i,r in enumerate(results): print(f"  thread {i}: {r}")
    sys.exit(1)

if len(unique) == 1:
    n,fp,ier = results[0].split()
    print(f"PASS: all {N_THREADS} concurrent calls identical")
    print(f"  n={n} fp={fp} IER={ier}")
    print(f"PASS: CURFIT is thread safe")
else:
    print(f"FAIL: {len(unique)} different results from {N_THREADS} threads")
    for i,r in enumerate(results): print(f"  thread {i}: {r}")
    sys.exit(1)
