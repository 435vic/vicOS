{
  inputs,
  outputs,
  config,
  pkgs,
  ...
}:
{
  home.username = "vico";
  home.homeDirectory = "/home/vico";
  home.stateVersion = "23.11";

  nixpkgs.overlays = [ inputs.alacritty-theme.overlays.default ];

  programs.home-manager.enable = true;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    opts = {
      number = true;
      signcolumn = "yes";
      showmode = false;
      mouse = "a";
      undofile = true;
      updatetime = 250;
      timeoutlen = 300;
      ignorecase = true;
      smartcase = true;
      splitright = true;
      splitbelow = true;
      cursorline = true;
      inccommand = "split";
    };
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    plugins = {
      oil.enable = true;
      transparent.enable = true;
      lightline.enable = true;
      lightline.settings.colorscheme = "rosepine";
      telescope.enable = true;
    };
    colorschemes.rose-pine.enable = true;
  };

  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./dotfiles;
        file = ".p10k.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };

  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    import = [ pkgs.alacritty-theme.rose-pine ];
    font.normal.family = "JetBrains Mono";
    window = {
      padding = {
        x = 6;
        y = 4;
      };
      opacity = 0.85;
      blur = true;
    };
    mouse.bindings = [
      {
        mouse = "Right";
        action = "Paste";
      }
    ];
    keyboard.bindings = [
      {
        key = "N";
        mods = "Control|Shift";
        action = "CreateNewWindow";
      }
    ];
  };

  programs.git = {
    enable = true;
    userName = "Victor Quintana";
    userEmail = "435victorjavier@gmail.com";
  };
}
