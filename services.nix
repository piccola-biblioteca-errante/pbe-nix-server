{ config, pkgs, lib, ... }:

{
  # Tailscale configuration
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  # Calibre Web Automated service
  systemd.services.calibre-web-automated = {
    description = "Calibre Web Automated";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "calibre";
      Group = "calibre";
      WorkingDirectory = "/var/lib/calibre-web-automated";
      ExecStart = "${pkgs.docker}/bin/docker run --rm --name calibre-web-automated -p 8083:8083 -v /var/lib/calibre-web-automated/config:/config -v /var/lib/calibre-web-automated/books:/books -v /var/lib/calibre-web-automated/ingest:/ingest -e PUID=1001 -e PGID=1001 crocodilestick/calibre-web-automated:latest";
      Restart = "always";
      RestartSec = "10";
    };
  };

  # Create calibre user and directories
  users.users.calibre = {
    isSystemUser = true;
    group = "calibre";
    uid = 1001;
    home = "/var/lib/calibre-web-automated";
    createHome = true;
  };

  users.groups.calibre = {
    gid = 1001;
  };

  # Ensure directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/calibre-web-automated 0755 calibre calibre -"
    "d /var/lib/calibre-web-automated/config 0755 calibre calibre -"
    "d /var/lib/calibre-web-automated/books 0755 calibre calibre -"
    "d /var/lib/calibre-web-automated/ingest 0755 calibre calibre -"
  ];

  # Nginx reverse proxy for services
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "calibre.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8083";
          proxyWebsockets = true;
        };
      };
    };
  };

  # Additional services can be added here
  # Example: Jellyfin, Sonarr, Radarr, etc.
  
  # services.jellyfin = {
  #   enable = true;
  #   openFirewall = true;
  # };
}