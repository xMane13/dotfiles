#!/usr/bin/env bash
# Copia tus configs actuales de ~/.config al repo, para guardar cambios con git.
# Uso:
#   bash sync.sh
#   git diff            (revisa qué cambió)
#   git commit -am "lo que cambiaste" && git push
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config"

FILES=(
    niri/config.kdl
    noctalia/config.toml
    kitty/kitty.conf
    fish/config.fish
    fastfetch/config.jsonc
    starship.toml
)

for f in "${FILES[@]}"; do
    if [ -f "$CFG/$f" ]; then
        mkdir -p "$REPO_DIR/config/$(dirname "$f")"
        cp "$CFG/$f" "$REPO_DIR/config/$f"
        echo "ok  $f"
    else
        echo "--  $f (no existe en ~/.config)"
    fi
done

# Paletas de Noctalia y funciones de fish (todas)
for dir in noctalia/palettes fish/functions; do
    [ -d "$CFG/$dir" ] || continue
    mkdir -p "$REPO_DIR/config/$dir"
    for f in "$CFG/$dir"/*; do
        [ -f "$f" ] || continue
        cp "$f" "$REPO_DIR/config/$dir/"
        echo "ok  $dir/$(basename "$f")"
    done
done

cd "$REPO_DIR" && git status --short 2>/dev/null
