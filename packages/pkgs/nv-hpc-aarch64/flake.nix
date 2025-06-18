# ~/.map/Nur/packages/pkgs/nv-hpc-aarch64/flake.nix
# -------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  description = "NVIDIA HPC SDK - aarch64 build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, flake-utils, systems, ... }:
    flake-utils.lib.eachSystem ["aarch64-linux"] (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      packages = {
        nvidia-hpc-sdk = pkgs.callPackage ./default.nix {};
        default = self.packages.${system}.nvidia-hpc-sdk;
      };

      apps = {
        nvc = {
          type = "app";
          program = "${self.packages.${system}.nvidia-hpc-sdk}/bin/nvc";
        };
        "nvc++" = {
          type = "app";
          program = "${self.packages.${system}.nvidia-hpc-sdk}/bin/nvc++";
        };
        nvcc = {
          type = "app";
          program = "${self.packages.${system}.nvidia-hpc-sdk}/bin/nvcc";
        };
        nvfortran = {
          type = "app";
          program = "${self.packages.${system}.nvidia-hpc-sdk}/bin/nvfortran";
        };
        pgcc = {
          type = "app";
          program = "${self.packages.${system}.nvidia-hpc-sdk}/bin/pgcc";
        };
        mpicc = {
          type = "app";
          program = "${self.packages.${system}.nvidia-hpc-sdk}/bin/mpicc";
        };
        default = self.apps.${system}.nvc;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [self.packages.${system}.nvidia-hpc-sdk];
        packages = with pkgs; [cmake pkg-config git];
        shellHook = ''
          echo "NVIDIA HPC SDK development environment"
          echo "Available compilers: nvc, nvc++, nvfortran, nvcc"
          echo "NVHPC_ROOT: ${self.packages.${system}.nvidia-hpc-sdk}"
        '';
      };

      checks = {
        nvidia-hpc-sdk-test =
          pkgs.runCommand "nvidia-hpc-sdk-test" {
            nativeBuildInputs = [self.packages.${system}.nvidia-hpc-sdk];
          } ''
            test -x ${self.packages.${system}.nvidia-hpc-sdk}/bin/nvc
            test -x ${self.packages.${system}.nvidia-hpc-sdk}/bin/nvcc
            touch $out
          '';
      };

      formatter = pkgs.alejandra;
    })
    // {
      overlays.default = final: prev: {
        nvidia-hpc-sdk = final.callPackage ./default.nix {};
      };

      templates = {
        cuda-project = {
          path = ./templates/cuda-project;
          description = "Basic CUDA project template using NVIDIA HPC SDK";
        };
        fortran-project = {
          path = ./templates/fortran-project;
          description = "Modern Fortran project template";
        };
        default = self.templates.cuda-project;
      };

      nixosModules = {
        nvidia-hpc-sdk = {
          config,
          lib,
          pkgs,
          ...
        }:
          with lib; {
            options.programs.nvidia-hpc-sdk = {
              enable = mkEnableOption "NVIDIA HPC SDK";
              package = mkOption {
                type = types.package;
                default = self.packages.${pkgs.system}.nvidia-hpc-sdk;
                description = "The NVIDIA HPC SDK package to use";
              };
            };

            config = mkIf config.programs.nvidia-hpc-sdk.enable {
              environment.systemPackages = [config.programs.nvidia-hpc-sdk.package];
              environment.variables = {
                NVHPC_ROOT = "${config.programs.nvidia-hpc-sdk.package}";
                CUDA_ROOT = "${config.programs.nvidia-hpc-sdk.package}/cuda";
              };
            };
          };
        default = self.nixosModules.nvidia-hpc-sdk;
      };
    };
}

