#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Detect Fedora version
FEDORA_VERSION=$(rpm -E %fedora)

# Check if the version is supported (Fedora 39 or higher)
if [ "$FEDORA_VERSION" -lt 39 ]; then
  echo "This script is designed for Fedora 39 or higher."
  exit 1
fi

# Install RPM Fusion repositories (Free and Non-Free)
echo "Installing RPM Fusion repositories..."
dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$FEDORA_VERSION.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$FEDORA_VERSION.noarch.rpm"

if [ $? -eq 0 ]; then
  echo "RPM Fusion repositories installed successfully."
else
  echo "There was an issue installing RPM Fusion repositories."
  exit 1
fi

# Install GNOME Tweaks and GNOME Extensions
echo "Installing GNOME Tweaks and GNOME Extensions..."
dnf install -y gnome-tweaks gnome-extensions

# Install pipx (Python package manager)
echo "Installing pipx..."
dnf install -y pipx
pipx install gnome-extensions-cli --system-site-packages

# Install GNOME extensions using gext CLI
echo "Installing GNOME extensions using gext CLI..."
gext install 1160   # Dash to Panel
gext install 3628   # Arc Menu
gext install 615    # Workspace Indicator

# Ask user if they want to update the system packages
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
else
  echo "Skipping system update."
fi

echo "Setup complete! Your Fedora system is ready to go."
