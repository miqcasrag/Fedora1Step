#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Detect Fedora version
FEDORA_VERSION=$(rpm -E %fedora)

echo "Detected Fedora version: $FEDORA_VERSION"

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

# Update the system
echo "Updating the package list and system..."
dnf -y update

if [ $? -eq 0 ]; then
  echo "System updated successfully."
else
  echo "There was an issue updating the system."
  exit 1
fi

# Install GNOME Tweaks
echo "Installing GNOME Tweaks..."
dnf install -y gnome-tweaks

# Enable minimize and maximize buttons in GNOME
echo "Enabling minimize and maximize buttons..."
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Confirm changes
echo "Minimize and maximize buttons enabled: $(gsettings get org.gnome.desktop.wm.preferences button-layout)"

# Install Extension Manager from Flathub
echo "Installing Extension Manager..."
flatpak install -y flathub com.mattjakeman.ExtensionManager

# Install Dash to Panel and ArcMenu using Extension Manager
echo "Installing Dash to Panel and ArcMenu..."
flatpak run com.mattjakeman.ExtensionManager install-extension dash-to-panel@jderose9.github.com
flatpak run com.mattjakeman.ExtensionManager install-extension arcmenu@arcmenu.com

# Restart GNOME Shell (for Xorg users)
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
  echo "Restarting GNOME Shell..."
  gnome-shell --replace &
fi

echo "Configuration complete. RPM Fusion, GNOME extensions, and settings have been applied."

