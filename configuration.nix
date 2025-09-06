{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "pbe-nix-server";
  networking.networkmanager.enable = true;

  # Enable flakes system-wide
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

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
    neovim
    wget
    curl
    git
    htop
    btop
    docker-compose
    tailscale
    tmux
    tree
    fd
    ripgrep
    bat
  ];

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  # Docker support with latest features
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Latest system version
  system.stateVersion = "24.05";
}