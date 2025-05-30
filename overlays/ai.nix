# /qompassai/nur-packages/overlays/.nix
# Qompass AI Overlay
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
final: prev: {
  tensorflow-optimized = prev.tensorflow.override {
    cudaSupport = true;
    cudnnSupport = true;
    tensorboardSupport = true;
    xlaSupport = true;
    tensorrtSupport = true;
  };
  pytorch-full = prev.python3Packages.pytorch.override {
    cudaSupport = true;
    rocmSupport = false;
    magmaSupport = true;
    mpiSupport = true;
    buildDocs = false;
    cudnnSupport = true;
    nccl = final.nccl-hpc;
  };
  intel-tensorflow = prev.tensorflow.override {
    mkl = final.intel-oneapi-mkl;
    openmp = final.intel-oneapi-openmp;
    dnnlSupport = true;
  };
  openvino-optimized = prev.openvino.override {
    enableGpu = true;
    enableMyriad = true;
    enableGna = true;
    enableVpu = true;
  };
  cupy-hpc = prev.python3Packages.cupy.override {
    cudatoolkit = final.nvidia-hpc-sdk;
    nccl = final.nccl-hpc;
  };
  jax-nvidia = prev.python3Packages.jax.override {
    cudaSupport = true;
    cudatoolkit = final.nvidia-hpc-sdk;
  };
  tensorrt-python = final.callPackage (
    {
      buildPythonPackage,
      fetchPypi,
      ...
    }:
      tensorrt = final.callPackage (
    { stdenv, fetchFromGitHub, cmake, cudatoolkit, ... }:
    stdenv.mkDerivation rec {
      pname = "tensorrt";
      version = "10.11";
      
      src = fetchFromGitHub {
        owner = "NVIDIA";
        repo = "TensorRT";
        rev = "9255eb39e6642787828a4c1f7fc1d09fe004e7a2";
        sha256 = "sha256-OXI6mR2X+kF/0EO5RSBnnaGjMKD6AkuQMfl0OMzayxc=";
      };
      nativeBuildInputs = [ cmake ];
      buildInputs = [ final.nvidia-hpc-sdk cudatoolkit ];
      meta = with final.lib; {
        description = "NVIDIA TensorRT inference library (GitHub source)";
        homepage = "https://github.com/NVIDIA/TensorRT";
        license = licenses.asl20;
      };
    }
  ) {};
      buildPythonPackage rec {
        pname = "tensorrt";
        version = "10.11.33";
        src = fetchPypi {
          inherit pname version;
          sha256 = "a3d6048f86e11ea5202d473646194d3be866c0c8d578ac0b7eeb91d923f65d0b";
        };
        buildInputs = [final.nvidia-hpc-sdk];
        meta.description = "NVIDIA TensorRT Python bindings";
      }
  ) {};
  cudf-nvidia = final.callPackage (
    {
      buildPythonPackage,
      fetchFromGitHub,
      ...
    }:
      buildPythonPackage rec {
        pname = "cudf";
        version = "25.04.00";
        src = fetchFromGitHub {
          owner = "rapidsai";
          repo = "cudf";
          rev = "6bc420631d12b0e7d87c5ede7710ac5b7154fd8d";
          sha256 = "sha256-RCS5XK5AbUof/MuROg1qWxNA3YcpIVfu/7XrRKuuD9U=";
        };
        buildInputs = [
          final.nvidia-hpc-sdk
          final.cupy-hpc
        ];
        meta.description = "GPU DataFrame library";
      }
  ) {};
  triton-nvidia = prev.python3Packages.triton.override {
    cudatoolkit = final.nvidia-hpc-sdk;
  };
  horovod-nvidia = prev.python3Packages.horovod.override {
    cudaSupport = true;
    nccl = final.nccl-hpc;
    mpi = final.openmpi-nvidia;
  };
  qiskit-aer-gpu = prev.python3Packages.qiskit-aer.override {
    cudaSupport = true;
    cudatoolkit = final.nvidia-hpc-sdk;
  };
  pennylane-lightning = final.callPackage (
  {
    buildPythonPackage,
    fetchFromGitHub,
    cmake,
    pybind11,
    eigen,
    ...
  }:
    buildPythonPackage rec {
      pname = "pennylane-lightning";
      version = "0.41.1";
      src = fetchFromGitHub {
        owner = "PennyLaneAI";
        repo = "pennylane-lightning";
        rev = "884f7dadad7d24a2f23d0356e2be1b4b733915e4";
        sha256 = "sha256-TqliaWhcU5eXSmI6Xf+ui7PdTrQmaD2kUn28oL0wQgQ=";
      };
      nativeBuildInputs = [ cmake ];
      buildInputs = [ 
        final.nvidia-hpc-sdk 
        pybind11 
        eigen 
      ];
      propagatedBuildInputs = [ final.python3Packages.pennylane ];
      cmakeFlags = [
        "-DENABLE_NATIVE=ON"
        "-DENABLE_BLAS=ON"
        "-DENABLE_OPENMP=ON"
        "-DENABLE_WARNINGS=OFF"
      ];
      meta.description = "PennyLane Lightning GPU plugin (built from source)";
    }
) {};
  numpy-intel = prev.python3Packages.numpy.override {
    blas = final.intel-oneapi-mkl;
    lapack = final.intel-oneapi-mkl;
  };
  scipy-intel = prev.python3Packages.scipy.override {
    numpy = final.numpy-intel;
    blas = final.intel-oneapi-mkl;
    lapack = final.intel-oneapi-mkl;
  };
  xgboost-gpu = prev.python3Packages.xgboost.override {
    cudaSupport = true;
    cudatoolkit = final.nvidia-hpc-sdk;
  };
  lightgbm-gpu = prev.python3Packages.lightgbm.override {
    cudaSupport = true;
    cudatoolkit = final.nvidia-hpc-sdk;
  };
  optix-ai = final.callPackage (
    {stdenv, ...}:
      stdenv.mkDerivation {
        pname = "optix-ai-toolkit";
        version = "1.0";
        src = final.optix-enhanced;
        buildInputs = [
          final.nvidia-hpc-sdk
          final.pytorch-full
          final.tensorflow-optimized
        ];
        installPhase = ''
          mkdir -p $out
          cp -r $src/* $out/
        '';
        meta.description = "OptiX AI integration toolkit";
      }
  ) {};
  hybrid-inference = final.buildEnv {
    name = "hybrid-ai-inference";
    paths = [
      final.pytorch-full
      final.tensorflow-optimized
      final.cupy-hpc
      final.tensorrt-python
      final.intel-tensorflow
      final.openvino-optimized
      final.numpy-intel
      final.scipy-intel
      final.horovod-nvidia
      final.nccl-hpc
      final.qiskit-aer-gpu
      final.pennylane-lightning-gpu
      final.nvidia-hpc-sdk
      final.jupyter
      final.tensorboard
    ];
  };
  ai-dev-shell = final.mkShell {
    buildInputs = [final.hybrid-inference];
    shellHook = ''
      # NVIDIA environment
      export CUDA_VISIBLE_DEVICES=0
      export NVIDIA_VISIBLE_DEVICES=0
      export OPENVINO_DEVICE=GPU.1
      export DNNL_VERBOSE=0
      export MKL_NUM_THREADS=8
      export NCCL_SOCKET_IFNAME=lo
      export NCCL_DEBUG=INFO
      export TF_FORCE_GPU_ALLOW_GROWTH=true
      export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024
      export VK_DEVICE_INDEX=0
    '';
  };
  gpu-monitor-tools = final.buildEnv {
    name = "gpu-monitoring-tools";
    paths = [
      final.nvtop
      final.intel-gpu-tools
      final.nvidia-ml-py
      final.pynvml
    ];
  };
}
