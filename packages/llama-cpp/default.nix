{
  fetchFromGitHub,
  lib,
  llama-cpp-vulkan,
}: let
  version = "0.7.0";

  # Upstream reads these from git; keep them in sync with the pinned tag.
  buildNumber = "11669";
  buildCommit = "620d222";
in
  llama-cpp-vulkan.overrideAttrs (finalAttrs: previousAttrs: {
    inherit version;

    src = fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "v${version}";
      hash = "sha256-pEDYgI3AMTU+cekvRX7NNt5wddznydQSNuerswvEpsA=";
    };

    # nixpkgs carries a patch that is already upstream in this version.
    patches = [ ];

    preConfigure = ''
      pushd ${finalAttrs.npmRoot}
      LLAMA_BUILD_NUMBER=${buildNumber} npm run build
      popd
    '';

    cmakeFlags =
      lib.filter (
        flag:
          !(lib.hasPrefix "-DLLAMA_BUILD_NUMBER" flag)
          && !(lib.hasPrefix "-DLLAMA_BUILD_COMMIT" flag)
      )
      previousAttrs.cmakeFlags
      ++ [
        (lib.cmakeFeature "LLAMA_BUILD_NUMBER" buildNumber)
        (lib.cmakeFeature "LLAMA_BUILD_COMMIT" buildCommit)
      ];

    npmDepsHash = "sha256-hqYzdp1FwPhYkBP278fQXgY9NCKB6Q3P6Gko7BfP0m0=";

    # The upstream test-suite is not run for this pinned source.
    doCheck = false;
  })
