# /qompassai/nur/modules/services/sqool/default.nix
# ---------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.dev.distcc;
in {
  options.dev.distcc = {
    enable = mkEnableOption "Qompass AI distributed build service";
    hosts = mkOption {
      type = types.listOf types.str;
      default = [ "caffe" "doppio" "harbor" "pensare" ];
      description = "List of DistCC hostnames";
    };
    sshPort = mkOption {
      type = types.port;
      default = 2342;
      description = "SSH port for DistCC connections";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ distcc zig ];

    services.distccd.enable = true;
    
    home-manager.users.${config.user.name} = {
      home.sessionVariables = {
        DISTCC_DIR = "\${XDG_RUNTIME_DIR}/distcc";
        DISTCC_LOG = "\${XDG_STATE_HOME}/distcc/distcc.log";
        DISTCC_SSH = "ssh -p ${toString cfg.sshPort} -o ControlMaster=auto -o ControlPersist=10m -o ControlPath=\${XDG_RUNTIME_DIR}/ssh_mux_%h_%p_%r";
        DISTCC_POTENTIAL_HOSTS = concatStringsSep " " cfg.hosts;
      };
    };
  };
}

