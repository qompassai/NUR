# ~/.GH/Qompass/Nur/packages/pkgs/nvidia-hpc-sdk/shell.nix
# --------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
# shell.nix
let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
in
  pkgs.callPackage ./default.nix {}
