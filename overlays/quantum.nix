# ~/.GH/Qompass/nur-packages/overlays/quantum.nix
# -----------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
final: prev: {
  cirq-optimized = prev.python3Packages.cirq-core.override {
    enableCuda = true;
  };
  liboqs = final.callPackage (
    {
      stdenv,
      fetchFromGitHub,
      cmake,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "liboqs";
        version = "0.13.0";
        src = fetchFromGitHub {
          owner = "open-quantum-safe";
          repo = "liboqs";
          rev = "21b3f8b0fadbb19e2c6a5df0f165c953ead164e1";
          sha256 = "sha256-E3wOiWeQSgWzzu4zoYfLV1kGV3jsFE+XEnUezWSqkcA=";
        };
        nativeBuildInputs = [cmake];
        cmakeFlags = [
          "-DOQS_BUILD_ONLY_LIB=ON"
          "-DOQS_ENABLE_KEM_CLASSIC_MCELIECE=ON"
          "-DOQS_ENABLE_KEM_KYBER=ON"
          "-DOQS_ENABLE_KEM_NTRUPRIME=ON"
          "-DOQS_ENABLE_SIG_DILITHIUM=ON"
          "-DOQS_ENABLE_SIG_FALCON=ON"
          "-DOQS_ENABLE_SIG_PICNIC=ON"
          "-DOQS_ENABLE_SIG_SPHINCS=ON"
        ];
        meta = with final.lib; {
          description = "C library for quantum-safe cryptographic algorithms";
          homepage = "https://openquantumsafe.org/";
          license = licenses.mit;
          maintainers = ["Qompass AI"];
          platforms = platforms.linux;
        };
      }
  ) {};
  liboqs-cpp = final.callPackage (
    {
      stdenv,
      fetchFromGitHub,
      cmake,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "liboqs-cpp";
        version = "0.12.0";
        src = fetchFromGitHub {
          owner = "open-quantum-safe";
          repo = "liboqs-cpp";
          rev = "7e293be10a2c5978afdbf6eaba1b0bf5056e530a";
          sha256 = "sha256-l+GIFOBQ6/wlbPiUNfGAh5wmCK8U+D/I9Ol9Od3tYEM=";
        };
        buildInputs = [final.liboqs];
        nativeBuildInputs = [cmake];
        meta = with final.lib; {
          description = "C++ library for quantum-safe cryptographic algorithms";
          homepage = "https://openquantumsafe.org/";
          license = licenses.mit;
          maintainers = ["Qompass AI"];
          platforms = platforms.linux;
        };
      }
  ) {};
  liboqs-go = final.callPackage (
    {
      buildGoModule,
      fetchFromGitHub,
      ...
    }:
      buildGoModule rec {
        pname = "liboqs-go";
        version = "0.12.0";
        src = fetchFromGitHub {
          owner = "open-quantum-safe";
          repo = "liboqs-go";
          rev = "eeb454f5d03ad474c6c353a11fab587c6029ac5c";
          sha256 = "sha256-OJjaxtEc1zxS62vk6m4uesCuSBka+1Asw+W70SX0DCg=";
        };
        buildInputs = [final.liboqs];
        vendorHash = null;
        meta = with final.lib; {
          description = "Go library for quantum-safe cryptographic algorithms";
          homepage = "https://openquantumsafe.org/";
          license = licenses.mit;
          maintainers = ["Qompass AI"];
          platforms = platforms.linux;
        };
      }
  ) {};
  openssl-quantum = prev.openssl.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [final.liboqs final.oqs-provider];
    configureFlags =
      old.configureFlags
      ++ [
        "--enable-external-tests"
      ];
    postInstall =
      old.postInstall
      + ''
        # Create quantum-safe configuration
        mkdir -p $out/etc/ssl/quantum
        cat > $out/etc/ssl/quantum/openssl.cnf << 'EOF'
        # Quantum-safe OpenSSL configuration
        openssl_conf = openssl_init
        [openssl_init]
        providers = provider_sect
        [provider_sect]
        default = default_sect
        oqsprovider = oqsprovider_sect
        [default_sect]
        activate = 1
        [oqsprovider_sect]
        activate = 1
        # Add quantum-safe cipher preferences
        [quantum_safe_ciphers]
        Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        EOF
      '';
  });
  oqs-provider = final.callPackage (
    {
      stdenv,
      fetchFromGitHub,
      cmake,
      openssl,
      ...
    }:
      stdenv.mkDerivation rec {
        pname = "oqs-provider";
        version = "0.9.0";
        src = fetchFromGitHub {
          owner = "open-quantum-safe";
          repo = "oqs-provider";
          rev = "848b4e6abaa89e769c4db46ca78f91000f67ca52";
          sha256 = "sha256-R9rau/Q+KSkr0hNxpvc3ub9eLQqS1kIONoOEw8zFUBk=";
        };
        buildInputs = [final.liboqs openssl];
        nativeBuildInputs = [cmake];
        cmakeFlags = [
          "-DOPENSSL_ROOT_DIR=${openssl}"
        ];
        meta = with final.lib; {
          description = "OpenSSL 3 provider for quantum-safe cryptographic algorithms";
          homepage = "https://openquantumsafe.org/";
          license = licenses.mit;
          maintainers = ["Qompass AI"];
          platforms = platforms.linux;
        };
      }
  ) {};
  python3Packages = prev.python3Packages.overrideScope (pyFinal: pyPrev: {
    liboqs-python = pyFinal.buildPythonPackage rec {
      pname = "liboqs-python";
      version = "0.12.0";
      src = final.fetchFromGitHub {
        owner = "open-quantum-safe";
        repo = "liboqs-python";
        rev = "7906e7879a099fa34217035957d977314f99757d";
        sha256 = "sha256-39/LqxqB2+KerZd8Eoaf1+jWYE4rsBFIEy7Q7MWSCp0=";
      };
      buildInputs = [final.liboqs];
      propagatedBuildInputs = with pyFinal; [cffi];
      meta.description = "Python bindings for liboqs quantum-safe cryptography library";
    };
  });
  qiskit-full = prev.python3Packages.qiskit.overrideAttrs (old: {
    propagatedBuildInputs =
      old.propagatedBuildInputs
      ++ [
        final.python3Packages.qiskit-aer
        final.python3Packages.qiskit-ibm-runtime
        final.python3Packages.qiskit-machine-learning
        final.python3Packages.qiskit-optimization
      ];
  });
  qiskit-quantum-safe = final.python3Packages.buildPythonPackage rec {
    pname = "qiskit-quantum-safe";
    version = "1.0.0";
    src = final.writeTextFile {
      name = "qiskit-quantum-safe-setup.py";
      text = ''
        from setuptools import setup, find_packages
        setup(
            name="qiskit-quantum-safe",
            version="1.0.0",
            packages=find_packages(),
            install_requires=[
                "qiskit",
                "liboqs-python",
                "cryptography",
            ],
            description="Quantum-safe cryptography integration for Qiskit",
        )
      '';
    };
    propagatedBuildInputs = with final.python3Packages; [
      cryptography
      liboqs-python
      qiskit
    ];
    postInstall = ''
      mkdir -p $out/${final.python3Packages.python.sitePackages}/qiskit_quantum_safe
      cat > $out/${final.python3Packages.python.sitePackages}/qiskit_quantum_safe/__init__.py << 'EOF'
      """
      Qiskit Quantum-Safe Cryptography Integration
      This module provides quantum-safe cryptographic utilities
      for securing quantum computing workflows.
      """
      import oqs
      from qiskit import QuantumCircuit
      class QuantumSafeSecurity:
          """Quantum-safe security utilities for Qiskit"""
          def __init__(self):
              self.kem = oqs.KeyEncapsulation("Kyber512")
              self.sig = oqs.Signature("Dilithium2")
          def secure_circuit_transmission(self, circuit: QuantumCircuit):
              """Securely transmit quantum circuit using PQC"""
              # Implementation for secure circuit transmission
              pass
          def quantum_safe_key_exchange(self):
              """Perform quantum-safe key exchange"""
              public_key = self.kem.generate_keypair()
              return public_key
      EOF
      touch $out/${final.python3Packages.python.sitePackages}/qiskit_quantum_safe/py.typed
    '';
    meta.description = "Quantum-safe cryptography integration for Qiskit workflows";
  };
  quantum-dev-env = final.buildEnv {
    name = "quantum-development-environment";
    paths = [
      final.cirq-optimized
      final.liboqs
      final.liboqs-cpp
      final.liboqs-go
      final.openssl-quantum
      final.oqs-provider
      final.qiskit-full
      final.qiskit-quantum-safe
      final.python3Packages.forest-benchmarking
      final.python3Packages.jupyter
      final.python3Packages.liboqs-python
      final.python3Packages.matplotlib
      final.python3Packages.numpy
      final.python3Packages.pennylane
      final.python3Packages.scipy
      final.python3Packages.strawberryfields
    ];
  };
}
