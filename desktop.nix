{ config, pkgs, ... }:

{
  # Enable X11 windowing system
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Enable GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # Calibre for library management
    calibre
    
    # Desktop applications
    firefox
    gnome.gnome-terminal
    gnome.nautilus
    gnome.gedit
    
    # System utilities
    gnome.gnome-system-monitor
    
    # Remote desktop (optional)
    remmina
    
    # Text editors
    vscode
  ];

  # Enable automatic login for desktop use (optional - remove for security)
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "admin";

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable printing (optional)
  services.printing.enable = true;

  # Enable touchpad support (if running on laptop hardware)
  services.xserver.libinput.enable = true;
}