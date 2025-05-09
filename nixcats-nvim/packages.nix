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
  golf-vim = vimUtils.buildVimPlugin {
    pname = "golf-vim";
    src = fetchFromGitHub {
      owner = "vuciv";
      repo = "golf";
      rev = "abf1bc0c1c4a5482b4a4b36b950b49aaa0f39e69";
      hash = "sha256-lCzt+7/uZ/vvWnvWPIqjtS3G3w3qOhI7vHdSQ9bvMKU=";
    };
    version = "master";
  };
}
