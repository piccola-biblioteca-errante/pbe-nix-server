# NixOS Server Configuration (Flakes + Latest)

Modern NixOS server configuration using flakes and the latest packages, featuring:

- 🐋 Calibre Web Automated (containerized)
- 🖥️ GNOME Desktop with Wayland
- 🔗 Tailscale + Funnel integration  
- 🚀 Latest NixOS unstable
- 📦 Flakes for reproducible builds
- 🛡️ Security-first configuration

## Quick Start

```bash
# Clone or download configuration files
git clone <your-repo> /etc/nixos/

# Generate hardware configuration
sudo nixos-generate-config

# Build and switch (first time)
sudo nixos-rebuild switch --flake /etc/nixos#pbe-nix-server

# Set user password
sudo passwd admin

# Reboot
sudo reboot
```

## File Structure

```
/etc/nixos/
├── flake.nix           # Flake configuration with inputs/outputs
├── configuration.nix   # Main system config
├── services.nix        # Services (Tailscale, Calibre, Nginx)
├── desktop.nix         # GNOME desktop environment
├── setup-funnel.sh     # Tailscale funnel setup script
└── hardware-configuration.nix  # Auto-generated
```

## Features

### 🎯 Latest Everything
- NixOS unstable channel
- Latest kernel
- Modern Nginx with HTTP/3
- GNOME with Wayland
- PipeWire audio

### 🐋 Container Management
- Docker with auto-prune
- OCI containers for services
- Calibre Web Automated container

### 🔐 Security
- SSH key-only authentication
- Minimal open ports
- Tailscale zero-trust networking
- Automatic security updates

### 🖥️ Desktop Features
- GNOME 45+ with Wayland
- Modern fonts and themes
- Hardware acceleration
- Bluetooth support

## Post-Install Setup

### 1. Tailscale Authentication
```bash
sudo tailscale up --ssh
```

### 2. Funnel Configuration
```bash
chmod +x setup-funnel.sh
./setup-funnel.sh
```

### 3. Service Verification
```bash
# Check all services
sudo systemctl status docker-calibre-web-automated
sudo systemctl status tailscale
sudo systemctl status nginx

# Check containers
docker ps
```

## Flake Commands

```bash
# Update flake inputs
nix flake update

# Build configuration
sudo nixos-rebuild switch --flake .#pbe-nix-server

# Check flake
nix flake check

# Show flake info
nix flake show
```

## Adding Services

Edit `services.nix` and add service configurations:

```nix
# Media server
services.jellyfin.enable = true;

# *arr stack
services.sonarr.enable = true;
services.radarr.enable = true;
services.prowlarr.enable = true;

# Cloud storage
services.nextcloud = {
  enable = true;
  package = pkgs.nextcloud28;
  # ... configuration
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#pbe-nix-server
```

## Directory Layout

```
/var/lib/calibre-web-automated/
├── config/     # Application config
├── books/      # Library storage  
└── ingest/     # Auto-import folder

/home/admin/    # User home directory
```

## Customization

### Desktop Environment
Edit `desktop.nix` to:
- Add/remove applications
- Change themes
- Configure fonts
- Modify GNOME settings

### Services
Edit `services.nix` to:
- Add new containers
- Configure networking
- Set up reverse proxy
- Enable additional services

### System
Edit `configuration.nix` to:
- Change system settings
- Add users
- Configure hardware
- Set kernel parameters

## Maintenance

### Updates
```bash
# Update system
sudo nixos-rebuild switch --upgrade --flake .#pbe-nix-server

# Clean old generations
sudo nix-collect-garbage -d
```

### Monitoring
```bash
# System resources
htop
btop

# Service logs
journalctl -u docker-calibre-web-automated -f
journalctl -u tailscale -f

# Container stats
docker stats
```

### Backup
Important paths to backup:
- `/var/lib/calibre-web-automated/`
- `/etc/nixos/`
- `/home/admin/`

## Troubleshooting

### Container Issues
```bash
# Restart container
sudo systemctl restart docker-calibre-web-automated

# Check container logs
docker logs calibre-web-automated

# Rebuild container
docker pull crocodilestick/calibre-web-automated:latest
sudo systemctl restart docker-calibre-web-automated
```

### Network Issues
```bash
# Check Tailscale
tailscale status
tailscale ping <machine-name>

# Check funnel
tailscale funnel status

# Test local service
curl http://localhost:8083
```

### Desktop Issues
```bash
# Restart display manager
sudo systemctl restart display-manager

# Check Wayland
echo $XDG_SESSION_TYPE

# Switch to X11 (if needed)
# Edit desktop.nix: services.xserver.displayManager.gdm.wayland = false;
```

### Flake Issues
```bash
# Check flake syntax
nix flake check

# Update lock file
nix flake update

# Build without switching
sudo nixos-rebuild build --flake .#pbe-nix-server
```

## Migration from Legacy Config

If upgrading from non-flake configuration:

1. Backup current config
2. Copy flake files to `/etc/nixos/`
3. Run: `sudo nixos-rebuild switch --flake .#pbe-nix-server`
4. Reboot if kernel updated

## Performance Tips

- Enable SSD optimizations in hardware-configuration.nix
- Use zram for swap on low-memory systems
- Enable fstrim for SSD maintenance
- Consider btrfs with compression

## Security Recommendations

- Disable auto-login in production
- Use SSH certificates instead of keys
- Enable fail2ban for additional protection
- Regular security updates with flake updates
- Monitor with tools like Grafana/Prometheus

## Service Access

- **Calibre Web (Local)**: `http://localhost:8083`
- **Calibre Web (Public)**: `https://your-machine-name.tailnet-name.ts.net/calibre`
- **Desktop Environment**: Available after reboot (auto-login as admin)
- **SSH**: Accessible on port 22 (key-based authentication only)

## Resources

- [NixOS Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [NixOS Options Search](https://search.nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Tailscale NixOS](https://tailscale.com/kb/1063/install-nixos/)