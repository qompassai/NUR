# ~/.GH/Qompass/nur-packages/packages/qsec/default.nix
# ----------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  pkgs,
  lib,
}: let
  openssl350 = pkgs.openssl_3_5 or pkgs.openssl_3;
in
  pkgs.writeShellScriptBin "network-security-check" ''
    #!/usr/bin/env bash
    echo "🔍 Network Security Configuration Check"
    echo "======================================"

    # Check NetworkManager
    if systemctl is-active NetworkManager >/dev/null 2>&1; then
      echo "✅ NetworkManager: Active"
    else
      echo "❌ NetworkManager: Inactive"
    fi

    # Check unbound
    if systemctl is-active unbound >/dev/null 2>&1; then
      echo "✅ Unbound DNS: Active"
    else
      echo "❌ Unbound DNS: Inactive"
    fi

    # Check DNS resolution
    if ${pkgs.dig}/bin/dig @127.0.0.1 google.com >/dev/null 2>&1; then
      echo "✅ DNS Resolution: Working"
    else
      echo "❌ DNS Resolution: Failed"
    fi

    # Check OpenSSL version
    echo "🔐 OpenSSL: $(${openssl350}/bin/openssl version)"

    # Check encryption tools
    echo "🔨 BLAKE3: $(${pkgs.b3sum}/bin/b3sum --version)"
    echo "🎯 Rage: $(${pkgs.rage}/bin/rage --version)"
  ''
