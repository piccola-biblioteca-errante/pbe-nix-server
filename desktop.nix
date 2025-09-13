{ config, pkgs, lib, ... }:

{
  # Latest GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Wayland support (default in latest GNOME)
  services.xserver.displayManager.gdm.wayland = true;

  # Modern audio with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Latest desktop packages
  environment.systemPackages = with pkgs; [
    # Modern browsers
    firefox

    # GNOME applications (latest versions)
    nautilus
    gnome-terminal
    gedit
    gnome-system-monitor
    gnome-tweaks
    dconf-editor

    # Calibre for library management (latest version)
    calibre

    # Development tools
    git

    # Media tools
    vlc

    # System utilities
    btop
    neofetch

    # Archive tools
    unzip
    p7zip
  ];

  # Latest fonts configuration
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dejavu_fonts
      font-awesome
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        monospace = [ "Fira Code" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Enable automatic login (disable for production)
  services.displayManager.autoLogin = {
    enable = true;
    user = "admin";
  };

  # Enable GNOME services
  services.gnome = {
    gnome-keyring.enable = true;
    sushi.enable = true;
  };

  # Enable printing with modern drivers
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip cups-filters ];
  };

  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;

  # Hardware acceleration
  hardware.opengl = {
    enable = true;
  };

  # Exclude some GNOME apps to keep system clean
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    totem
  ];
}
