# /qompassai/nur/flake.nix
# Qompass AI NUR Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  description = "Qompass AI NUR packages - Deep Tech packages for quantum AI, HPC, and research";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });

    packages = forAllSystems (
      system:
        self.legacyPackages.${system}.packages
    );

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
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
          '';
        };
      }
    );

    formatter = forAllSystems (
      system:
        (import nixpkgs {inherit system;}).nixpkgs-fmt
    );

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
      boot-kernel = import ./modules/boot/kernel.nix;
      boot-ntp = import ./modules/boot/ntp.nix;
      boot-modprobe = import ./modules/boot/modprobe.nix;
      hardware = import ./modules/hardware/hardware.nix;
      hardware-amd = import ./modules/hardware/amd.nix;
      hardware-intel = import ./modules/hardware/intel.nix;
      hardware-nvidia = import ./modules/hardware/nvidia.nix;
      hardware-nv-prime = import ./modules/hardware/nv-prime.nix;
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
      services-network = import ./modules/services/network.nix;
      services-vm = import ./modules/services/vm.nix;
      xdg-hyprland = import ./modules/xdg/hyprland;
    };

    lib = import ./lib;

    templates = {
      default = {
        path = ./templates;
        description = "Qompass AI package template";
      };
      lua-ai = {
        path = ./templates/lang/lua;
        description = "Qompass AI Lua template with OpenResty LuaJIT";
      };
    };
  };
}
