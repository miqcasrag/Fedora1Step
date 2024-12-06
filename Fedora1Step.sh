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

# Enable minimize and maximize buttons in GNOME
echo "Enabling minimize and maximize buttons..."
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

# Install GNOME Shell Extension Manager
echo "Installing GNOME Shell Extension Manager..."
dnf install -y gnome-shell-extension-manager

# Use GNOME Shell Extension Manager to search and install "Dash to Panel" and "ArcMenu"
echo "Installing popular GNOME extensions: Dash to Panel and ArcMenu..."
gnome-shell-extension-manager install dash-to-panel@jderose9.github.com
gnome-shell-extension-manager install arcmenu@arcmenu.com

# Ask user if they want to update the system packages
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
else
  echo "Skipping system update."
fi

echo "Setup complete! Your Fedora system is ready to go."
