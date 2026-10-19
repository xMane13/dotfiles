#!/bin/bash
# Parche: kernel 6.12.113 añadió el argumento exclude_bars a pci_resize_resource()
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }

SRC=/usr/src/nvidia-current-open-550.163.01/nvidia/nv-pci.c
cp -n "$SRC" "$SRC.orig"
sed -i 's/pci_resize_resource(pci_dev, NV_GPU_BAR1, requested_size);/pci_resize_resource(pci_dev, NV_GPU_BAR1, requested_size, 0);/' "$SRC"
grep -n 'pci_resize_resource' "$SRC"

# Terminar la configuración pendiente (recompila el módulo con DKMS)
dpkg --configure -a
apt install -f -y

# Pasos 3 y 4 del script anterior, que no llegaron a ejecutarse
cp -n /etc/default/grub /etc/default/grub.bak-nvidia
if ! grep -q 'nvidia-drm.modeset=1' /etc/default/grub; then
    sed -i -E 's/^(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)"/\1 nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' /etc/default/grub
fi
grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
update-grub

echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' > /etc/modprobe.d/nvidia-power.conf
systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service || true

update-initramfs -u
dkms status
echo
echo "Listo. Reinicia el equipo (sudo reboot)."
