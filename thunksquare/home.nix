{
  inputs,
  outputs,
  config,
  pkgs,
  localpkgs,
  ...
}: {
  imports = [ ./dconf.nix ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vico";
  home.homeDirectory = "/home/vico";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    # Custom build of zed with semi-latest commit

    pkgs.bun
    #    pkgs.rustup
    pkgs.cargo

    (pkgs.buildFHSEnv {
      name = "zed";
      targetPkgs = pkgs: [localpkgs.zed];
      extraInstallCommands = ''
        mkdir -p $out/share/applications
        ln -s ${localpkgs.zed}/share/icons $out/share
        ln -s ${localpkgs.zed}/share/applications/dev.zed.Zed.desktop $out/share/applications/dev.zed.Zed.desktop
      '';
      runScript = pkgs.writeShellScript "zed-wrapper.sh" ''
        export WAYLAND_DISPLAY=
        exec zed "$@"
      '';
    })

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vico/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.git = {
    enable = true;
    userName = "Victor Quintana";
    userEmail = "435victorjavier@gmail.com";
  };

  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "powerlevel10k-config";
	src = ./dotfiles;
	file = "p10k.zsh";
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
    font.normal.family = "MesloLGS NF";
    window = {
      padding = {
        x = 6;
        y = 4;
      };
      opacity = 0.85;
      blur = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;  
}