let
  pkgs = import <nixpkgs> {};
in
  pkgs.callPackage ({
    autoPatchelfHook,
    binutils,
    buildFHSUserEnv,
    dbus,
    fetchurl,
    fontconfig,
    gcc,
    glib,
    glibc,
    gmp,
    lib,
    libGL,
    libtiff,
    libxcrypt,
    libxkbcommon,
    libxml2,
    makeWrapper,
    ncurses,
    perl,
    python3,
    rdma-core,
    stdenv,
    wayland,
    which,
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
    stdenv.mkDerivation rec {
      pname = "nvidia-hpc-sdk";
      version = "25.5";

      src = fetchurl sourceInfo;

      autoPatchelfIgnoreMissingDeps = [
        "libdbus-1.so.3"
        "libfontconfig.so.1"
        "libglib-2.0.so.0"
        "libGLX.so.0"
        "libgthread-2.0.so.0"
        "libibmad.so.5"
        "libibumad.so.3"
        "libibverbs.so.1"
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
      ];

      buildInputs = [
        binutils
        dbus
        fontconfig
        gcc
        glibc
        glib
        gmp
        libGL
        libICE
        nss
        nspr
        libdrm
        libxkbfile
        libxshmfence
        libtiff
        libxcrypt
        libxkbcommon
        libxml2
        ncurses
        perl
        python3
        rdma-core
        wayland
        which
        xorg.libX11
        xorg.libxcb
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXfixes
        xorg.libXrender
        xorg.libXrandr
        xorg.libXtst
        xorg.libXi
        xorg.xcbutilcursor
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil
        xorg.xcbutil
        zlib
      ];

      dontBuild = true;
      dontConfigure = true;

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
        # fhsEnv  # Only needed if using installer
      ];

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        mkdir -p $out

        cd "${platformDir}"

        if [ -d "install_components/Linux_x86_64/${version}" ]; then
          echo "Copying HPC SDK installation directly..."
          cp -r install_components/Linux_x86_64/${version}/* $out/
        else
          echo "Fallback: copying all files..."
          cp -r * $out/
        fi

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

      meta = with lib; {
        description = "NVIDIA HPC Software Development Kit v25.5";
        homepage = "https://developer.nvidia.com/hpc-sdk";
        license = licenses.unfree;
        maintainers = with maintainers; [];
        platforms = ["x86_64-linux" "aarch64-linux"];
      };
    }) {}
