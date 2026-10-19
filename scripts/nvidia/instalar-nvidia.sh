#!/bin/bash
# Instala el driver NVIDIA (módulo open) en Debian 13 trixie con niri/Wayland
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }

echo "==> 1/4 Activando contrib y non-free en /etc/apt/sources.list"
cp /etc/apt/sources.list /etc/apt/sources.list.bak-nvidia
# Solo líneas activas de deb.debian.org / security que aún no tengan contrib
sed -i -E '/^deb(-src)? .*(deb\.debian\.org|security\.debian\.org)/{/ contrib/! s/ main( |$)/ main contrib non-free\1/}' /etc/apt/sources.list
grep -E '^deb' /etc/apt/sources.list

echo "==> 2/4 Instalando headers y driver"
apt update
apt install -y linux-headers-amd64 nvidia-open-kernel-dkms nvidia-driver firmware-misc-nonfree nvidia-suspend-common

echo "==> 3/4 Activando nvidia-drm.modeset=1 en GRUB"
cp /etc/default/grub /etc/default/grub.bak-nvidia
if ! grep -q 'nvidia-drm.modeset=1' /etc/default/grub; then
    sed -i -E 's/^(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)"/\1 nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' /etc/default/grub
fi
grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
update-grub

echo "==> 4/4 Servicios de suspensión"
echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' > /etc/modprobe.d/nvidia-power.conf
systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service || true
update-initramfs -u

echo
echo "Listo. Reinicia el equipo (sudo reboot)."
