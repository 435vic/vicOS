{
  lib,
  vimUtils,
  fetchFromGitHub,
  ...
}: {
  vim-be-good = vimUtils.buildVimPlugin {
    pname = "vim-be-good";
    src = fetchFromGitHub {
      owner = "ThePrimeagen";
      repo = "vim-be-good";
      rev = "0ae3de14eb8efc6effe7704b5e46495e91931cc5";
      hash = "sha256-yrNZV90yiHIxw0OMSSvi5SMApR2oFT8EpvF6TiUlC88=";
    };
    version = "master";
  };
}
