# ~/.map/Nur/devenv.nix
# ---------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  config,
  lib,
  ...
}: {
  options = {
    programs.treefmt = {
      package = lib.mkOption {
        defaultText = lib.literalMD "package for running `treefmt` in devshell";
      };
    };
  };

  config = {
    packages = [
      config.programs.treefmt.package
    ];

    languages = {
      nix.enable = true;
      shell.enable = true;
    };
  };
}
