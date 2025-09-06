{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./services.nix
      ./desktop.nix
    ];

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "pbe-nix-server";
  networking.networkmanager.enable = true;

  # Enable flakes and new command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Time zone and internationalization
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.admin = {
    isNormalUser = true;
    description = "Server Administrator";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    docker-compose
    tailscale
  ];

  # Enable SSH
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  # Docker support
  virtualisation.docker.enable = true;

  system.stateVersion = "23.11";
}