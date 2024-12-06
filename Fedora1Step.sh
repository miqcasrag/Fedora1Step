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
pipx install gnome-extensions-cli

# Define an array with extension IDs
EXTENSIONS=(
  "1160"  # Dash to Panel
  "3628"  # Arc Menu
  "615"   # Workspace Indicator
)

# Loop through each extension and ask user to activate after installation
for EXT_ID in "${EXTENSIONS[@]}"; do
  echo "Installing GNOME extension with ID: $EXT_ID"
  gext install $EXT_ID

  # Ask user if they want to activate this extension
  read -p "Do you want to activate the extension with ID $EXT_ID now? (y/n): " enable_extension
  if [[ "$enable_extension" == "y" || "$enable_extension" == "Y" ]]; then
    echo "Activating GNOME extension with ID $EXT_ID..."
    gext enable $EXT_ID
  else
    echo "Skipping activation for extension with ID $EXT_ID."
  fi
done

# Ask user if they want to update the system packages
read -p "Do you want to update the system packages now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Updating system packages..."
  dnf update -y
else
  echo "Skipping system update."
fi

echo "Setup complete! Your Fedora system is ready to go."
