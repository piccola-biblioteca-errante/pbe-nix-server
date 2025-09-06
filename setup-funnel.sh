#!/usr/bin/env bash

# Tailscale Funnel Setup Script for NixOS Flake Configuration
# This script should be run after NixOS is installed and Tailscale is authenticated

set -euo pipefail

echo "🚀 Setting up Tailscale Funnel for Calibre Web..."

# Check if tailscale is running
if ! systemctl is-active --quiet tailscale; then
    echo "❌ Error: Tailscale service is not running. Please start it first with 'sudo systemctl start tailscale'"
    exit 1
fi

# Check if authenticated
if ! tailscale status &>/dev/null; then
    echo "❌ Error: Tailscale is not authenticated. Please run 'sudo tailscale up' first"
    exit 1
fi

# Check if jq is available (needed for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found. Installing temporarily..."
    nix-shell -p jq --run "echo 'jq available'"
    JQ_CMD="nix-shell -p jq --run"
else
    JQ_CMD="jq"
fi

# Get tailscale status information
echo "📡 Getting Tailscale information..."
STATUS_JSON=$(tailscale status --json)
MACHINE_NAME=$(echo "$STATUS_JSON" | $JQ_CMD -r '.Self.HostName')
TAILNET=$(echo "$STATUS_JSON" | $JQ_CMD -r '.MagicDNSSuffix')

if [ -z "$MACHINE_NAME" ] || [ -z "$TAILNET" ] || [ "$MACHINE_NAME" = "null" ] || [ "$TAILNET" = "null" ]; then
    echo "❌ Error: Could not determine machine name or tailnet. Please check your Tailscale configuration."
    exit 1
fi

FULL_DOMAIN="${MACHINE_NAME}.${TAILNET}"

echo "🖥️  Machine: $MACHINE_NAME"
echo "🌐 Tailnet: $TAILNET"
echo "🔗 Full domain: $FULL_DOMAIN"

# Check if funnel is supported
echo "🔍 Checking funnel capability..."
if ! tailscale funnel status &>/dev/null; then
    echo "⚠️  Warning: Funnel may not be available on your plan or machine configuration."
    echo "   Please ensure you have a Tailscale plan that supports funnel."
fi

# Enable HTTPS certificate
echo "🔒 Enabling HTTPS certificate for $FULL_DOMAIN..."
if tailscale cert --domain "$FULL_DOMAIN" 2>/dev/null; then
    echo "✅ Certificate obtained successfully"
    USE_HTTPS=true
else
    echo "⚠️  Warning: Failed to get certificate. Continuing with HTTP..."
    USE_HTTPS=false
fi

# Configure funnel
echo "🌟 Configuring funnel..."
if [ "$USE_HTTPS" = true ]; then
    if tailscale funnel --bg --https=443 --set-path=/calibre http://localhost:8083; then
        echo "✅ HTTPS funnel enabled successfully"
        echo "🎉 Access your service at: https://$FULL_DOMAIN/calibre"
        FUNNEL_URL="https://$FULL_DOMAIN/calibre"
    else
        echo "❌ Failed to enable HTTPS funnel, trying HTTP..."
        USE_HTTPS=false
    fi
fi

if [ "$USE_HTTPS" = false ]; then
    if tailscale funnel --bg --http=80 --set-path=/calibre http://localhost:8083; then
        echo "✅ HTTP funnel enabled successfully"
        echo "🎉 Access your service at: http://$FULL_DOMAIN/calibre"
        FUNNEL_URL="http://$FULL_DOMAIN/calibre"
    else
        echo "❌ Error: Failed to enable funnel on both HTTPS and HTTP."
        echo "   Please check your Tailscale configuration and plan."
        exit 1
    fi
fi

# Display status
echo ""
echo "📊 Current funnel status:"
tailscale funnel status

echo ""
echo "🎯 Service Status Check:"
if systemctl is-active --quiet docker-calibre-web-automated; then
    echo "✅ Calibre Web Automated container is running"
elif systemctl is-active --quiet calibre-web-automated; then
    echo "✅ Calibre Web Automated service is running"
else
    echo "⚠️  Calibre Web Automated is not running. Start it with:"
    echo "   sudo systemctl start docker-calibre-web-automated"
fi

echo ""
echo "🎉 Setup complete!"
echo "📖 Your Calibre Web service is accessible at:"
echo "   🏠 Local: http://localhost:8083"
echo "   🌍 Public: $FUNNEL_URL"
echo ""
echo "💡 Tips:"
echo "   • Place books in /var/lib/calibre-web-automated/ingest/ for auto-import"
echo "   • Check container logs: docker logs calibre-web-automated"
echo "   • Check service logs: sudo journalctl -u docker-calibre-web-automated -f"
echo "   • Monitor funnel: tailscale funnel status"