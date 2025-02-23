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
        file = "p10k-config.zsh";
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
    general.import = [ pkgs.alacritty-theme.rose_pine ];
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

  xdg.configFile = {
    "hypr" = {
      recursive = true;
      source = ./dotfiles/hypr;
    };

    "waybar" = {
      recursive = true;
      source = ./dotfiles/waybar;
    };

    "dunst" = {
      recursive = true;
      source = ./dotfiles/dunst;
    };

    "i3" = {
      recursive = true;
      source = ./dotfiles/i3;
    };

    "swappy/config".text = ''
      [Default]
      save_dir=$HOME/Pictures/Screenshots
      save_filename_format=screenshot_%Y%m%d-%H%M%S.png
      early_exit=true
    '';

    "nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
      }
    '';

    ".xinitrc".text = ''
      if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
          eval $(dbus-launch --exit-with-session --sh-syntax)
      fi
      systemctl --user import-environment DISPLAY XAUTHORITY

      if command -v dbus-update-activation-environment >/dev/null 2>&1; then
          dbus-update-activation-environment DISPLAY XAUTHORITY
      fi
    '';
  };
}
