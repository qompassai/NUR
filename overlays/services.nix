# ~/.GH/Qompass/nur-packages/overlays/services.nix
# ------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
final: prev: {
  postgresql-ai = prev.postgresql.override {
    enableSystemd = true;
    gssSupport = true;
    ldapSupport = true;
    jitSupport = true;
    systemdSupport = true;
    icuSupport = true;
    llvmPackages = final.llvm;
  };
  mariadb-ai = prev.mariadb.override {
    enableSystemd = true;
    mysqlSupport = true;
    embedSupport = true;
    extraOptions = [
      "--with-embedded-server"
      "--enable-thread-safe-client"
      "--with-ssl=${final.openssl-pqc}"
    ];
  };
  redis-ai = prev.redis.overrideAttrs (old: {
    buildInputs =
      old.buildInputs
      ++ [
        final.openssl-pqc
        final.jemalloc
      ];
    configureFlags =
      old.configureFlags
      ++ [
        "--enable-tls"
        "--with-jemalloc"
        "--enable-systemd"
      ];
    postInstall =
      old.postInstall
      + ''
        mkdir -p $out/etc/redis/modules
        cat > $out/etc/redis/ai-modules.conf << EOF
        loadmodule $out/lib/redismodules/redistimeseries.so
        loadmodule $out/lib/redismodules/redisgraph.so
        loadmodule $out/lib/redismodules/redisai.so
        EOF
      '';
  });
  valkey = final.callPackage (
    {
      stdenv,
      fetchFromGitHub,
      openssl,
      systemd,
      pkg-config,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "valkey";
        version = "8.1.1";
        src = fetchFromGitHub {
          owner = "valkey-io";
          repo = "valkey";
          rev = "fcd8bc3ee40f5d7841b7d5a8f3cd12252fec14e4";
          sha256 = "sha256-C0Xp2+1w2J3pHqkNIi9p+AEDjPNwkmopDfAgGNSdrNg=";
        };
        nativeBuildInputs = [pkg-config];
        buildInputs = [openssl systemd];
        makeFlags = [
          "USE_SYSTEMD=yes"
          "BUILD_TLS=yes"
          "PREFIX=${placeholder "out"}"
        ];
        installPhase = ''
          runHook preInstall
          make install PREFIX=$out
          runHook postInstall
        '';
        meta = with final.lib; {
          description = "High-performance key-value store (Redis fork)";
          homepage = "https://valkey.io/";
          license = licenses.bsd3;
          platforms = platforms.linux;
          maintainers = ["Qompass AI"];
        };
      }
  ) {};
  prometheus-ai = prev.prometheus.override {
    buildGoModule = args:
      prev.buildGoModule (args
        // {
          postInstall = ''
            # Add AI-specific exporters
            mkdir -p $out/bin/exporters

            # GPU exporter for NVIDIA monitoring
            cat > $out/bin/exporters/nvidia_gpu_exporter << 'EOF'
            #!/bin/sh
            # NVIDIA GPU metrics exporter for Prometheus
            nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.used,memory.free,power.draw --format=csv,noheader,nounits | while IFS=, read -r index name temp gpu_util mem_util mem_total mem_used mem_free power; do
              echo "nvidia_gpu_temperature{gpu=\"$index\",name=\"$name\"} $temp"
              echo "nvidia_gpu_utilization{gpu=\"$index\",name=\"$name\"} $gpu_util"
              echo "nvidia_gpu_memory_utilization{gpu=\"$index\",name=\"$name\"} $mem_util"
              echo "nvidia_gpu_memory_total{gpu=\"$index\",name=\"$name\"} $mem_total"
              echo "nvidia_gpu_memory_used{gpu=\"$index\",name=\"$name\"} $mem_used"
              echo "nvidia_gpu_memory_free{gpu=\"$index\",name=\"$name\"} $mem_free"
              echo "nvidia_gpu_power_draw{gpu=\"$index\",name=\"$name\"} $power"
            done
            EOF
            chmod +x $out/bin/exporters/nvidia_gpu_exporter
            cat > $out/bin/exporters/intel_gpu_exporter << 'EOF'
            #!/bin/sh
            # Intel GPU metrics exporter for Prometheus
            intel_gpu_top -s 1000 -c 1 | grep -E "GPU|MEM" | while read line; do
              if echo "$line" | grep -q "GPU"; then
                gpu_util=$(echo "$line" | grep -o '[0-9]*%' | head -1 | tr -d '%')
                echo "intel_gpu_utilization $gpu_util"
              fi
            done
            EOF
            chmod +x $out/bin/exporters/intel_gpu_exporter
          '';
        });
  };
  ai-services-bundle = final.buildEnv {
    name = "ai-services-bundle";
    paths = [
      final.postgresql-ai
      final.mariadb-ai
      final.redis-ai
      final.valkey
      final.prometheus-ai
    ];
  };
}
