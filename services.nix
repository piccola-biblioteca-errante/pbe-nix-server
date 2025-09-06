{ config, pkgs, lib, ... }:

{
  # Tailscale configuration with latest features
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--ssh" ];
  };

  # Calibre Web Automated service using latest container
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      calibre-web-automated = {
        image = "crocodilestick/calibre-web-automated:latest";
        ports = [ "8083:8083" ];
        volumes = [
          "/var/lib/calibre-web-automated/config:/config"
          "/var/lib/calibre-web-automated/books:/books"
          "/var/lib/calibre-web-automated/ingest:/ingest"
        ];
        environment = {
          PUID = "1001";
          PGID = "1001";
          TZ = "UTC";
        };
        autoStart = true;
      };
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

  # Modern Nginx configuration with HTTP/3 support
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;  # Latest Nginx with HTTP/3 support
    
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;

    virtualHosts = {
      "calibre.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8083";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
          '';
        };
      };
    };
  };

  # Enable container runtime optimizations
  virtualisation.containers.enable = true;

  # Additional modern services examples
  # Uncomment and configure as needed:
  
  # services.jellyfin = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # services.prowlarr = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # services.sonarr = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # services.radarr = {
  #   enable = true;
  #   openFirewall = true;
  # };
}