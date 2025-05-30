# ~/.config/nixpkgs/config.nix
# ----------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
      inherit pkgs;
    };
  };
}
