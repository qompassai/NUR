{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  pname = "ko";
  version = "032025";

  src = fetchFromGitHub {
    owner = "qompassai";
    repo = "KO";
    rev = "6a0f5bd8c73f83b4e883a3140cd78782a3d1efae";
    sha256 = "sha256-1IVhrsCArL8kE3dPi1pN26VR4lPoVzA/Q4XA0wSS8YE=";
  };
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
        mkdir -p $out/share/ko
        cp -r background $out/share/ko/
        cp -r methods $out/share/ko/
        cp -r results $out/share/ko/
        cp -r scripts $out/share/ko/
        cp README.md $out/share/ko/
        cp citation.bib $out/share/ko/
        cp CITATION.cff $out/share/ko/
        cp LICENSE* $out/share/ko/
        cp *.pdf $out/share/ko/ 2>/dev/null || true
        cp *.jpg $out/share/ko/ 2>/dev/null || true
        cp -r liboqs-* $out/share/ko/ 2>/dev/null || true
        cp -r oqs-provider* $out/share/ko/ 2>/dev/null || true
        cp -r ossl-* $out/share/ko/ 2>/dev/null || true
        cp -r QompassL-* $out/share/ko/ 2>/dev/null || true
        cp -r qompassl-* $out/share/ko/ 2>/dev/null || true
        if [ -d scripts ]; then
          mkdir -p $out/bin
          find scripts -type f -executable -exec cp {} $out/bin/ \;
        fi
        mkdir -p $out/bin
        cat > $out/bin/ko-info << 'EOF'
    #!/bin/sh
    echo "KO Research Project - Quantum-Safe Cryptography Research"
    echo "Documentation location: $out/share/ko"
    echo "Available components:"
    ls -la $out/share/ko/
    EOF
        chmod +x $out/bin/ko-info
  '';

  meta = with lib; {
    description = "KO - Quantum-Safe Cryptography Research Project by Qompass AI";
    homepage = "https://github.com/qompassai/KO";
    license = licenses.agpl3Plus;
    maintainers = ["Qompass AI"];
    platforms = platforms.all;
  };
}
