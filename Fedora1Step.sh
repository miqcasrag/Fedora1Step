#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Function to confirm actions
confirm() {
    read -p "Do you want to proceed with this action? (y/n): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo "Action cancelled."
        exit 1
    fi
}

# Install RPM Fusion repositories (Free and Non-Free)
echo "Installing RPM Fusion repositories..."
confirm
dnf install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

if [ $? -eq 0 ]; then
  echo "RPM Fusion repositories installed successfully."
else
  echo "There was an issue installing RPM Fusion repositories."
  exit 1
fi

# Update system packages
echo "Updating system packages..."
confirm
dnf update @core

if [ $? -eq 0 ]; then
  echo "System packages updated successfully."
else
  echo "System update encountered an issue."
  exit 1
fi

# Install multimedia codecs
echo "Installing multimedia codecs..."
confirm
dnf swap ffmpeg-free ffmpeg --allowerasing
dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

if [ $? -eq 0 ]; then
  echo "Codecs installed and updated successfully."
else
  echo "There was an error installing multimedia codecs."
  exit 1
fi

# Install GNOME Tweaks
echo "Installing GNOME Tweaks..."
confirm
dnf install gnome-tweaks

if [ $? -eq 0 ]; then
  echo "GNOME Tweaks installed successfully."
else
  echo "Failed to install GNOME Tweaks."
  exit 1
fi

# Installing Extension Manager from Flathub
echo "Installing Extension Manager from Flathub..."
confirm
flatpak install flathub com.mattjakeman.ExtensionManager

if [ $? -eq 0 ]; then
  echo "Extension Manager installed successfully."
else
  echo "Failed to install Extension Manager."
  exit 1
fi

# Ask the user if they want to update the system
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  confirm
  echo "Updating system packages..."
  dnf update
  echo "System update completed."
else
  echo "System update skipped."
fi

echo "Post-installation configuration completed successfully."