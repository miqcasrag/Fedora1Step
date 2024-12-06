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

# Install GNOME Tweaks
echo "Installing GNOME Tweaks..."
dnf install -y gnome-tweaks

# Install the Extension Manager from Flathub
echo "Installing Extension Manager..."
flatpak install -y flathub com.mattjakeman.ExtensionManager

# Ask the user if they want to update the system
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
  echo "System update completed."
else
  echo "System update skipped."
fi

echo "Configuration completed successfully."
