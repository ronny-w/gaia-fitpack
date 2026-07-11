# patch_08: CMake build system for the double-precision FITPACK fork.
#
# Builds:
#   * libfitpack.a  -- static library from all fixed-form .f sources in src/
#   * test_SXXX     -- 10 Fortran-90 regression drivers in tests/
# and registers each driver with CTest so `ctest` runs the whole suite.
#
# Supported compilers: gfortran and ifort (Intel). -O2 by default.
#
# Usage:
#   cmake -B build -DCMAKE_Fortran_COMPILER=gfortran
#   cmake --build build -j4
#   ctest --test-dir build --output-on-failure

cmake_minimum_required(VERSION 3.13)
project(fitpack_fork Fortran)

# ---------------------------------------------------------------------------
# Standard / optimization defaults
# ---------------------------------------------------------------------------
# The library sources are legacy fixed-form FORTRAN 77 (F90 is the minimum
# language level required to build the modern .f90 test drivers).
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# -O2 by default (Release).
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(OPT_FLAGS "-O2")
  # NOTE: the legacy library relies on implicit typing, so -fimplicit-none is
  # applied only to the (implicit none) test drivers below, not to the library.
  set(LIB_WARN_FLAGS "-Wall")
  set(DRIVER_STRICT_FLAGS "-fimplicit-none -Wimplicit-interface -ffree-line-length-none")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(OPT_FLAGS "-O2")
  set(LIB_WARN_FLAGS "-warn general")
  set(DRIVER_STRICT_FLAGS "-implicitnone -warn interfaces")
else()
  set(OPT_FLAGS "-O2")
  set(LIB_WARN_FLAGS "")
  set(DRIVER_STRICT_FLAGS "")
endif()

# ---------------------------------------------------------------------------
# Static library: libfitpack.a
# ---------------------------------------------------------------------------
file(GLOB FITPACK_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/*.f")

add_library(fitpack STATIC ${FITPACK_SOURCES})
set_target_properties(fitpack PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
  OUTPUT_NAME fitpack)
separate_arguments(_lib_flags UNIX_COMMAND "${OPT_FLAGS} ${LIB_WARN_FLAGS}")
target_compile_options(fitpack PRIVATE ${_lib_flags})

# ---------------------------------------------------------------------------
# Test drivers + CTest integration
# ---------------------------------------------------------------------------
enable_testing()

set(FITPACK_TESTS
  test_S001 test_S002 test_S003 test_S004 test_S005
  test_S006 test_S007 test_S008 test_S009 test_S010)

separate_arguments(_drv_flags UNIX_COMMAND "${OPT_FLAGS} ${DRIVER_STRICT_FLAGS}")

foreach(t ${FITPACK_TESTS})
  add_executable(${t} "${CMAKE_SOURCE_DIR}/tests/${t}.f90")
  target_compile_options(${t} PRIVATE ${_drv_flags})
  target_link_libraries(${t} PRIVATE fitpack)
  add_test(NAME ${t} COMMAND ${t})
  # Any nonzero exit (STOP 1) is a failure; drivers print PASS/FAIL themselves.
  set_tests_properties(${t} PROPERTIES
    FAIL_REGULAR_EXPRESSION "FAIL"
    PASS_REGULAR_EXPRESSION "PASS")
endforeach()
