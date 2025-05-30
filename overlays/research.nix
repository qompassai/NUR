# /qompassai/nur-packages/overlays/research.nix
# Qompass AI Nix Research
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
final: prev: {
  ko = final.callPackage ../pkgs/ko {};
}
