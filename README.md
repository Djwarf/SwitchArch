# SwitchArch

A polished Arch Linux + Hyprland desktop environment, ready to deploy.

![Hyprland Desktop](https://raw.githubusercontent.com/YOUR_USERNAME/SwitchArch/main/screenshots/desktop.png)

## Features

- **Hyprland Window Manager** - Modern, GPU-accelerated Wayland compositor
- **Modular Configuration** - Well-organized, easy to customize
- **5 Color Themes** - Switch instantly with a keybind
- **Complete Tooling** - All the tools you need for daily use
- **One-Command Install** - Get up and running fast

### Included Themes

| Theme | Description |
|-------|-------------|
| 🍷 Burgundy Glass | Deep reds on dark gray (default) |
| 🌲 Forest Canopy | Natural greens and earth tones |
| 🌊 Deep Ocean | Calming blues and teals |
| 🌅 Golden Sunset | Warm oranges and golds |
| ❄️ Arctic Nord | Cool blues inspired by Nord |

Press `SUPER + SHIFT + T` to cycle through themes!

## Quick Start

### Prerequisites

- Fresh Arch Linux installation
- Internet connection
- [yay](https://github.com/Jguer/yay) (AUR helper) - recommended but optional

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/SwitchArch.git
cd SwitchArch

# Run the installer
./install.sh
```

### Installation Options

| Option | Description |
|--------|-------------|
| `--full` | Install everything (default) |
| `--minimal` | Core packages only, no apps |
| `--no-packages` | Config files only |
| `--dry-run` | Preview changes |

```bash
# Examples
./install.sh --minimal      # Lightweight install
./install.sh --no-packages  # Just the configs
./install.sh --dry-run      # See what would happen
```

After installation, **log out and back in**. Hyprland starts automatically on TTY1.

## Keybindings

### Essential

| Keybind | Action |
|---------|--------|
| `SUPER + T` | Terminal (Kitty) |
| `SUPER + A` | App launcher (nwg-drawer/Fuzzel) |
| `SUPER + F` | File manager (Thunar) |
| `SUPER + B` | Browser (Brave) |
| `SUPER + K` | Close window |
| `SUPER + L` | Lock screen |
| `SUPER + X` | Power menu (wlogout) |
| `SUPER + H` | Show all keybindings |

### Window Management

| Keybind | Action |
|---------|--------|
| `SUPER + V` | Toggle floating |
| `SUPER + M` | Fullscreen (no gaps) |
| `SUPER + SHIFT + M` | Fullscreen (with gaps) |
| `SUPER + Z` | Pin window (float + all workspaces) |
| `SUPER + Arrow` | Move focus |
| `SUPER + CTRL + Arrow` | Swap windows |
| `SUPER + ALT + R` | Resize mode (arrow keys) |

### Workspaces

| Keybind | Action |
|---------|--------|
| `SUPER + 1-0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + SHIFT + S` | Move to scratchpad |
| `SUPER + Scroll` | Cycle workspaces |

### Screenshots

| Keybind | Action |
|---------|--------|
| `SUPER + P` | Region screenshot → save |
| `SUPER + ALT + P` | Region screenshot → clipboard |
| `SUPER + CTRL + P` | Full screen → save |
| `SUPER + CTRL + ALT + P` | Full screen → clipboard |

### Utilities

| Keybind | Action |
|---------|--------|
| `SUPER + SHIFT + T` | Cycle color themes |
| `SUPER + C` | Clipboard history |
| `SUPER + Y` | Toggle waybar |

### Media Keys

Volume, brightness, and media controls work out of the box with laptop function keys.

## Components

### Core

- **[Hyprland](https://hyprland.org/)** - Wayland compositor
- **[Waybar](https://github.com/Alexays/Waybar)** - Status bar
- **[Kitty](https://sw.kovidgoyal.net/kitty/)** - Terminal emulator
- **[Thunar](https://docs.xfce.org/xfce/thunar/start)** - File manager

### Launchers & Menus

- **[nwg-drawer](https://github.com/nwg-piotr/nwg-drawer)** - Full-screen app drawer
- **[Fuzzel](https://codeberg.org/dnkl/fuzzel)** - Fast dmenu replacement
- **[wlogout](https://github.com/ArtsyMacaw/wlogout)** - Logout menu

### Visual

- **[Hyprpaper](https://github.com/hyprwm/hyprpaper)** - Wallpaper manager
- **[Hyprlock](https://github.com/hyprwm/hyprlock)** - Lock screen
- **[SwayNC](https://github.com/ErikReider/SwayNotificationCenter)** - Notification center
- **[SwayOSD](https://github.com/ErikReider/SwayOSD)** - On-screen display

### Shell

- **[Starship](https://starship.rs/)** - Cross-shell prompt
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - Smarter cd
- **[eza](https://github.com/eza-community/eza)** - Modern ls
- **[bat](https://github.com/sharkdp/bat)** - Better cat
- **[fzf](https://github.com/junegunn/fzf)** - Fuzzy finder

## Directory Structure

```
SwitchArch/
├── install.sh              # Installer script
├── packages/
│   ├── base.txt            # Core system packages
│   ├── hyprland.txt        # Desktop environment
│   ├── apps.txt            # Applications
│   └── aur.txt             # AUR packages
├── dotfiles/.config/
│   ├── hypr/               # Hyprland config (modular)
│   ├── waybar/             # Status bar
│   ├── kitty/              # Terminal
│   ├── themes/             # Color theme system
│   └── ...                 # Other app configs
├── scripts/.local/bin/
│   ├── theme-switcher      # Theme management
│   ├── screenshot          # Screenshot utility
│   └── waybar-*            # Waybar modules
├── shell/                  # Shell configs
├── systemd/                # User services
├── fonts/                  # Custom fonts
└── wallpapers/             # Sample wallpapers
```

## Customization

### Adding Your Wallpaper

1. Copy your wallpaper to `~/Pictures/`
2. Edit `~/.config/hypr/hyprpaper.conf`:
   ```
   wallpaper {
       monitor =
       path = ~/Pictures/your-wallpaper.jpg
       fit_mode = cover
   }
   ```
3. Reload with `hyprctl reload`

### Creating a New Theme

1. Copy an existing theme in `~/.config/themes/themes/`:
   ```bash
   cp ~/.config/themes/themes/maroon.json ~/.config/themes/themes/mytheme.json
   ```
2. Edit colors in the JSON file
3. Apply with: `theme-switcher set mytheme`

### Modifying Hyprland Config

Configs are split into modules in `~/.config/hypr/hyprland.conf.d/`:

| File | Purpose |
|------|---------|
| `00-monitors.conf` | Monitor setup |
| `01-programs.conf` | Default programs |
| `02-autostart.conf` | Startup applications |
| `03-environment.conf` | Environment variables |
| `04-look-and-feel.conf` | Visuals, animations |
| `05-input.conf` | Keyboard, mouse |
| `06-keybindings.conf` | All keybinds |
| `07-windowrules.conf` | Window rules |

Edit individual files and reload: `hyprctl reload`

## Troubleshooting

### Black screen after login

- Check if Hyprland is starting: `hyprctl version`
- For NVIDIA: Ensure `nvidia-open` is installed and in `03-environment.conf`:
  ```
  env = LIBVA_DRIVER_NAME,nvidia
  env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  ```

### Waybar not appearing

- Check if running: `pgrep waybar`
- Start manually: `waybar`
- Check logs: `journalctl --user -u waybar`

### Theme not applying

- Run manually: `~/.local/bin/theme-switcher set maroon`
- Check for errors in the output
- Ensure all template files exist in `~/.config/themes/templates/`

### No audio

- Ensure PipeWire is running: `systemctl --user status pipewire`
- Check volume: `wpctl status`
- Open pavucontrol for detailed settings

### Screen not locking

- Test hyprlock: `hyprlock`
- Check hypridle is running: `pgrep hypridle`

## Optional Services

### Daily Backups (borg)

```bash
# Configure backup location first!
# Edit ~/.local/bin/backup-home

# Enable daily backups
systemctl --user enable --now backup.timer
```

### Game Streaming (Sunshine)

```bash
# Enable Sunshine service
systemctl --user enable --now sunshine.service

# Configure at https://localhost:47990
```

## Uninstalling

Your original configs are backed up during installation:

```bash
# Find your backup
ls ~/.config-backup-*

# Restore if needed
mv ~/.config-backup-XXXXXXXX/* ~/
```

To remove SwitchArch configs:
```bash
rm -rf ~/.config/{hypr,waybar,kitty,themes,fuzzel,wofi,swaync,dunst,swayosd,wlogout,nwg-drawer,nwg-dock-hyprland,btop}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Credits

- [Hyprland](https://hyprland.org/) and the Hypr ecosystem
- [Catppuccin](https://github.com/catppuccin) for color inspiration
- The Arch Linux community

## License

MIT License - Feel free to use, modify, and distribute.

---

**Enjoy your new desktop!** 🚀

If you have issues or suggestions, please [open an issue](https://github.com/YOUR_USERNAME/SwitchArch/issues).
