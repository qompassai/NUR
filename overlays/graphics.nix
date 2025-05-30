# ~/.GH/Qompass/nur-packages/overlays/graphics.nix
# ------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
final: prev: {
  mesa-full = prev.mesa.override {
    galliumDrivers = [
      "nouveau"
      "virgl"
      "svga"
      "swrast"
      "iris"
      "crocus"
      "radeonsi"
      "r300"
      "r600"
      "zink"
      "d3d12"
    ];
    vulkanDrivers = [
      "amd"
      "intel"
      "intel_hasvk"
      "nouveau"
      "swrast"
      "microsoft-experimental"
      "imagination-experimental"
    ];
    enableGalliumNine = true;
    enableOpenCL = true;
    enablePatentEncumberedCodecs = true;
    enableVulkanOverlay = true;
    vulkanLayers = ["device-select" "intel-nullhw" "overlay"];
  };
  vulkan-tools-enhanced = prev.vulkan-tools.overrideAttrs (old: {
    buildInputs =
      old.buildInputs
      ++ [
        final.vulkan-extension-layer
        final.vulkan-utility-libraries
      ];
  });
  vulkan-validation-layers-rt = prev.vulkan-validation-layers.overrideAttrs (old: {
    cmakeFlags =
      old.cmakeFlags
      ++ [
        "-DBUILD_LAYER_SUPPORT_FILES=ON"
        "-DVALIDATION_LAYERS_ENABLE_GPU_ASSISTED=ON"
        "-DVALIDATION_LAYERS_ENABLE_BEST_PRACTICES=ON"
      ];
  });
  vulkan-memory-allocator-enhanced = prev.vulkan-memory-allocator.overrideAttrs (old: {
    cmakeFlags =
      old.cmakeFlags
      ++ [
        "-DVMA_RECORDING_ENABLED=ON"
        "-DVMA_USE_STL_CONTAINERS=ON"
      ];
  });
  ffmpeg-rt = prev.ffmpeg.override {
    withNvenc = true;
    withNvdec = true;
    withVaapi = true;
    withVdpau = true;
    withCuda = true;
    withMfx = true;
    withAom = true;
    withSvtav1 = true;
    withRav1e = true;
    withVpl = true;
    withOpenh264 = true;
    withx264 = true;
    withx265 = true;
    withXvid = true;
    withVpx = true;
  };
  blender-rt = prev.blender.override {
    cudaSupport = true;
    colladaSupport = true;
    enableNumpy = true;
    enableOctane = true;
    enableCycles = true;
    enableOpenvdb = true;
    enableAlembic = true;
    enableUsd = true;
    enableEmbree = true;
    enableOpenImageDenoise = true; #
    enableOptiX = true;
  };
  optix-enhanced = final.callPackage (
    {
      stdenv,
      fetchurl,
      autoPatchelfHook,
      makeWrapper,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "optix-enhanced";
        version = "9.0.0";
        src = fetchurl {
          url = "https://developer.nvidia.com/downloads/designworks/optix/secure/9.0.0/NVIDIA-OptiX-SDK-9.0.0-linux64-x86_64.sh";
          sha256 = "162am1b1hsv39ziyq27bqv4f43gi14rb1vkg8lnmx2zv296v09an";
        };
        buildInputs = [
          final.cudatoolkit
          final.vulkan-loader
          final.vulkan-validation-layers-rt
        ];
        nativeBuildInputs = [autoPatchelfHook makeWrapper];
        installPhase = ''
          mkdir -p $out
          cp -r include $out/
          cp -r lib64 $out/lib
          cp -r SDK $out/
          # Create wrapper for Unreal Engine integration
          makeWrapper $out/SDK/bin/OptiXRenderScript $out/bin/optix-render \
            --prefix LD_LIBRARY_PATH : $out/lib
        '';
      }
  ) {};
  embree-optimized = prev.embree.override {
    enableTBB = true;
    enableISPC = true;
    enableTutorials = true;
    enableGlfw = true;
  };
  oidn-enhanced = prev.oidn.overrideAttrs (old: {
    cmakeFlags =
      old.cmakeFlags
      ++ [
        "-DOIDN_DEVICE_CUDA=ON"
        "-DOIDN_DEVICE_HIP=ON"
        "-DOIDN_DEVICE_METAL=ON"
      ];
  });
  shaderc-rt = prev.shaderc.overrideAttrs (old: {
    cmakeFlags =
      old.cmakeFlags
      ++ [
        "-DSHADERC_ENABLE_WERROR_COMPILE=OFF"
        "-DSHADERC_ENABLE_SHARED_CRT=ON"
      ];
  });
  spirv-tools-enhanced = prev.spirv-tools.overrideAttrs (old: {
    cmakeFlags =
      old.cmakeFlags
      ++ [
        "-DSPIRV_WERROR=OFF"
        "-DSPIRV_BUILD_COMPRESSION=ON"
        "-DSPIRV_BUILD_FUZZER=ON"
      ];
  });
  usd-rt = final.callPackage (
    {
      boost,
      cmake,
      fetchFromGitHub,
      stdenv,
      python3,
      tbb,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "usd-rt";
        version = "25.05.01";
        src = fetchFromGitHub {
          owner = "PixarAnimationStudios";
          repo = "OpenUSD";
          rev = "v${version}";
          sha256 = "1d27lawx0l1sfy6a0jd5f2cxabxmb0jv14c6h4hkka8c5q8a8643";
        };
        buildInputs = [
          boost
          tbb
          python3
          final.embree-optimized
          final.optix-enhanced
        ];
        nativeBuildInputs = [cmake];
        cmakeFlags = [
          "-DPXR_BUILD_EMBREE_PLUGIN=ON"
          "-DPXR_ENABLE_OPTIX_SUPPORT=ON"
          "-DPXR_BUILD_IMAGING=ON"
          "-DPXR_BUILD_USD_IMAGING=ON"
          "-DPXR_BUILD_USDVIEW=ON"
          "-DPXR_BUILD_ALEMBIC_PLUGIN=ON"
          "-DPXR_BUILD_DRACO_PLUGIN=ON"
          "-DPXR_BUILD_MATERIALX_PLUGIN=ON"
        ];
      }
  ) {};

  cudatoolkit-rt = prev.cudatoolkit.overrideAttrs (old: {
    propagatedBuildInputs =
      old.propagatedBuildInputs
      ++ [
        final.optix-enhanced
      ];
  });
  dxc-enhanced = final.callPackage (
    {
      cmake,
      fetchFromGitHub,
      stdenv,
      python3,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "dxc-enhanced";
        version = "1.8.2502";
        src = fetchFromGitHub {
          owner = "microsoft";
          repo = "DirectXShaderCompiler";
          rev = "v${version}";
          sha256 = "0w54mkma7ghrz7cm2fsnj6xg7c0dqjjq4majg0cfds17h0i6f0k1";
        };
        nativeBuildInputs = [cmake python3];
        cmakeFlags = [
          "-DENABLE_SPIRV_CODEGEN=ON"
          "-DSPIRV_BUILD_TESTS=OFF"
          "-DHLSL_ENABLE_ANALYZE=ON"
        ];
      }
  ) {};
  libgl-rt = prev.libGL.overrideAttrs (old: {
    configureFlags =
      old.configureFlags
      ++ [
        "--enable-glx-tls"
        "--enable-dri3"
        "--enable-gallium-llvm"
      ];
  });
  glfw-rt = prev.glfw.override {
    enableWayland = true;
    enableX11 = true;
  };
  opencl-rt =
    prev.ocl-icd.overrideAttrs (old: {
    });
  rt-dev-suite = final.buildEnv {
    name = "ray-tracing-dev-suite";
    paths = [
      final.vulkan-tools-enhanced
      final.vulkan-validation-layers-rt
      final.vulkan-memory-allocator-enhanced
      final.shaderc-rt
      final.spirv-tools-enhanced
      final.embree-optimized
      final.oidn-enhanced
      final.optix-enhanced
      final.usd-rt
      final.dxc-enhanced
      final.cudatoolkit-rt
    ];
  };
  unreal-dev-env = final.buildEnv {
    name = "unreal-engine-dev-env";
    paths = [
      final.mesa-full
      final.vulkan-tools-enhanced
      final.vulkan-validation-layers-rt
      final.ffmpeg-rt
      final.blender-rt
      final.rt-dev-suite
      final.usd-rt
      final.glfw-rt
      final.cmake
      final.ninja
      final.clang
      final.lld
      final.python3
      final.nodejs
      final.renderdoc
      final.gputrace
    ];
  };
}
