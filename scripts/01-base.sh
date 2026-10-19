#!/usr/bin/env bash
# Paso 1: escritorio base sobre Debian 13 (trixie) instalado SIN entorno gráfico.
# Instala niri, Noctalia v5, NetworkManager, portales y greetd + tuigreet.
# Uso: sudo bash scripts/01-base.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Sin paquetes recomendados por defecto (evita que se cuele medio GNOME)"
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99norecommends

apt update
apt install -y curl wget gnupg ca-certificates git sudo nano

echo "==> Repositorio de Noctalia (v5)"
if ! [ -f /etc/apt/sources.list.d/noctalia-trixie.sources ]; then
    tmp="$(mktemp -d)"
    wget -qO "$tmp/keyring.deb" https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb
    dpkg -i "$tmp/keyring.deb"
    wget -qO /etc/apt/sources.list.d/noctalia-trixie.sources https://pkg.noctalia.dev/deb/noctalia-trixie.sources
    rm -rf "$tmp"
fi
# El repo viejo (pkg.noctalia.dev/apt) ya no existe y rompe apt update
rm -f /etc/apt/sources.list.d/noctalia.list

echo "==> Repositorio de DankLinux (niri y xwayland-satellite para Debian 13)"
DANK=https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/Debian_13
if ! grep -rqs "AvengeMedia" /etc/apt/sources.list.d/; then
    curl -fsSL "$DANK/Release.key" | gpg --dearmor -o /etc/apt/keyrings/danklinux.gpg
    echo "deb [signed-by=/etc/apt/keyrings/danklinux.gpg] $DANK/ /" > /etc/apt/sources.list.d/danklinux.list
fi

apt update

echo "==> Escritorio"
apt install -y \
    niri noctalia xwayland xwayland-satellite \
    network-manager \
    xdg-desktop-portal-gnome xdg-desktop-portal-gtk gnome-keyring \
    pipewire pipewire-pulse wireplumber pavucontrol pulseaudio-utils \
    greetd tuigreet \
    kitty unzip

echo "==> greetd + tuigreet como pantalla de login"
install -Dm644 "$REPO_DIR/system/greetd/config.toml" /etc/greetd/config.toml
systemctl enable greetd

cat <<'EOF'

Listo.
Si tu WiFi está configurado en /etc/network/interfaces (lo hace el instalador de
Debian), comenta las líneas de la interfaz inalámbrica para que la maneje
NetworkManager, luego:
    sudo systemctl restart NetworkManager
    nmtui

Siguiente paso: drivers NVIDIA (scripts/nvidia/instalar-nvidia.sh) y reinicio.
EOF
