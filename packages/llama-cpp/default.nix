{
  fetchFromGitHub,
  llama-cpp-vulkan,
}: let
  commit = "10bf611e533d81f739128304991c5e133c6aebd8";
in
  llama-cpp-vulkan.overrideAttrs (finalAttrs: previousAttrs: {
    version = "10446";

    src = fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      rev = commit;
      hash = "sha256-pRiP8Q0HekoR7DgyF+LzNbRuQ+TDrfXj3v6LUDjprTM=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
  })
