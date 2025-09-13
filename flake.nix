{
  description = "PBE NixOS Server Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Optional: Use stable if you prefer stability over latest features
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {nixpkgs, ...}: let
    mkSystem = system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            ./configuration.nix
            ./services.nix
            ./desktop.nix
            {
              nixpkgs.hostPlatform = system;
            }
          ]
          ++ nixpkgs.lib.lists.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
      };
  in {
    nixosConfigurations = {
      pbe-nix-server-x86 = mkSystem "x86_64-linux";
      pbe-nix-server-arm64 = mkSystem "aarch64-linux";
    };
  };
}
