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

# Install GNOME Tweaks and GNOME Shell Extension
echo "Installing GNOME Tweaks and GNOME Shell Extension..."
dnf install -y gnome-tweaks gnome-shell-extension

# Install pipx (Python package manager)
echo "Installing pipx..."
dnf install -y pipx
pipx install gnome-extensions-cli

# Install and activate each GNOME extension manually
echo "Installing GNOME extension Dash to Panel (ID 1160)..."
gext install 1160

# Ask user if they want to activate the extension Dash to Panel
read -p "Do you want to activate the Dash to Panel extension? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  gext enable 1160
  echo "Dash to Panel activated."
else
  echo "Skipping activation of Dash to Panel."
fi

echo "Installing GNOME extension Arc Menu (ID 3628)..."
gext install 3628

# Ask user if they want to activate the extension Arc Menu
read -p "Do you want to activate the Arc Menu extension? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  gext enable 3628
  echo "Arc Menu activated."
else
  echo "Skipping activation of Arc Menu."
fi

echo "Installing GNOME extension Workspace Indicator (ID 615)..."
gext install 615

# Ask user if they want to activate the extension Workspace Indicator
read -p "Do you want to activate the Workspace Indicator extension? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  gext enable 615
  echo "Workspace Indicator activated."
else
  echo "Skipping activation of Workspace Indicator."
fi

# Ask user if they want to update the system packages now
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
else
  echo "Skipping system update."
fi

echo "Setup complete! Your Fedora system is ready to go."
