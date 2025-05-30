# ~/.GH/Qompass/nur-packages/packages/qrage/default.nix
# -----------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  pkgs,
  lib,
}:
pkgs.writeShellScriptBin "qrage" ''
  #!/usr/bin/env bash
  set -euo pipefail

  KEYS_DIR="$HOME/.config/rage"
  mkdir -p "$KEYS_DIR"
  chmod 700 "$KEYS_DIR"

  if [[ ! -f "$KEYS_DIR/key.txt" ]]; then
    echo "🔑 Generating new rage key..."
    ${pkgs.rage}/bin/rage-keygen -o "$KEYS_DIR/key.txt"
    chmod 600 "$KEYS_DIR/key.txt"
    echo "✅ Rage key generated at $KEYS_DIR/key.txt"
  else
    echo "✅ Rage key already exists at $KEYS_DIR/key.txt"
  fi
  echo "📋 Your public key:"
  ${pkgs.rage}/bin/rage-keygen -y "$KEYS_DIR/key.txt"
''
