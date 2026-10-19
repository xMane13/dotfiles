#!/usr/bin/env bash
# Límite de carga al 80% en laptops Acer (probado en Nitro V 15 ANV15-52).
# Instala el módulo acer-wmi-battery con DKMS (sobrevive actualizaciones de kernel),
# lo carga al arrancar y da permiso para usar `batlim` sin sudo.
# Uso: sudo bash scripts/bateria-acer.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VER=1.0
SRC=/usr/src/acer-wmi-battery-$VER

apt install -y build-essential dkms "linux-headers-$(uname -r)" git

if [ ! -d "$SRC" ]; then
    git clone --depth 1 https://github.com/frederik-h/acer-wmi-battery.git "$SRC"
fi

cat > "$SRC/dkms.conf" <<EOF
PACKAGE_NAME="acer-wmi-battery"
PACKAGE_VERSION="$VER"
BUILT_MODULE_NAME[0]="acer-wmi-battery"
DEST_MODULE_LOCATION[0]="/extra"
MAKE[0]="make -C \${kernel_source_dir} M=\${dkms_tree}/\${PACKAGE_NAME}/\${PACKAGE_VERSION}/build modules"
CLEAN="make clean"
AUTOINSTALL="yes"
EOF

dkms status acer-wmi-battery/$VER | grep -q . || dkms add acer-wmi-battery/$VER
dkms install acer-wmi-battery/$VER || true

echo acer_wmi_battery > /etc/modules-load.d/acer-wmi-battery.conf
install -Dm644 "$REPO_DIR/system/udev/99-acer-wmi-battery.rules" /etc/udev/rules.d/99-acer-wmi-battery.rules
udevadm control --reload

modprobe acer_wmi_battery
chmod 666 /sys/bus/wmi/drivers/acer-wmi-battery/health_mode /sys/bus/wmi/drivers/acer-wmi-battery/calibration_mode

dkms status acer-wmi-battery
echo
echo "Listo. Usa: batlim | batlim on | batlim off"
