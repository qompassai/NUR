# ~/.map/Nur/helpers/meta.nix
# ---------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
# Helper function for generating comprehensive metadata
let
  makeQompassMeta = {
    name,
    version,
    description,
    mainProgram ? name,
    longDescription ? "",
    homepage ? "",
    downloadPage ? homepage,
    changelog ? null,
    proprietaryLicense ? "unfree",
    qompassLicense ? "agpl3Only", 
    customLicense ? null,
    sourceProvenance ? with lib.sourceTypes; [ binaryNativeCode ],
    platforms ? [ "x86_64-linux" "aarch64-linux" ],
    outputsToInstall ? [ "out" ],
    maintainers ? [],
    additionalMaintainers ? [],
    timeout ? 7200,
    broken ? false,
    badPlatforms ? [],
    knownVulnerabilities ? [],
    extraMeta ? {},
    category ? "hpc",
    qompassVersion ? "1.0",
    researchArea ? null,
    ...
  }: with lib; {
    inherit description mainProgram platforms outputsToInstall timeout broken badPlatforms knownVulnerabilities;
    
    longDescription = if longDescription != "" then longDescription else ''
      ${description}
      This package is part of the Qompass AI NUR (Nix User Repository) focused on
      deep tech, quantum AI, HPC, and research applications.
      LICENSING NOTICE:
      • ${name} components: Licensed under ${proprietaryLicense} license
      • Qompass AI packaging, build scripts, and configuration: Dual-licensed under:
        - GNU AGPL v3.0 for non-commercial, open-source use
        - Qompass Commercial Distribution Agreement (Q-CDA) v1.0 for commercial use
    '';
    homepage = if homepage != "" then homepage else "https://github.com/qompassai/nur";
    downloadPage = if downloadPage != homepage then downloadPage else homepage + "/releases";

    changelog = if changelog != null then changelog 
                else if homepage != "" then "${homepage}/releases" 
                else null;

    license = with licenses; 
      [ (if proprietaryLicense == "unfree" then unfree else proprietaryLicense) ]
      ++ [ (if qompassLicense == "agpl3Only" then agpl3Only else qompassLicense) ]
      ++ (optional (customLicense != null) customLicense)
      ++ [{
        fullName = "Qompass AI Commercial Distribution Agreement v${qompassVersion}";
        shortName = "Q-CDA-${qompassVersion}";
        spdxId = "Q-CDA-${qompassVersion}";
        url = "https://github.com/qompassai/nur/blob/main/LICENSE-QCDA";
        free = false;
        redistributable = true;
      }];
    inherit sourceProvenance;
    maintainers = with maintainers; [
      {
        github = "qompassai";
        githubId = 137334444;
        name = "Qompass AI";
      }
    ] ++ maintainers ++ additionalMaintainers;
    qompass = {
      category = category;
      version = qompassVersion;
      researchArea = researchArea;
      nurRepository = "https://github.com/qompassai/nur";
    };
    position = __curPos.file + ":" + toString __curPos.line;
  } // extraMeta;
makeNvidiaHpcMeta = args: makeQompassMeta ({
  category = "hpc";
  researchArea = "high-performance-computing";
  proprietaryLicense = "unfree";
  sourceProvenance = with lib.sourceTypes; [ binaryNativeCode binaryBytecode fromSource ];
  timeout = 7200;
  platforms = [ "x86_64-linux" "aarch64-linux" ];
} // args);
makeAiMlMeta = args: makeQompassMeta ({
  category = "ai-ml";
  researchArea = "artificial-intelligence";
  timeout = 3600;
} // args);
makeQuantumMeta = args: makeQompassMeta ({
  category = "quantum";
  researchArea = "quantum-computing";
  timeout = 1800;
  platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
} // args);
in
rec {
  bunkerUrl = "https://bunker.xuyh0120.win/lantian";
  bunkerPublicKey = "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=";
  cachixUrl = "https://xddxdd.cachix.org";
  cachixPublicKey = "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=";
  garnixUrl = "https://cache.garnix.io";
  garnixPublicKey = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  url = atticUrl;
  publicKey = atticPublicKey;
}
