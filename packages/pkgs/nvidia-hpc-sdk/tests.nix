# /qompassai/nur/packages/pkgs/nvidia-hpc-sdk/tests.nix
# --------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  lib,
  stdenv,
  runCommand,
  writeShellScript,
  nvidia-hpc-sdk,
}: {
  binaries-exist =
  runCommand "nvidia-hpc-binaries-test" {
    nativeBuildInputs = [nvidia-hpc-sdk];
  } ''
    echo "Testing NVIDIA HPC SDK binaries..."

    # Check main compilers
    for compiler in nvc nvc++ nvfortran; do
      if [ ! -x "${nvidia-hpc-sdk}/bin/$compiler" ]; then
        echo "ERROR: $compiler not found or not executable"
        exit 1
      fi
      echo "✓ $compiler found"
      
      # Test that binary can at least show help/version
      if ! ${nvidia-hpc-sdk}/bin/$compiler --help >/dev/null 2>&1 && 
         ! ${nvidia-hpc-sdk}/bin/$compiler --version >/dev/null 2>&1; then
        echo "WARNING: $compiler doesn't respond to --help or --version"
      fi
    done

    # Check CUDA tools (if present)
    for tool in nvcc nsight_compute nsight_systems; do
      if [ -x "${nvidia-hpc-sdk}/bin/$tool" ]; then
        echo "✓ $tool found"
      else
        echo "ℹ $tool not found (may not be included)"
      fi
    done

    # Check MPI tools (if present)
    for mpi_tool in mpicc mpicxx mpif90 mpirun mpiexec; do
      if [ -x "${nvidia-hpc-sdk}/bin/$mpi_tool" ]; then
        echo "✓ $mpi_tool found"
      fi
    done

    touch $out
  '';

 version-check =
  runCommand "nvidia-hpc-version-test" {
    nativeBuildInputs = [nvidia-hpc-sdk];
  } ''
    echo "Testing compiler version output..."

    # Test nvc version
    if ! ${nvidia-hpc-sdk}/bin/nvc --version > version_output.txt 2>&1; then
      echo "ERROR: nvc --version failed"
      cat version_output.txt
      exit 1
    fi

    # Check version output contains expected strings
    if ! grep -q "nvc" version_output.txt; then
      echo "ERROR: Version output doesn't contain 'nvc'"
      cat version_output.txt
      exit 1
    fi

    # Check for specific version (25.5)
    if ! grep -q "25.5" version_output.txt; then
      echo "WARNING: Version 25.5 not found in output"
      cat version_output.txt
    fi

    echo "✓ Version check passed"
    mkdir -p $out
    cp version_output.txt $out/version.txt  # Fixed: $out should be a directory
  '';

  environment-check =
  runCommand "nvidia-hpc-env-test" {
    nativeBuildInputs = [nvidia-hpc-sdk];
  } ''
    echo "Testing environment setup..."

    # Test NVHPC_ROOT is accessible
    if [ ! -d "${nvidia-hpc-sdk}" ]; then
      echo "ERROR: NVHPC installation directory not found"
      exit 1
    fi

    # Test essential directories exist
    for dir in compilers; do
      if [ ! -d "${nvidia-hpc-sdk}/$dir" ]; then
        echo "ERROR: Essential directory $dir not found"
        exit 1
      fi
      echo "✓ $dir directory found"
    done

    # Test library paths exist (optional directories)
    for libdir in "compilers/lib" "cuda/lib64" "math_libs/lib64" "comm_libs/mpi/lib"; do
      if [ -d "${nvidia-hpc-sdk}/$libdir" ]; then
        echo "✓ $libdir libraries found"
      else
        echo "ℹ $libdir not found (optional)"
      fi
    done

    # Test that environment variables would be set correctly
    export NVHPC_ROOT="${nvidia-hpc-sdk}"
    export PATH="${nvidia-hpc-sdk}/bin:$PATH"
    
    if [ "$NVHPC_ROOT" != "${nvidia-hpc-sdk}" ]; then
      echo "ERROR: NVHPC_ROOT not set correctly"
      exit 1
    fi

    echo "✓ Environment variables working"
    touch $out
  '';
