# /qompassai/nur/flake.nix
# Qompass AI NUR Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
#####################################################
{
  description = "Qompass AI Nix User (NUR) Repository";
  inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    qjp.url = "github:qompassai/QJP";
    qjp.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule

        ./flake
      ];
    };
}
