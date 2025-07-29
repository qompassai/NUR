# /qompassai/nur/packages/qhash/flake.nix
# Qompass AI Q-Hash Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  description = "Qompass AI Q-Hash: collision-resistant hash utilities";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        qhash = pkgs.callPackage ./packages/qhash/default.nix { };
      in {
        packages = {
          qhash = qhash;
        };
        app = flake-utils.lib.mkApp { drv = qhash; exePath = "~/.local/bin/qhash"; };
        packages.default = qhash;
        apps.default = flake-utils.lib.mkApp { drv = qhash; exePath = "~/.local/bin/qhash"; };
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.coreutils pkgs.b3sum ];
          shellHook = ''
            echo "Qompass AI QHash Dev Shell"
            echo "Try: qhash blake3 <file>"
          '';
        };
      }
    );
}
