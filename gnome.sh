#!/bin/bash

# Script para configurar y personalizar tu entorno GNOME en Fedora
# Incluye todos los repositorios RPM Fusion (Libre y No Libre)

# Asegurarse de ejecutar el script como superusuario
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta el script como root o con sudo"
    exit 1
fi

# Actualizar el sistema antes de instalar cualquier cosa
echo "Actualizando el sistema..."
dnf update -y

# Instalar repositorios RPM Fusion (Libre y No Libre)
echo "Habilitando repositorios RPM Fusion..."
dnf install -y \
    https://rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Instalar paquetes esenciales para GNOME y multimedia
echo "Instalando paquetes y mejoras para tu entorno GNOME..."

dnf install -y \
    gnome-tweaks \
    gnome-shell-extension-manager \
    gnome-system-monitor \
    gnome-screenshot \
    gnome-calendar \
    gnome-terminal \
    ffmpeg \
    ffmpeg-libs \
    x264 \
    x265 \
    lame \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-ugly \
    lame \
    pulseaudio \
    alsa-tools \
    rpmfusion-free-release \
    rpmfusion-nonfree-release

# Configuración del escritorio GNOME básico
echo "Configurando tu entorno GNOME..."

# Aplicar ajustes básicos al entorno GNOME
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize"

# Configuración de la posición de elementos del panel de GNOME
gsettings set org.gnome.shell.extensions.dash-to-panel position 'BOTTOM'

# Limpiar caché y actualizaciones finales
dnf clean all
dnf update -y

# Solicitar reiniciar el sistema
echo "¡Todo está listo! Por favor, reinicia tu sistema para aplicar todos los cambios."
read -p "¿Te gustaría reiniciar ahora? (s/n): " decision
if [[ "$decision" == "s" ]]; then
    reboot
else
    echo "Por favor, reinicia tu sistema más tarde manualmente."
fi