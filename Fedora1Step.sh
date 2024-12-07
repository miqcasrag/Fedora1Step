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

# Install multimedia codecs
echo "Installing multimedia codecs..."
dnf install -y \
  gstreamer1-plugins-{bad-free,good,ugly} \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugin-openh264 \
  lame \
  libdvdcss \
  x264 \
  x265

# Replace ffmpeg-free with full ffmpeg
echo "Replacing ffmpeg-free with full ffmpeg..."
dnf swap ffmpeg-free ffmpeg --allowerasing

if [ $? -eq 0 ]; then
  echo "Multimedia codecs installed successfully, including full ffmpeg."
else
  echo "There was an issue installing multimedia codecs."
  exit 1
fi

# Install GNOME Tweaks
echo "Installing GNOME Tweaks..."
dnf install -y gnome-tweaks

# Ask user to enable Minimize and Maximize buttons
read -p "Do you want to enable Minimize and Maximize buttons on windows? (y/n): " enable_buttons
if [[ "$enable_buttons" == "y" || "$enable_buttons" == "Y" ]]; then
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
  echo "Minimize and Maximize buttons enabled."
else
  echo "Skipped enabling Minimize and Maximize buttons."
fi

# Install Extension Manager from Flathub
echo "Installing Extension Manager from Flathub..."
flatpak install -y flathub org.gnome.shell.extensions.manager

# Ask user if they want to update the system packages at the end
read -p "Do you want to update the system packages now? (y/n): " update_system
if [[ "$update_system" == "y" || "$update_system" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
  echo "System packages updated."
else
  echo "Skipping system update."
fi

echo "Setup complete! Your Fedora system is ready to use."