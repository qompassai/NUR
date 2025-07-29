# dev-systems.nix
# Qompass AI Nur Dev Systems Flake Module
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    devSystems = lib.mkOption {
      type = with lib.types; listOf str;
      default = config.systems;
    };
    perSystem = mkPerSystemOption (
      { system, ... }:
      {
        _file = ./dev-systems.nix;
        options.isDevSystem = lib.mkOption {
          type = lib.types.bool;
          default = lib.elem system config.devSystems;
          readOnly = true;
        };
      }
    );
  };
}
