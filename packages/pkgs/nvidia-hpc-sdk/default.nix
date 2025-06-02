# /qompassai/NixOS/modules/services/networking.nix
# Qompass AI Nix User Repository (NUR) NVIDIA HPC SDK 25.5 For x86-64/aarch64
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  binutils,
  buildFHSUserEnv,
  dbus,
  fontconfig,
  gcc,
  glib,
  glibc,
  gmp,
  libICE,
  libdrm,
  libGL,
  libtiff,
  libxcrypt,
  libxkbcommon,
  libxkbfile,
  libxshmfence,
  libxml2,
  makeWrapper,
  ncurses,
  nss,
  nspr,
  perl,
  python3,
  rdma-core,
  runCommand,
  testers,
  wayland,
  which,
  writeScript,
  writeShellScript,
  writeText,
  xorg,
  zlib,
}: let
  # FHS environment for installer (if needed)
  fhsEnv = buildFHSUserEnv {
    name = "nvidia-hpc-installer-env";
    targetPkgs = pkgs: with pkgs; [bash coreutils gcc glibc perl];
  };
  platformDir =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then "nvhpc_2025_255_Linux_x86_64_cuda_multi"
    else "nvhpc_2025_255_Linux_aarch64_cuda_multi";
  sourceInfo =
    sources.${
      stdenv.hostPlatform.system
    } or (throw
      "Unsupported platform: ${stdenv.hostPlatform.system}");
  sources = {
    aarch64-linux = {
      sha256 = "0iw3nbzg45fx9x9g5zdkpgfvqjw2aw3m5z1kn90ka37yzm5q5am1";
      url = "https://developer.download.nvidia.com/hpc-sdk/25.5/nvhpc_2025_255_Linux_aarch64_cuda_multi.tar.gz";
    };
    x86_64-linux = {
      sha256 = "1lj6577qxh1aljljqggla8pmd803w3v1jhc9l4qjwzsv4a9wnxls";
      url = "https://developer.download.nvidia.com/hpc-sdk/25.5/nvhpc_2025_255_Linux_x86_64_cuda_multi.tar.gz";
    };
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "nvidia-hpc-sdk";
    version = "25.5";
    src = fetchurl sourceInfo;
    buildInputs = [
      binutils
      cmake
      dbus
      fontconfig
      gcc
      glibc
      glib
      gmp
      libGL
      libdrm
      libtiff
      libxcrypt
      libxkbcommon
      libxml2
      ncurses
      ninja
      nss
      nspr
      perl
      pkg-config
      python3
      rdma-core
      wayland
      which
      xorg.libICE
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXi
      xorg.libxkbfile
      xorg.libXrender
      xorg.libXrandr
      xorg.libxshmfence
      xorg.libXtst
      xorg.xcbutilcursor
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutil
      zlib
    ];
    dontAutoPatchelf = true;
    dontStrip = false;
    separateDebugInfo = true;
    stripDebugList = ["lib" "compilers/lib" "math_libs/lib64" "cuda/lib64"];
    hardeningEnable = ["format" "stackprotector" "pic"];
    hardeningDisable = ["fortify" "relro"];
    env = {
      NIX_CFLAGS_COMPILE = "-Os -ffunction-sections -fdata-sections";
      NIX_CFLAGS_LINK = "-Wl,--gc-sections";
    };
    autoPatchelfIgnoreMissingDeps = [
      "libdbus-1.so.3"
      "libfontconfig.so.1"
      "libglib-2.0.so.0"
      "libGLX.so.0"
      "libgthread-2.0.so.0"
      "libibmad.so.5"
      "libibumad.so.3"
      "libibverbs.so.1"
      "libICE.so.6"
      "libnvidia-ml.so.1"
      "libOpenGL.so.0"
      "libpython3.10.so.1.0"
      "libpython3.11.so.1.0"
      "libpython3.12.so.1.0"
      "libpython3.8.so.1.0"
      "libpython3.9.so.1.0"
      "libQt6WlShellIntegration.so.6"
      "libtiff.so.5"
      "libwayland-client.so.0"
      "libwayland-cursor.so.0"
      "libwayland-egl.so.1"
      "libX11-xcb.so.1"
      "libX11.so.6"
      "libxcb-cursor.so.0"
      "libxcb-icccm.so.4"
      "libxcb-image.so.0"
      "libxcb-keysyms.so.1"
      "libxcb-render-util.so.0"
      "libxcb-render.so.0"
      "libxcb-shape.so.0"
      "libxcb-xfixes.so.0"
      "libxcb-xkb.so.1"
      "libxcb.so.1"
      "libxkbcommon-x11.so.0"
      "libxkbcommon.so.0"
      "libxkbfile.so.1"
      "libxshmfence.so.1"
    ];
    dontBuild = true;
    dontConfigure = true;
    nativeBuildInputs = [
      autoPatchelfHook
      cmake
      ninja
      pkg-config
      makeWrapper
      # fhsEnv  # Only needed if using installer
    ];
    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cd "${platformDir}"
      if [ -d "install_components/Linux_x86_64/${finalAttrs.version}" ]; then
        echo "Copying HPC SDK installation directly..."
        cp -r install_components/Linux_x86_64/${finalAttrs.version}/* $out/
      else
        echo "Fallback: copying all files..."
        cp -r * $out/
      fi
      echo "Removing unnecessary files..."
      find $out -name "*.pdf" -delete          # Remove documentation PDFs
      find $out -name "*.html" -delete         # Remove HTML docs
      find $out -name "*_test" -delete         # Remove test binaries
      find $out -name "examples" -type d -exec rm -rf {} + 2>/dev/null || true
      find $out -name "samples" -type d -exec rm -rf {} + 2>/dev/null || true
      find $out -name "*.bak" -delete
      find $out -name "*.orig" -delete
      find $out -name "*~" -delete
      find $out -type f -executable -name "*.so*" -exec autoPatchelf {} \; 2>/dev/null || true
      find $out -type f -executable -path "*/bin/*" -exec autoPatchelf {} \; 2>/dev/null || true
      mkdir -p $out/bin
      if [ -d "$out/compilers/bin" ]; then
        for compiler in nvc nvc++ nvfortran pgcc pgc++ pgfortran; do
          if [ -f "$out/compilers/bin/$compiler" ]; then
            makeWrapper "$out/compilers/bin/$compiler" "$out/bin/$compiler" \
              --prefix PATH : "$out/compilers/bin:$out/cuda/bin" \
              --prefix LD_LIBRARY_PATH : "$out/compilers/lib:$out/cuda/lib64:$out/math_libs/lib64" \
              --set NVHPC_ROOT "$out" \
              --set CUDA_ROOT "$out/cuda"
          fi
        done
      fi
      if [ -d "$out/cuda/bin" ]; then
        for tool in nvcc nvprof nvprune nsight_compute nsight_systems; do
          if [ -f "$out/cuda/bin/$tool" ]; then
            makeWrapper "$out/cuda/bin/$tool" "$out/bin/$tool" \
              --prefix PATH : "$out/cuda/bin" \
              --prefix LD_LIBRARY_PATH : "$out/cuda/lib64" \
              --set CUDA_ROOT "$out/cuda"
          fi
        done
      fi
      if [ -d "$out/comm_libs/mpi/bin" ]; then
        for mpi_tool in mpicc mpicxx mpif90 mpirun mpiexec; do
          if [ -f "$out/comm_libs/mpi/bin/$mpi_tool" ]; then
            makeWrapper "$out/comm_libs/mpi/bin/$mpi_tool" "$out/bin/$mpi_tool" \
              --prefix PATH : "$out/comm_libs/mpi/bin" \
              --prefix LD_LIBRARY_PATH : "$out/comm_libs/mpi/lib"
          fi
        done
      fi
      runHook postInstall
    '';

    postFixup = ''
      # Only patch executable directories, skip debug files
      find $out -type f -executable -not -name "*.debug" -not -path "*/debug/*" | while read -r file; do
        if [[ $(file "$file") =~ ELF.*executable ]]; then
          echo "Patching: $file"
          autoPatchelf "$file" || true
        fi
      done

      # Patch specific directories
      if [[ -d $out/bin ]]; then
        autoPatchelf $out/bin
      fi

      if [[ -d $out/lib ]]; then
        find $out/lib -name "*.so*" -not -name "*.debug" -exec autoPatchelf {} \;
      fi
    '';

    passthru = {
      tests = {
        version = testers.testVersion {
          package = finalAttrs.finalPackage;
          command = "nvc --version";
        };

        simple-compile =
          runCommand "nvidia-hpc-test" {
            nativeBuildInputs = [finalAttrs.finalPackage];
          } ''
            echo 'int main(){return 0;}' > test.c
            nvc -o test test.c
            ./test
            touch $out
          '';

        inherit
          (import ./tests.nix {
            lib = lib;
            stdenv = stdenv;
            runCommand = runCommand;
            writeShellScript = writeShellScript;
            nvidia-hpc-sdk = finalAttrs.finalPackage;
          })
          binaries-exist
          version-check
          environment-check
          ;

        inherit
          (import ./test-compile.nix {
            lib = lib;
            stdenv = stdenv;
            runCommand = runCommand;
            writeText = writeText;
            nvidia-hpc-sdk = finalAttrs.finalPackage;
          })
          c-compile
          cpp-compile
          fortran-compile
          openmp-test
          ;
      };

      updateScript = writeScript "update-nvidia-hpc-sdk" ''
        #!/usr/bin/env bash
        # Script to check for updates
        echo "Check https://developer.nvidia.com/hpc-sdk for new versions"
      '';
    };

    meta = with lib; {
      description = "NVIDIA HPC Software Development Kit v25.5 - Comprehensive suite of compilers, libraries and tools for HPC";

      longDescription = ''
              The NVIDIA HPC Software Development Kit (SDK) includes proven compilers, libraries and
              software tools essential to maximizing developer productivity and the performance and
              portability of HPC applications.

              Key Features:
              • C, C++, and Fortran compilers with GPU acceleration support
              • Standard C++17 parallel algorithms and OpenACC directives
              • CUDA programming support for NVIDIA GPUs
              • GPU-accelerated math libraries (cuBLAS, cuSOLVER, cuFFT, cuSPARSE)
              • Optimized for Tensor Cores and multi-GPU systems
              • Multi-GPU programming with NCCL and NVSHMEM
              • CUDA-aware MPI library based on Open MPI
              • Nsight Systems and Nsight Compute profiling tools
              • Container deployment support with HPC Container Maker
              • Support for x86-64 and Arm CPUs with Linux

              Used by popular HPC applications including VASP, Gaussian, ANSYS Fluent,
              GROMACS, and NAMD for dramatic performance improvements.

               LICENSING NOTICE:
        • NVIDIA HPC SDK components: Licensed under NVIDIA's proprietary license (unfree)
        • Qompass AI packaging, build scripts, and configuration: Dual-licensed under:
          - GNU AGPL v3.0 for non-commercial, open-source use
          - and the Qompass Commercial Distribution Agreement (Q-CDA) v1.0 for commercial use
      '';

      homepage = "https://developer.nvidia.com/hpc-sdk";
      downloadPage = "https://developer.nvidia.com/hpc-sdk-downloads";
      changelog = "https://docs.nvidia.com/hpc-sdk/archive/${version}/hpc-sdk-release-notes/index.html";

      license = with licenses; [
        unfree
        agpl3Only
        {
          fullName = "Qompass AI Commercial Distribution Agreement v1.0";
          shortName = "Q-CDA-1.0";
          spdxId = "Q-CDA-1.0";
          url = "https://github.com/qompassai/nur/blob/main/LICENSE-QCDA";
          free = false;
          redistributable = true;
        }
      ];

      sourceProvenance = with sourceTypes; [
        binaryNativeCode
        binaryBytecode
        fromSource
      ];
      mainProgram = "nvc";
      maintainers = [
        {
          github = "qompassai";
          githubId = 137334444;
          name = "Qompass AI";
        }
        maintainers.phaedrusflow
      ];
      platforms = ["x86_64-linux" "aarch64-linux"];
      outputsToInstall = ["out"];
      timeout = 7200;
      broken = false;
      badPlatforms = []; # None currently
      knownVulnerabilities = []; # None currently
      position = __curPos.file + ":" + toString __curPos.line;
    };
  })
