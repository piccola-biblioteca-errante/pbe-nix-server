# NixOS Server Configuration

This configuration sets up a NixOS server with:
- Calibre Web Automated for ebook management
- Desktop environment with Calibre
- Tailscale integration with funnel for internet exposure
- Docker support for additional services

## Files Overview

- `configuration.nix` - Main NixOS configuration
- `services.nix` - Service configurations (Tailscale, Calibre Web, Nginx)
- `desktop.nix` - GNOME desktop environment with applications
- `setup-funnel.sh` - Script to configure Tailscale funnel
- `README.md` - This file

## Installation Steps

1. **Install NixOS** on your target machine

2. **Copy configuration files** to `/etc/nixos/`:
   ```bash
   sudo cp *.nix /etc/nixos/
   ```

3. **Generate hardware configuration** (if not already present):
   ```bash
   sudo nixos-generate-config
   ```

4. **Apply the configuration**:
   ```bash
   sudo nixos-rebuild switch
   ```

5. **Set up user password**:
   ```bash
   sudo passwd admin
   ```

6. **Reboot the system**:
   ```bash
   sudo reboot
   ```

## Post-Installation Setup

### 1. Tailscale Configuration

After reboot, set up Tailscale:

```bash
sudo tailscale up
```

Follow the authentication link and log in to your Tailscale account.

### 2. Funnel Setup

Run the provided script to set up Tailscale funnel:

```bash
./setup-funnel.sh
```

This script will:
- Verify Tailscale is running and authenticated
- Get SSL certificates for your domain
- Configure funnel to expose Calibre Web
- Display the public URL

### 3. Calibre Web Setup

1. The service should start automatically. Check status:
   ```bash
   sudo systemctl status calibre-web-automated
   ```

2. Access Calibre Web locally at: `http://localhost:8083`

3. Complete the initial setup in the web interface

4. Add books by placing them in `/var/lib/calibre-web-automated/ingest/`

## Service Access

- **Calibre Web (Local)**: `http://localhost:8083`
- **Calibre Web (Public)**: `https://your-machine-name.tailnet-name.ts.net/calibre`
- **Desktop Environment**: Available after reboot (auto-login as admin)
- **SSH**: Accessible on port 22 (key-based authentication only)

## Adding More Services

Edit `services.nix` to add additional services. Here are some examples:

### Jellyfin Media Server
```nix
services.jellyfin = {
  enable = true;
  openFirewall = true;
};
```

### Sonarr (TV Show Management)
```nix
services.sonarr = {
  enable = true;
  openFirewall = true;
};
```

### Radarr (Movie Management)
```nix
services.radarr = {
  enable = true;
  openFirewall = true;
};
```

### Nextcloud
```nix
services.nextcloud = {
  enable = true;
  package = pkgs.nextcloud28;
  hostName = "nextcloud.local";
  config = {
    dbtype = "pgsql";
    adminpassFile = "/var/lib/nextcloud/admin-pass";
  };
};
```

After adding services, rebuild the configuration:
```bash
sudo nixos-rebuild switch
```

## Directory Structure

```
/var/lib/calibre-web-automated/
├── config/          # Calibre Web configuration
├── books/           # Book library
└── ingest/          # Drop books here for automatic import
```

## Security Notes

- SSH password authentication is disabled (key-based only)
- Firewall is enabled with minimal open ports (22, 80, 443)
- Tailscale provides secure networking layer
- Desktop auto-login is enabled (disable in production: set `services.xserver.displayManager.autoLogin.enable = false;` in `desktop.nix`)

## Troubleshooting

### Calibre Web not starting
```bash
sudo systemctl status calibre-web-automated
sudo journalctl -u calibre-web-automated -f
```

### Tailscale issues
```bash
sudo systemctl status tailscale
tailscale status
```

### Desktop not loading
Check display manager:
```bash
sudo systemctl status display-manager
```

### Docker issues
```bash
sudo systemctl status docker
docker ps
```

## Customization

- Edit `desktop.nix` to add/remove desktop applications
- Modify `services.nix` to configure additional services
- Update `configuration.nix` for system-level changes

## Backup Recommendations

Important directories to backup:
- `/var/lib/calibre-web-automated/` (books and configuration)
- `/etc/nixos/` (system configuration)
- Home directories (`/home/admin/`)

## Support

For NixOS-specific issues, refer to:
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Wiki](https://nixos.wiki/)

For service-specific issues:
- [Calibre Web Documentation](https://github.com/janeczku/calibre-web)
- [Tailscale Documentation](https://tailscale.com/kb/)