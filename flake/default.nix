# /qompassai/dotfiles/flake/default.nix
# Qompass AI Nur Flake Defaults 
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ ... }:
{
  imports = [
    ./apps.nix
    ./checks.nix
    ./devshells.nix
    ./flake-modules.nix
    ./lib.nix
    ./nixos-modules.nix
    ./nixpkgs.nix
    ./overlays.nix
    ./packages.nix
    ./treefmt.nix
  ];
}
