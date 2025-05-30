# /qompassai/nur-packages/packages/qjp/default.nix
# Qompass AI Fork of Anduril Jetpack-NixOS
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  ...
}:
stdenv.mkDerivation rec {
  pname = "qjp";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "qompassai";
    repo = "qjp";
    rev = "02a8e69c3a1e730499c84ea8cf9ac54628eddf06";
    sha256 = "sha256-NwFg/JSScu81F5/3mU9R4dOrv5VkN1LYp1ew2DsABwM=";
  };
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
        mkdir -p $out/share/qjp

        cp -r anduril $out/share/qjp/
        cp -r device-pkgs $out/share/qjp/
        cp -r kernel $out/share/qjp/
        cp -r modules $out/share/qjp/
        cp -r pkgs $out/share/qjp/
        cp -r sourceinfo $out/share/qjp/
        cp overlay.nix $out/share/qjp/
        cp overlay-with-config.nix $out/share/qjp/
        cp flake.nix $out/share/qjp/
        cp flake.lock $out/share/qjp/
        cp README.md $out/share/qjp/
        cp citation.bib $out/share/qjp/
        cp CITATION.cff $out/share/qjp/
        cp qompass.jpg $out/share/qjp/
        cp LICENSE-AGPL $out/share/qjp/
        cp LICENSE-QCDA $out/share/qjp/
        mkdir -p $out/bin
        cat > $out/bin/qjp-load-overlay << 'EOF'
    #!/bin/sh
    # Load QJP Jetpack overlay
    export QJP_OVERLAY_PATH="$out/share/qjp/overlay.nix"
    echo "QJP Jetpack overlay available at: $QJP_OVERLAY_PATH"
    echo "Usage: nixpkgs.overlays = [ (import $QJP_OVERLAY_PATH) ];"
    EOF
        chmod +x $out/bin/qjp-load-overlay
        cat > $out/bin/qjp-flake-info << 'EOF'
    #!/bin/sh
    # QJP Flake information
    echo "QJP Jetpack Flake location: $out/share/qjp/"
    echo "Usage: nix develop $out/share/qjp/"
    echo "Or add to flake.nix inputs:"
    echo "  qjp.url = \"path:$out/share/qjp\";"
    EOF
        chmod +x $out/bin/qjp-flake-info
        # QJP module loader script
        cat > $out/bin/qjp-modules << 'EOF'
    #!/bin/sh
    echo "Available QJP NixOS modules:"
    find $out/share/qjp/modules -name "*.nix" -type f | while read module; do
      basename=$(basename "$module" .nix)
      echo "  - $basename: $module"
    done
    echo ""
    echo "Usage in configuration.nix:"
    echo "  imports = [ $out/share/qjp/modules/MODULE_NAME.nix ];"
    EOF
        chmod +x $out/bin/qjp-modules
        cat > $out/bin/qjp-packages << 'EOF'
    #!/bin/sh
    echo "Available QJP package categories:"
    find $out/share/qjp/pkgs -maxdepth 1 -type d | while read dir; do
      if [ "$dir" != "$out/share/qjp/pkgs" ]; then
        category=$(basename "$dir")
        echo "  - $category/"
        find "$dir" -name "default.nix" | head -3 | while read pkg; do
          echo "    └── $(dirname "$pkg" | xargs basename)"
        done
      fi
    done
    EOF
        chmod +x $out/bin/qjp-packages
  '';
  passthru = {
    overlay = "${placeholder "out"}/share/qjp/overlay.nix";
    overlayWithConfig = "${placeholder "out"}/share/qjp/overlay-with-config.nix";
    modules = "${placeholder "out"}/share/qjp/modules";
    packages = "${placeholder "out"}/share/qjp/pkgs";
    flake = "${placeholder "out"}/share/qjp/flake.nix";
  };
  meta = with lib; {
    description = "Qompass AI NVIDIA Jetpack NixOS (QJP) - Enhanced Anduril fork";
    longDescription = ''
      Comprehensive NVIDIA Jetpack support for NixOS, enhanced by Qompass AI.
      Based on Anduril Industries' jetpack-nixos with quantum computing optimizations.
      Includes:
      - Device packages for various Jetson boards
      - Kernel patches and configurations
      - NixOS modules for Jetpack services
      - CUDA packages and tools
      - Flash utilities and OTA tools
      - Benchmarking and testing tools
    '';
    homepage = "https://github.com/qompassai/jetpack-nixos";
    license = [
      licenses.asl20 
      licenses.agpl3Plus
      {
      shortName = "Q-CDA-1.0";
      fullName = "Qompass Commercial Distribution Agreement 1.0";
      url = "https://github.com/qompassai/jpq/blob/main/LICENSE-QCDA";
      free = false;
      redistributable = true;
    };
  ];
    ];
    maintainers = ["Qompass AI"];
    platforms = platforms.linux;
    broken = false;
  };
}
