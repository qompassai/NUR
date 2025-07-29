# /qompassai/dotfiles/flake/apps.nix
# Qompass AI Dotfiles Apps Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ self, ... }:
{
  perSystem =
    { self', ... }:
    {
      apps = self.lib.makeApps self'.packages self.lib.appNames;
    };
}
