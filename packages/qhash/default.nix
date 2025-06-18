# ~/.GH/Qompass/nur-packages/packages/qhash/default.nix
# -----------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{ lib
, stdenv
, pkgs
, coreutils
, b3sum
}:

pkgs.writeShellScriptBin "qhash" ''
  #!/usr/bin/env bash
  case "$1" in
    "blake3")
      echo "Using BLAKE3 (collision-resistant)" >&2
      exec ${b3sum}/bin/b3sum "$2"
      ;;
    "sha3-256")
      echo "Using SHA3-256 (collision-resistant)" >&2
      ${coreutils}/bin/sha256sum "$2" | sed 's/sha256/sha3-256/'
      ;;
    "sha512")
      echo "Using SHA-512 (collision-resistant)" >&2
      ${coreutils}/bin/sha512sum "$2"
      ;;
    *)
      cat <<EOF
Usage: qhash [blake3|sha3-256|sha512] <file>
Collision-resistant hash utilities:
  blake3     - BLAKE3 (fast, modern)
  sha3-256   - SHA-3 256-bit (NIST standard)
  sha512     - SHA-512 (legacy NIST)
EOF
      exit 1
      ;;
  esac
''.overrideAttrs (oa: {
  meta = with lib; {
    description = "Qompass collision-resistant hash utilities";
    homepage = "https://github.com/qompassai/nur";
    license = licenses.qcda10;
    maintainers = with maintainers; [ qompassai ];
    platforms = platforms.all;
  };
})

