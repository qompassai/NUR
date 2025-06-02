# /qompassai/nur-packages/packages/pkgs/nvidia-hpc-sdk/test-compile.nix
# ---------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  lib,
  stdenv,
  runCommand,
  writeText,
  nvidia-hpc-sdk,
}: let
  testPrograms = {
    c-hello = writeText "hello.c" ''
      #include <stdio.h>
      int main() {
          printf("Hello from NVIDIA HPC SDK C compiler!\n");
          return 0;
      }
    '';

    cpp-hello = writeText "hello.cpp" ''
      #include <iostream>
      int main() {
          std::cout << "Hello from NVIDIA HPC SDK C++ compiler!" << std::endl;
          return 0;
      }
    '';

    fortran-hello = writeText "hello.f90" ''
      program hello
          print *, 'Hello from NVIDIA HPC SDK Fortran compiler!'
      end program hello
    '';

    openmp-test = writeText "openmp_test.c" ''
      #include <stdio.h>
      #include <omp.h>
      int main() {
          #pragma omp parallel
          {
              printf("Thread %d of %d\n", omp_get_thread_num(), omp_get_num_threads());
          }
          return 0;
      }
    '';
  };
in {
  c-compile =
    runCommand "nvidia-hpc-c-test" {
      buildInputs = [nvidia-hpc-sdk];
      src = testPrograms.c-hello;
    } ''
      echo "Testing C compilation..."
      cp $src hello.c

      ${nvidia-hpc-sdk}/bin/nvc -o hello_c hello.c
      ./hello_c > output.txt

      if ! grep -q "Hello from NVIDIA HPC SDK C compiler" output.txt; then
        echo "ERROR: C program output incorrect"
        cat output.txt
        exit 1
      fi

      echo "✓ C compilation and execution successful"
      cp output.txt $out
    '';

  cpp-compile =
    runCommand "nvidia-hpc-cpp-test" {
      buildInputs = [nvidia-hpc-sdk];
      src = testPrograms.cpp-hello;
    } ''
      echo "Testing C++ compilation..."
      cp $src hello.cpp

      ${nvidia-hpc-sdk}/bin/nvc++ -o hello_cpp hello.cpp
      ./hello_cpp > output.txt

      if ! grep -q "Hello from NVIDIA HPC SDK C++ compiler" output.txt; then
        echo "ERROR: C++ program output incorrect"
        cat output.txt
        exit 1
      fi

      echo "✓ C++ compilation and execution successful"
      cp output.txt $out
    '';

  fortran-compile =
    runCommand "nvidia-hpc-fortran-test" {
      buildInputs = [nvidia-hpc-sdk];
      src = testPrograms.fortran-hello;
    } ''
      echo "Testing Fortran compilation..."
      cp $src hello.f90

      if [ -x "${nvidia-hpc-sdk}/bin/nvfortran" ]; then
        ${nvidia-hpc-sdk}/bin/nvfortran -o hello_f90 hello.f90
        ./hello_f90 > output.txt

        if ! grep -q "Hello from NVIDIA HPC SDK Fortran compiler" output.txt; then
          echo "ERROR: Fortran program output incorrect"
          cat output.txt
          exit 1
        fi

        echo "✓ Fortran compilation and execution successful"
        cp output.txt $out
      else
        echo "⚠ Fortran compiler not found, skipping test"
        echo "fortran-not-available" > $out
      fi
    '';

  openmp-test =
    runCommand "nvidia-hpc-openmp-test" {
      buildInputs = [nvidia-hpc-sdk];
      src = testPrograms.openmp-test;
    } ''
      echo "Testing OpenMP support..."
      cp $src openmp_test.c

      ${nvidia-hpc-sdk}/bin/nvc -fopenmp -o openmp_test openmp_test.c
      export OMP_NUM_THREADS=2
      ./openmp_test > output.txt

      if ! grep -q "Thread" output.txt; then
        echo "ERROR: OpenMP test failed"
        cat output.txt
        exit 1
      fi

      echo "✓ OpenMP compilation and execution successful"
      cp output.txt $out
    '';
}
