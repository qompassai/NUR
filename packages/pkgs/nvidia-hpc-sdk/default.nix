# ~/.GH/Qompass/nur-packages/packages/pkgs/nvidia-hpc-sdk/default.nix
# -------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  zlib,
  ncurses,
  glibc,
  gcc,
  binutils,
  which,
  perl,
  python3,
  ...
}:
stdenv.mkDerivation rec {
  pname = "nvidia-hpc-sdk";
  version = "25.3";
  src = /opt/nvidia/hpc_sdk;
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    zlib
    ncurses
    glibc
    gcc
    binutils
    which
    perl
    python3
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    cp -r Linux_x86_64/${version}/* $out/
    # Create activation script
    cp activate $out/activate
    # Patch binaries
    find $out -type f -executable -exec autoPatchelf {} \; || true
    # Create wrapper scripts
    mkdir -p $out/bin
    # Compiler wrappers
    makeWrapper $out/compilers/bin/nvc $out/bin/nvc \
      --prefix PATH : $out/compilers/bin:$out/cuda/bin \
      --prefix LD_LIBRARY_PATH : $out/compilers/lib:$out/cuda/lib64:$out/math_libs/lib64 \
      --set NVHPC_ROOT $out \
      --set CUDA_ROOT $out/cuda
    makeWrapper $out/compilers/bin/nvc++ $out/bin/nvc++ \
      --prefix PATH : $out/compilers/bin:$out/cuda/bin \
      --prefix LD_LIBRARY_PATH : $out/compilers/lib:$out/cuda/lib64:$out/math_libs/lib64 \
      --set NVHPC_ROOT $out \
      --set CUDA_ROOT $out/cuda
    makeWrapper $out/compilers/bin/nvfortran $out/bin/nvfortran \
      --prefix PATH : $out/compilers/bin:$out/cuda/bin \
      --prefix LD_LIBRARY_PATH : $out/compilers/lib:$out/cuda/lib64:$out/math_libs/lib64 \
      --set NVHPC_ROOT $out \
      --set CUDA_ROOT $out/cuda
    makeWrapper $out/compilers/bin/pgcc $out/bin/pgcc \
      --prefix PATH : $out/compilers/bin:$out/cuda/bin \
      --prefix LD_LIBRARY_PATH : $out/compilers/lib:$out/cuda/lib64:$out/math_libs/lib64 \
      --set NVHPC_ROOT $out \
      --set CUDA_ROOT $out/cuda
    # CUDA tools
    for tool in nvcc nvprof nvprune nsight_compute nsight_systems; do
      if [ -f $out/cuda/bin/$tool ]; then
        makeWrapper $out/cuda/bin/$tool $out/bin/$tool \
          --prefix PATH : $out/cuda/bin \
          --prefix LD_LIBRARY_PATH : $out/cuda/lib64 \
          --set CUDA_ROOT $out/cuda
      fi
    done
    # MPI wrappers
    if [ -d $out/comm_libs/mpi/bin ]; then
      for mpi_tool in mpicc mpicxx mpif90 mpirun mpiexec; do
        if [ -f $out/comm_libs/mpi/bin/$mpi_tool ]; then
          makeWrapper $out/comm_libs/mpi/bin/$mpi_tool $out/bin/$mpi_tool \
            --prefix PATH : $out/comm_libs/mpi/bin \
            --prefix LD_LIBRARY_PATH : $out/comm_libs/mpi/lib
        fi
      done
    fi
  '';
  meta = with lib; {
    description = "NVIDIA HPC Software Development Kit";
    homepage = "https://developer.nvidia.com/hpc-sdk";
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = ["Qompass AI"];
  };
}
