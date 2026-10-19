#!/usr/bin/env bash
# Instala los dots en ~/.config (con respaldo) y los paquetes que usan.
# Uso:
#   bash install.sh             paquetes + dots
#   bash install.sh --solo-dots solo copia los archivos
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config"
BACKUP="$CFG/dots-backup-$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;31m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

[ "$(id -u)" -ne 0 ] || { echo "Córrelo como tu usuario normal, no con sudo"; exit 1; }

if [ "${1:-}" != "--solo-dots" ]; then
    info "Paquetes de la terminal y el escritorio"
    sudo apt update
    sudo apt install -y \
        kitty fish starship fastfetch eza bat zoxide fzf btop cava \
        playerctl wl-clipboard grim slurp git curl xz-utils fontconfig \
        fonts-noto-core fonts-noto-color-emoji libglib2.0-bin

    info "Extras (si alguno no existe en Debian se salta)"
    for p in wl-clip-persist papirus-icon-theme adw-gtk3 nautilus loupe; do
        sudo apt install -y "$p" >/dev/null 2>&1 && echo "   ok: $p" || warn "no disponible: $p"
    done

    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        info "JetBrainsMono Nerd Font"
        tmp="$(mktemp -d)"
        mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNF"
        curl -fL -o "$tmp/jbm.tar.xz" \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
            && tar -xJf "$tmp/jbm.tar.xz" -C "$HOME/.local/share/fonts/JetBrainsMonoNF" \
            && fc-cache -f >/dev/null \
            || warn "No se pudo instalar la fuente, los iconos se verán como cuadros."
        rm -rf "$tmp"
    fi
fi

info "Copiando dots (respaldo en $BACKUP)"
cd "$REPO_DIR/config"
find . -type f | sed 's|^\./||' | sort | while read -r f; do
    if [ -e "$CFG/$f" ]; then
        mkdir -p "$BACKUP/$(dirname "$f")"
        cp -a "$CFG/$f" "$BACKUP/$f"
    fi
    mkdir -p "$CFG/$(dirname "$f")"
    cp "$f" "$CFG/$f"
    echo "   $f"
done
mkdir -p "$HOME/Pictures/Screenshots"

if command -v niri >/dev/null; then
    niri validate -c "$CFG/niri/config.kdl" >/dev/null 2>&1 \
        && echo "   niri: config válida" \
        || warn "niri validate encontró errores. Revisa con: niri validate"
fi

info "Tema oscuro para apps GTK"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
dpkg -s adw-gtk3 >/dev/null 2>&1 && gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null
dpkg -s papirus-icon-theme >/dev/null 2>&1 && gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null

if [ "$(basename "${SHELL:-}")" != "fish" ] && command -v fish >/dev/null; then
    read -r -p "¿Usar fish como shell por defecto? [s/N] " r
    [[ "$r" =~ ^[sSyY]$ ]] && chsh -s "$(command -v fish)"
fi

echo
info "Listo. Cierra sesión (Super+Shift+E) y vuelve a entrar."
