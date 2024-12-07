#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Remove Fedora Flatpaks repository
read -p "Do you want to remove the Fedora Flatpaks repository? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Removing Fedora Flatpaks repository..."
  flatpak remote-delete fedora || echo "Failed to remove Fedora Flatpaks repository."
fi

# Ask the user if they want to update the system packages now
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update || echo "System update encountered an issue."
fi

# Install RPM Fusion repositories (Free and Non-Free)
read -p "Do you want to install the RPM Fusion repositories? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing RPM Fusion repositories..."
  dnf install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
    || echo "Failed to install RPM Fusion repositories."
fi

# Update system packages
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update || echo "System update encountered an issue."
fi

# Install multimedia codecs
read -p "Do you want to install multimedia codecs? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing multimedia codecs..."
  dnf swap ffmpeg-free ffmpeg --allowerasing || echo "Failed to swap FFmpeg packages."
  dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin \
    || echo "Failed to update multimedia packages."
fi

# Install GNOME Tweaks and GNOME Themes Extra
read -p "Do you want to install GNOME Tweaks and GNOME Themes Extra? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing GNOME Tweaks and GNOME Themes Extra..."
  dnf install gnome-tweaks gnome-themes-extra || echo "Failed to install GNOME Tweaks or GNOME Themes Extra."
fi

# Installing Extension Manager from Flathub
read -p "Do you want to install the Extension Manager from Flathub? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing Extension Manager from Flathub..."
  flatpak install flathub com.mattjakeman.ExtensionManager || echo "Failed to install Extension Manager."
fi

# Installing Fish shell and setting it as default
read -p "Do you want to install the Fish shell? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing Fish shell..."
  dnf install fish || echo "Failed to install Fish shell."

  # Ask the user if they want to set Fish as the default shell
  read -p "Do you want to set Fish as your default shell? (y/n): " answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Setting Fish as the default shell for the user..."
    chsh -s /bin/fish || echo "Failed to set Fish as the default shell."
  else
    echo "Fish shell installation completed without setting it as default."
  fi
fi

echo "Post-installation configuration completed successfully."