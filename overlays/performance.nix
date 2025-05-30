# ~/.GH/Qompass/nur-packages/overlays/performance.nix
# ---------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
final: prev: {
  linux-performance = prev.linux_latest.override {
    kernelPatches =
      prev.linux_latest.kernelPatches
      ++ [
      ];
    extraConfig = ''
      PREEMPT_VOLUNTARY y
      CC_OPTIMIZE_FOR_PERFORMANCE y
      CPU_FREQ_DEFAULT_GOV_PERFORMANCE y
    '';
  };
  gcc-optimized = prev.gcc.override {
    extraConfigureFlags = ["--with-cpu=native" "--with-tune=native"];
  };
  llvm-full = prev.llvm.override {
    enableSharedLibraries = true;
    enablePIC = true;
  };
}
