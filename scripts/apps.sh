#!/usr/bin/env bash
# Programas del día a día. Pregunta grupo por grupo.
# Uso: bash scripts/apps.sh   (como tu usuario, pide sudo cuando hace falta)
set -uo pipefail

[ "$(id -u)" -ne 0 ] || { echo "Córrelo como tu usuario normal, no con sudo"; exit 1; }

ask() { read -r -p "$1 [s/N] " r; [[ "$r" =~ ^[sSyY]$ ]]; }
info() { printf '\033[1;31m==>\033[0m %s\n' "$*"; }

if ask "¿Brave?"; then
    info "Brave"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update && sudo apt install -y brave-browser
fi

if ask "¿Herramientas de desarrollo (gcc, gdb, cmake, clang, python)?"; then
    info "Desarrollo"
    sudo apt install -y build-essential gdb cmake clang python3-venv python3-pip python3-dev
fi

if ask "¿VS Code?"; then
    info "VS Code"
    wget -qO /tmp/code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    sudo apt install -y /tmp/code.deb && rm -f /tmp/code.deb
fi

if ask "¿Docker?"; then
    info "Docker"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    printf '%s\n' 'Types: deb' 'URIs: https://download.docker.com/linux/debian' 'Suites: trixie' \
        'Components: stable' 'Architectures: amd64' 'Signed-By: /etc/apt/keyrings/docker.asc' \
        | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo "   Cierra sesión y vuelve a entrar para usar docker sin sudo."
fi

if ask "¿LaTeX (tesis, papers IEEE, español)?"; then
    info "LaTeX"
    sudo apt install -y texlive-latex-extra texlive-science texlive-publishers \
        texlive-lang-spanish texlive-bibtex-extra biber latexmk
fi

if ask "¿OBS, mpv, GIMP y utilidades?"; then
    info "Multimedia"
    # obs-plugins trae la captura PipeWire, sin él no se puede grabar en Wayland
    sudo apt install -y obs-studio obs-plugins mpv gimp file-roller p7zip-full
fi

if ask "¿Flatpak + Spotify, Discord, Obsidian?"; then
    info "Flatpak"
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub com.spotify.Client com.discordapp.Discord md.obsidian.Obsidian
fi

if ask "¿Steam?"; then
    info "Steam (necesita contrib y arquitectura i386)"
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y steam-installer nvidia-driver-libs:i386
fi

if ask "¿Claude Code?"; then
    info "Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
    command -v fish >/dev/null && fish -c 'fish_add_path ~/.local/bin'
fi

info "Terminado."
