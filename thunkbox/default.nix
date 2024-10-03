{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../scripts
    ../common/fonts.nix
    ../common/packages.nix
    ../common/hyprland.nix
    ../common/games.nix
    ../common/cloudflare-warp.nix
    ../common/virtualisation.nix
  ];

  # TODO: if I ever add more hosts I should probably move this to separate files

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "thunkbox";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.plymouth.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelParams = [ "quiet" ];

  services.logind.lidSwitch = "ignore";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      8081
    ];
  };

  # ASUS GA503RM keyboard backlight fix
  # boot.kernelPatches = [
  #   {
  #     name = "asus-hid-keyboard-backlight-fix";
  #     patch = "${inputs.g14-kernel}/v2-0001-hid-asus-use-hid-for-brightness-control-on-keyboa.patch";
  #   }
  # ];

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # thunkbox specific: hardware clock fix
  time.hardwareClockInLocalTime = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.theme = "catppuccin-mocha";
  #services.displayManager.sddm.package = pkgs.kdePackages.sddm;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r --time --cmd hyprland";
        user = "vico";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
  #services.cage.enable = true;
  #programs.regreet.enable = true;

  #services.xserver.desktopManager.gnome.enable = true;

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # temp fix for vulkan issues
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "555.58.02";
    sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
    sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
    openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
    settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
    persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
  };

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # thunkbox specific: NVIDIA power management
  powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.modesetting.enable = true;

  users.users.vico = {
    isNormalUser = true;
    description = "Victor";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config.credential = {
      helper = "manager";
      credentialStore = "secretservice";
    };
  };

  programs.direnv.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
  };

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    # thunkbox specific: asusctl
    asusctl
    libnotify
    #gnomeExtensions.blur-my-shell
    zed-editor.fhs
    prismlauncher
    webcord
    spotify
    spicetify-cli
    davinci-resolve
    ciscoPacketTracer8 # makes me want to cry
    deluge
    #(pkgs.catppuccin-sddm.override {
    #  flavor = "mocha";
    #  background = "${/home/vico/wallpapers/ukbangbang.png}";
    #  loginBackground = true;
    #})
  ];

  # THUNKBOX specific: asusctl daemon
  services.asusd.enable = true;

  system.stateVersion = "23.11";
}
