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

# Restart GNOME Shell to apply changes
echo "Restarting GNOME Shell to apply button layout changes..."
if [ "$XDG_CURRENT_DESKTOP" == "GNOME" ]; then
  gnome-shell --replace &
  sleep 5  # Give GNOME Shell some time to restart
fi

# Install Extension Manager via Flatpak
echo "Installing Extension Manager from Flathub..."
flatpak install -y flathub com.mattjakeman.ExtensionManager

# Activate popular extensions automatically
echo "Activating popular GNOME extensions..."
flatpak run com.mattjakeman.ExtensionManager install-extension dash-to-panel@jderose9.github.com
flatpak run com.mattjakeman.ExtensionManager install-extension arcmenu@arcmenu.com

# Ask the user if they want to update the system
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
  echo "System packages updated."
else
  echo "Skipping system update."
fi

echo "Setup complete! Your Fedora system is ready."
