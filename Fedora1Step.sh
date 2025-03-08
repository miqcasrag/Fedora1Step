#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Remove Fedora Flatpaks repository
read -p "Do you want to remove the Fedora Flatpaks repositories? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Removing Fedora Flatpaks repositories..."
  
  flatpak remote-delete fedora && echo "'fedora' repository removed successfully." || echo "Failed to remove 'fedora' repository."
  flatpak remote-delete fedora-testing && echo "'fedora-testing' repository removed successfully." || echo "Failed to remove 'fedora-testing' repository."

# Check if only the official Flathub repository remains
  remaining_repos=$(flatpak remotes --columns=name)

  if [[ "$remaining_repos" == "flathub" ]]; then
    echo "Fedora Flatpaks repositories have been successfully removed. Only the official Flathub repository remains."
  else
    echo "Unexpected repositories detected:"
    echo "$remaining_repos"
  fi
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
read -p "Do you want to update the system packages now? This may take a few minutes. (y/n): " answer
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

# Simulate a loading effect
echo -n "Finalizing post-installation"
for i in {1..3}; do
  echo -n "."
  sleep 0.5
done
echo ""

# Display the final message in a highlighted format
echo -e "\e[1;32m✔ Post-installation configuration completed successfully! \e[0m"

# Ask if the user wants to restart
read -p "Do you want to restart now? (y/n): " restart_answer
if [[ "$restart_answer" == "y" || "$restart_answer" == "Y" ]]; then
  echo "Restarting the system..."
  sudo reboot
else
  echo "Restart skipped. You may need to restart later for changes to take effect."
fi