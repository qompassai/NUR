# /qompassai/nur-packages/flake.nix
# Qompass AI NUR Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  description = "Qompass AI NUR packages - Deep Tech packages for quantum AI, HPC, and research";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      nur-packages = import ./default.nix {inherit pkgs;};
    in {
      packages = {
        default = nur-packages.packages.qjp;
        inherit
          (nur-packages.packages)
          qhash
          qjp
          qrage
          qsec
          ko
          nvidia-hpc-sdk
          ;
      };
      legacyPackages = nur-packages.packages;

      # Development shell
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nix-build-uncached
          nix-update
          nixpkgs-fmt
          nixpkgs-review
          nix-tree
        ];
        shellHook = ''
          echo "🔬 Qompass AI NUR Development Environment"
          echo "Available packages: qhash, qjp, qrage, qsec, ko, nvidia-hpc-sdk"
          echo "Available overlays: ai, graphics, quantum, research, etc."
          echo ""
          echo "Commands:"
          echo "  nix build .#qjp          - Build QJP package"
          echo "  nix build .#qhash         - Build QHash package"
          echo "  nixpkgs-review wip        - Review packages"
          echo "  nix flake check           - Check flake validity"
        '';
      };
      checks = {
        packages-build =
          pkgs.linkFarmFromDrvs "packages"
          (builtins.attrValues self.packages.${system});
      };
    })
    // {
      overlays = {
        default = import ./overlays;
        ai = import ./overlays/ai.nix;
        graphics = import ./overlays/graphics.nix;
        nv-hpc = import ./overlays/nv-hpc.nix;
        pentest = import ./overlays/pentest.nix;
        performance = import ./overlays/performance.nix;
        quantum = import ./overlays/quantum.nix;
        research = import ./overlays/research.nix;
        services = import ./overlays/services.nix;
      };
      nixosModules = {
        default = import ./modules;
        apps-browser = import ./modules/apps/browser.nix;
        apps-media = import ./modules/apps/media.nix;
        apps-pro = import ./modules/apps/pro.nix;
        apps-zoom = import ./modules/apps/zoom.nix;
        boot = import ./modules/boot/boot.nix;
        boot-common = import ./modules/boot/common.nix;
        boot-ntp = import ./modules/boot/ntp.nix;
        boot-kernel = import ./modules/boot/kernel.nix;
        modprobe = import ./modules/boot/modprobe.nix;
        hardware-amd = import ./modules/hardware/amd.nix;
        hardware-intel = import ./modules/hardware/intel.nix;
        hardware-nvidia = import ./modules/hardware/nvidia.nix;
        hardware-nv-prime = import ./modules/hardware/nv-prime.nix;
        services-network = import ./modules/services/network.nix;
        services-vm = import ./modules/services/vm.nix;
        hyprland = import ./modules/xdg/hyprland;
        dev-c = import ./modules/dev/c.nix;
        dev-cpp = import ./modules/dev/cpp.nix;
        dev-dotnet = import ./modules/dev/dotnet.nix;
        dev-git = import ./modules/dev/git.nix;
        dev-go = import ./modules/dev/go.nix;
        dev-haskell = import ./modules/dev/haskell.nix;
        dev-jj = import ./modules/dev/jj.nix;
        dev-julia = import ./modules/dev/julia.nix;
        dev-lang = import ./modules/dev/lang.nix;
        dev-lua = import ./modules/dev/lua.nix;
        dev-mojo = import ./modules/dev/mojo.nix;
        dev-ocaml = import ./modules/dev/ocaml.nix;
        dev-perl = import ./modules/dev/perl.nix;
        dev-php = import ./modules/dev/php.nix;
        dev-python = import ./modules/dev/python.nix;
        dev-rust = import ./modules/dev/rust.nix;
        dev-scala = import ./modules/dev/scala.nix;
        dev-ts = import ./modules/dev/ts.nix;
        dev-zig = import ./modules/dev/zig.nix;
      };

      lib = import ./lib;

      templates = {
        default = {
          path = ./templates;
          description = "Qompass AI package template";
        };
      };

      formatter = flake-utils.lib.eachDefaultSystem (
        system:
          nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}
