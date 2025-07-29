# devshells.nix
# Qompass AI Nur Devshells Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ ... }:
{
  perSystem =
    {
      self',
      lib,
      pkgs,
      ...
    }:
    let
      commandFor =
        p: args: lib.optional (self'.packages ? ${p}) ({ package = self'.packages.${p}; } // args);
    in
    {
      devshells.default = {
        devshell.name = "qompassai/nur";
        commands = [ { package = pkgs.cabal2nix; } ] ++ commandFor "devPackages/update" { };
      };
    };
}
