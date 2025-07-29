# /qompassai/dotfiles/flake/checks.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ self, inputs, ... }:
{
  perSystem =
    {
      config,
      system,
      self',
      pkgs,
      lib,
      ...
    }:
    let
      pkgsStable = import inputs.nixos-stable config.nixpkgs;
    in
    {
      checks = inputs.flake-utils.lib.flattenTree {
        packages = lib.recurseIntoAttrs self'.legacyPackages;
        packages-stable = lib.recurseIntoAttrs (
          self.lib.makePackages pkgsStable ../pkgs { selfLib = self.lib; }
        );
        devShells = lib.recurseIntoAttrs self'.devShells;
      };
    };
}
