#!/usr/bin/env bash

# This script should be run after NixOS is installed and Tailscale is authenticated

echo "Setting up Tailscale Funnel for Calibre Web..."

# Check if tailscale is running
if ! systemctl is-active --quiet tailscale; then
    echo "Error: Tailscale service is not running. Please start it first with 'sudo systemctl start tailscale'"
    exit 1
fi

# Check if authenticated
if ! tailscale status &>/dev/null; then
    echo "Error: Tailscale is not authenticated. Please run 'sudo tailscale up' first"
    exit 1
fi

# Get the machine name from tailscale status
MACHINE_NAME=$(tailscale status --json | grep -o '"Name":"[^"]*"' | cut -d'"' -f4 | head -1)
TAILNET=$(tailscale status --json | grep -o '"MagicDNSSuffix":"[^"]*"' | cut -d'"' -f4)

if [ -z "$MACHINE_NAME" ] || [ -z "$TAILNET" ]; then
    echo "Error: Could not determine machine name or tailnet. Please check your Tailscale configuration."
    exit 1
fi

FULL_DOMAIN="${MACHINE_NAME}.${TAILNET}"

echo "Machine: $MACHINE_NAME"
echo "Tailnet: $TAILNET"
echo "Full domain: $FULL_DOMAIN"

# Enable HTTPS for your tailscale domain
echo "Enabling HTTPS certificate for $FULL_DOMAIN..."
if ! tailscale cert --domain "$FULL_DOMAIN"; then
    echo "Warning: Failed to get certificate. Continuing with HTTP..."
fi

# Enable funnel (this requires the machine to be an exit node or have funnel capability)
echo "Enabling funnel..."
if ! tailscale funnel --bg --https=443 --set-path=/calibre http://localhost:8083; then
    echo "Error: Failed to enable funnel. Make sure your tailscale plan supports funnel and the machine has proper permissions."
    echo "Trying with HTTP on port 80..."
    if ! tailscale funnel --bg --http=80 --set-path=/calibre http://localhost:8083; then
        echo "Error: Failed to enable funnel on both HTTPS and HTTP. Please check your Tailscale configuration."
        exit 1
    fi
    echo "Funnel enabled on HTTP port 80"
    echo "Access your service at: http://$FULL_DOMAIN/calibre"
else
    echo "Funnel enabled on HTTPS port 443"
    echo "Access your service at: https://$FULL_DOMAIN/calibre"
fi

# Check funnel status
echo ""
echo "Current funnel status:"
tailscale funnel status

echo ""
echo "Setup complete! Your Calibre Web service is now accessible through Tailscale Funnel."
echo "Note: Make sure the calibre-web-automated service is running: 'sudo systemctl status calibre-web-automated'"