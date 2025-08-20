#!/bin/bash

# Avoid user prompts
export DEBIAN_FRONTEND=noninteractive
set -e

# Update and upgrade
echo "Updating and upgrading system..."
apt-get update -y && apt-get upgrade -y

# Install necessary packages
echo "Installing sudo, curl, git, and node.js..."
apt-get install -y sudo curl git

# Install Node.js (for example, v20)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Disable and remove the systemd service after it's run
systemctl disable setup-provision.service
rm -f /etc/systemd/system/setup-provision.service
systemctl daemon-reload

# Remove this setup script after it's run
rm -- "$0"

# Print success message
echo "Setup complete!"

echo "✅ Node.js version: $(node -v)"
echo "✅ npm version: $(npm -v)"
