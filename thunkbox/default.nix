{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../scripts
    ../common/fonts.nix
    ../common/packages.nix
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

  # ASUS GA503RM keyboard backlight fix
  boot.kernelPatches = [
    {
      name = "asus-g14-kernel-hid-backlight";
      patch = ./patches/v2-0001-hid-asus-use-hid-for-brightness-control-on-keyboa.patch;
    }
  ];

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

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
    gnomeExtensions.blur-my-shell
    zed-editor
  ];

  # THUNKBOX specific: asusctl daemon
  services.asusd.enable = true;

  system.stateVersion = "23.11";
}
