# 🌙 Moon dots

**English** | [Español](README.es.md)

My desktop on **Debian 13 (trixie)** with **niri** + **Noctalia v5**, red and black theme, built on top of a minimal install with no desktop environment.

![Desktop](assets/screenshot.png)

| | |
|---|---|
| **Distro** | Debian 13 trixie (minimal install, no desktop) |
| **Compositor** | [niri](https://github.com/YaLTeR/niri) 26.04 (scrollable tiling, Wayland) |
| **Shell / bar** | [Noctalia](https://noctalia.dev) v5 |
| **Login** | greetd + tuigreet |
| **Terminal** | kitty (black, 40% opacity, blur) |
| **Shell** | fish + starship |
| **Fetch** | fastfetch with the Debian ASCII logo |
| **Font** | JetBrainsMono Nerd Font |
| **Hardware** | Acer Nitro V 15 (i5-13420H, RTX 4050 Max-Q, 165 Hz display) |

The niri config and the Noctalia bar are based on [Spike-dotfiles](https://github.com/triplespike/Spike-dotfiles) by triplespike (NixOS), ported to Debian and tweaked to my taste.

---

## Features

- **Active window border** with a red gradient (`#FF3B3B` to `#9B0012`), rounded corners, shadows and spring animations.
- **Capsule-style Noctalia bar**: launcher, wallpaper, workspaces and clock on the left; audio visualizer and media in the center; tray, network, volume, battery and keyboard layout on the right.
- **Keyboard** in English (US) by default, `Super+Shift+Space` switches to Latin American Spanish.
- **kitty** black and translucent (40%); single-line red starship prompt.
- **Clean fastfetch** with the Debian logo (labels in Spanish).
- **`batlim`**: turn the 80% battery charge limit on or off (Acer laptops).
- **`fixaudio`**: brings the laptop speakers back when they disappear after plugging a monitor over DisplayPort.
- Qt (OBS) and Electron (VS Code, Discord) apps forced to run natively on Wayland.
- Noctalia UI in Spanish (`lang = "es"`).

## Layout

```
.
├── install.sh                 # copies the dots to ~/.config (with backup) and installs what they need
├── sync.sh                    # pulls your configs from ~/.config back into the repo to commit changes
├── config/                    # everything that goes in ~/.config
│   ├── niri/config.kdl
│   ├── noctalia/config.toml
│   ├── noctalia/palettes/Nullscapes.json
│   ├── kitty/kitty.conf
│   ├── fish/config.fish
│   ├── fish/functions/{batlim,fixaudio}.fish
│   ├── fastfetch/config.jsonc
│   └── starship.toml
├── system/                    # system files (outside $HOME)
│   ├── greetd/config.toml
│   └── udev/99-acer-wmi-battery.rules
└── scripts/
    ├── 01-base.sh             # niri, Noctalia, NetworkManager, portals, greetd
    ├── nvidia/
    │   ├── instalar-nvidia.sh # NVIDIA open driver + Wayland modeset + suspend services
    │   └── arreglar-nvidia.sh # patch for when DKMS fails on kernel 6.12.113 (see below)
    ├── bateria-acer.sh        # acer-wmi-battery module via DKMS + permissions for batlim
    └── apps.sh                # Brave, VS Code, Docker, LaTeX, OBS, Flatpak, Steam, Claude Code
```

> The scripts print their messages in Spanish.

---

## Fresh install

Starting point: Debian 13 installed from the **netinst** ISO with every desktop environment unchecked (only "standard system utilities").

### 0. Internet from the TTY

If the installer set up Wi-Fi in `/etc/network/interfaces` but there is no connection:

```bash
su -              # with the dash, otherwise root won't have /usr/sbin in PATH
ip a              # find the interface name (e.g. wlp62s0)
ifdown wlp62s0; ifup wlp62s0
ping -c 3 8.8.8.8
```

If nothing works, plug in your phone over USB, turn on **USB tethering** and run `dhclient` on the new interface (`usb0` or `enx...`).

### 1. Clone the repo

```bash
apt install git sudo
usermod -aG sudo YOUR_USER      # then log in again
git clone https://github.com/xMane13/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Base desktop

```bash
sudo bash scripts/01-base.sh
```

Then hand Wi-Fi over to NetworkManager: comment out the wireless interface lines in `/etc/network/interfaces` with `#`, and run:

```bash
sudo systemctl restart NetworkManager
nmtui
```

### 3. NVIDIA drivers

```bash
sudo bash scripts/nvidia/instalar-nvidia.sh
sudo reboot
```

Enables `contrib non-free`, installs the **open** NVIDIA kernel module, adds `nvidia-drm.modeset=1 nvidia-drm.fbdev=1` to GRUB (required for Wayland) and enables the suspend services.

> **If DKMS fails to build the module** on kernel `6.12.113+deb13`: that kernel changed the signature of `pci_resize_resource()` and driver 550.163.01 no longer compiles. `arreglar-nvidia.sh` patches the source, finishes the install and runs the steps that were skipped:
> ```bash
> sudo bash scripts/nvidia/arreglar-nvidia.sh
> ```
> It targets that exact driver version. If Debian has already shipped a fixed driver, you don't need it.

### 4. The dots

```bash
bash install.sh
```

Reboot. tuigreet logs you straight into niri with Noctalia.

### 5. Battery (Acer laptops only)

```bash
sudo bash scripts/bateria-acer.sh
batlim on     # limit charging to 80%
batlim off    # charge to 100%
```

### 6. Apps

```bash
bash scripts/apps.sh
```

Asks group by group what to install.

---

## Just the dots

```bash
git clone https://github.com/xMane13/dotfiles.git ~/dotfiles
bash ~/dotfiles/install.sh --solo-dots
```

Everything it replaces is backed up in `~/.config/dots-backup-DATE/`.

## Saving changes

Edit your configs in `~/.config` as usual, and when you want to save them:

```bash
cd ~/dotfiles
bash sync.sh
git diff
git commit -am "describe the change"
git push
```

---

## Keybindings

`Super` is the Windows key. `Super+Shift+/` shows them all.

| Keys | Action |
|---|---|
| `Super+Enter` | Terminal |
| `Super+T` | Floating terminal |
| `Super+B` | Brave |
| `Super+E` | Files |
| `Super+Space` / `Super+D` | Noctalia launcher |
| `Super+Shift+C` | Control center |
| `Super+N` | Noctalia settings |
| `Super+X` | Power / session menu |
| `Super+Tab` | Window switcher |
| `Super+Shift+Space` | Keyboard: English / Spanish |
| `Super+Q` | Close window |
| `Super+V` | Toggle floating |
| `Super+W` | Tabbed column |
| `Super+F` / `Super+Shift+F` | Maximize / fullscreen |
| `Super+R` | Cycle column width |
| `Super+O` | Overview |
| `Super+H/L` or arrows | Focus column left / right |
| `Super+J/K` | Focus window down / up |
| `Super+Shift+H/L/J/K` | Move window |
| `Super+1..9` | Go to workspace |
| `Super+Shift+1..9` | Send window to workspace |
| `Super+U/I` or mouse wheel | Workspace down / up |
| `Print` / `Super+Shift+S` | Region screenshot |
| `Ctrl+Print` / `Alt+Print` | Screen / window screenshot |
| `Super+Shift+E` | Quit niri |

---

## Issues I ran into and how I fixed them

<details>
<summary><b>apt: "Temporary failure resolving deb.debian.org"</b></summary>

No network. See step 0. `ip a` shows whether the interface has an IP; `NO-CARRIER` on Wi-Fi means it isn't associated with any network.
</details>

<details>
<summary><b>"ifup: command not found" as root</b></summary>

You used `su` instead of `su -`. Without the dash, `/usr/sbin` isn't added to PATH.
</details>

<details>
<summary><b>Noctalia repo returns 404 ("does not have a Release file")</b></summary>

Older tutorials use `https://pkg.noctalia.dev/apt`, which no longer exists. The new one is `noctalia-trixie.sources` with the `nickh-archive-keyring.deb` keyring, and the package is now called `noctalia` (formerly `noctalia-shell`). `01-base.sh` uses the right one and removes the old file.
</details>

<details>
<summary><b>Installing niri pulled in half of GNOME</b></summary>

Recommended packages. `01-base.sh` creates `/etc/apt/apt.conf.d/99norecommends` so it doesn't happen again. If it already did: `sudo apt purge gdm3 gnome-shell gnome-session && sudo apt autoremove`, making sure it doesn't remove `niri`, `noctalia` or `xdg-desktop-portal-gnome`.
</details>

<details>
<summary><b>noctalia-greeter won't install (libdrm2, libwayland)</b></summary>

It's built against newer libraries than trixie ships. I use greetd + tuigreet from the regular repos instead.
</details>

<details>
<summary><b>niri: "Failed to parse the config file"</b></summary>

`niri validate` points to the exact line. It's almost always a duplicated keybind: comment out the original with `//`.
</details>

<details>
<summary><b>fish: "Expected a string, but found a redirection"</b></summary>

fish doesn't understand `<<'EOF'` heredocs (that's bash). Type `bash`, paste the command, then `exit`.
</details>

<details>
<summary><b>OBS doesn't show "Screen Capture (PipeWire)"</b></summary>

`obs-plugins` was missing (it doesn't get pulled in with `--no-install-recommends`) and OBS has to run on Wayland. The second part is handled by the `environment` block in `config.kdl`.
</details>

<details>
<summary><b>Laptop speakers disappear after plugging a monitor over DisplayPort</b></summary>

The Intel sound card thinks headphones were plugged in and switches to a profile without "Speaker", which `pavucontrol` also hides. Fix: run `fixaudio`, or in `pavucontrol` → Configuration uncheck "Hide unavailable profiles" and pick the `HiFi (... Speaker)` profile.
</details>

<details>
<summary><b>Battery won't charge past 80%</b></summary>

The limit is stored in the firmware and survives reinstalls. Install the module with `scripts/bateria-acer.sh` and run `batlim off`.
</details>

---

## Customizing

- **Noctalia language:** set to Spanish with `lang = "es"` under `[shell]` in `config/noctalia/config.toml`. Remove it to follow the system locale.
- **Noctalia colors:** the palette is `config/noctalia/palettes/Nullscapes.json` (blue and purple, from the original dots). Change `mPrimary`, `mSecondary` and `mTertiary` to make it red.
- **Terminal transparency:** `background_opacity` in `config/kitty/kitty.conf`.
- **Window border:** `focus-ring` in `config/niri/config.kdl`.

## Credits

- [triplespike/Spike-dotfiles](https://github.com/triplespike/Spike-dotfiles): base for the niri config, the Noctalia bar and the Nullscapes palette.
- [niri](https://github.com/YaLTeR/niri) and [Noctalia](https://github.com/noctalia-dev/noctalia).
- [frederik-h/acer-wmi-battery](https://github.com/frederik-h/acer-wmi-battery): kernel module for the Acer charge limit.
- Debian packages for niri from the [DankLinux (AvengeMedia)](https://build.opensuse.org/project/show/home:AvengeMedia:danklinux) repo.

MIT License.
