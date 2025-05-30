# /qompassai/nur-packages/overlays/default.nix
# Qompass AI Nix overlays
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
final: prev:
(import ./ai.nix final prev)
// (import ./quantum.nix final prev)
// (import ./graphics.nix final prev)
// (import ./nautilus.nix final prev)
// (import ./nv-hpc.nix final prev)
// (import ./performance.nix final prev)
// (import ./research.nix final prev)
// (import ./quantum.nix final prev)
// (import ./services.nix final prev)
// {
  qompassai-tools = final.callPackage ../pkgs/qompassai-tools {};
  opencv-ai = prev.opencv4.override {
    enableGtk3 = true;
    enableFfmpeg = true;
    enableGstreamer = true;
    enableCuda = true;
    enableContrib = true;
  };
}
