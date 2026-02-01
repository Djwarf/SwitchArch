#!/bin/bash
#
# SwitchArch Installer
# A polished Arch Linux + Hyprland desktop environment
#
# Usage:
#   ./install.sh [OPTIONS]
#
# Options:
#   --minimal      Install only core packages (no apps)
#   --full         Install all packages including apps (default)
#   --no-packages  Config files only, skip package installation
#   --dry-run      Show what would be done without making changes
#   --help         Show this help message
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory (where SwitchArch repo is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation options
INSTALL_MODE="full"
DRY_RUN=false
SKIP_PACKAGES=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)
                INSTALL_MODE="minimal"
                shift
                ;;
            --full)
                INSTALL_MODE="full"
                shift
                ;;
            --no-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo -e "${BOLD}SwitchArch Installer${NC}"
    echo ""
    echo "A polished Arch Linux + Hyprland desktop environment"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  ./install.sh [OPTIONS]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  --minimal      Install core system + Hyprland (no apps)"
    echo "  --full         Install everything including apps (default)"
    echo "  --no-packages  Config files only, skip package installation"
    echo "  --dry-run      Show what would be done without making changes"
    echo "  --help, -h     Show this help message"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  ./install.sh                # Full installation"
    echo "  ./install.sh --minimal      # Core packages only"
    echo "  ./install.sh --no-packages  # Just deploy configs"
    echo "  ./install.sh --dry-run      # Preview changes"
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${CYAN}${BOLD}==> $1${NC}"
}

# Dry run wrapper
run_cmd() {
    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        "$@"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking Prerequisites"

    # Check if running on Arch
    if ! command -v pacman &> /dev/null; then
        log_error "This script requires Arch Linux (pacman not found)"
        exit 1
    fi
    log_success "Arch Linux detected"

    # Check for AUR helper
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
        log_success "AUR helper found: yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
        log_success "AUR helper found: paru"
    else
        log_warning "No AUR helper found (yay/paru)"
        log_info "AUR packages will be skipped. Install yay with:"
        echo "  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
        AUR_HELPER=""
    fi

    # Check for stow
    if ! command -v stow &> /dev/null; then
        log_warning "GNU Stow not found - will install it"
        if ! $DRY_RUN && ! $SKIP_PACKAGES; then
            sudo pacman -S --noconfirm stow
        fi
    fi
    log_success "GNU Stow available"

    # Check for git
    if ! command -v git &> /dev/null; then
        log_error "Git is required but not installed"
        exit 1
    fi
    log_success "Git available"
}

# Install packages from a list file
install_packages() {
    local pkg_file="$1"
    local pkg_name="$2"
    local use_aur="$3"

    if [ ! -f "$pkg_file" ]; then
        log_warning "Package file not found: $pkg_file"
        return
    fi

    # Filter comments and empty lines
    local packages=$(grep -v '^#' "$pkg_file" | grep -v '^$' | tr '\n' ' ')

    if [ -z "$packages" ]; then
        log_warning "No packages found in $pkg_file"
        return
    fi

    log_info "Installing $pkg_name packages..."

    if [ "$use_aur" = "true" ]; then
        if [ -n "$AUR_HELPER" ]; then
            run_cmd $AUR_HELPER -S --needed --noconfirm $packages
        else
            log_warning "Skipping AUR packages (no AUR helper)"
            return
        fi
    else
        run_cmd sudo pacman -S --needed --noconfirm $packages
    fi

    log_success "$pkg_name packages installed"
}

# Install all packages based on mode
install_all_packages() {
    log_step "Installing Packages"

    if $SKIP_PACKAGES; then
        log_info "Skipping package installation (--no-packages)"
        return
    fi

    # Base packages (always installed)
    install_packages "$SCRIPT_DIR/packages/base.txt" "base system" "false"

    # Hyprland packages (always installed)
    install_packages "$SCRIPT_DIR/packages/hyprland.txt" "Hyprland desktop" "false"

    # Apps (only in full mode)
    if [ "$INSTALL_MODE" = "full" ]; then
        install_packages "$SCRIPT_DIR/packages/apps.txt" "application" "false"
        install_packages "$SCRIPT_DIR/packages/aur.txt" "AUR" "true"
    else
        log_info "Skipping apps (minimal mode)"
    fi
}

# Backup existing configs
backup_configs() {
    log_step "Backing Up Existing Configs"

    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    local needs_backup=false

    # Check what needs backing up
    local dirs_to_backup=(
        ".config/hypr"
        ".config/waybar"
        ".config/kitty"
        ".config/themes"
        ".config/fuzzel"
        ".config/wofi"
        ".config/swaync"
        ".config/dunst"
        ".config/swayosd"
        ".config/wlogout"
        ".config/nwg-drawer"
        ".config/nwg-dock-hyprland"
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/btop"
        ".bashrc"
        ".bash_profile"
    )

    for dir in "${dirs_to_backup[@]}"; do
        if [ -e "$HOME/$dir" ]; then
            needs_backup=true
            break
        fi
    done

    if $needs_backup; then
        log_info "Creating backup at $backup_dir"
        run_cmd mkdir -p "$backup_dir"

        for dir in "${dirs_to_backup[@]}"; do
            if [ -e "$HOME/$dir" ]; then
                local parent_dir=$(dirname "$backup_dir/$dir")
                run_cmd mkdir -p "$parent_dir"
                run_cmd mv "$HOME/$dir" "$backup_dir/$dir"
                log_info "Backed up: $dir"
            fi
        done

        log_success "Existing configs backed up to: $backup_dir"
    else
        log_info "No existing configs to backup"
    fi
}

# Deploy dotfiles using stow
deploy_dotfiles() {
    log_step "Deploying Dotfiles"

    # Ensure .config exists
    run_cmd mkdir -p "$HOME/.config"

    # Deploy dotfiles directory
    if [ -d "$SCRIPT_DIR/dotfiles" ]; then
        log_info "Deploying dotfiles via stow..."
        cd "$SCRIPT_DIR"
        run_cmd stow -v -t "$HOME" dotfiles
        log_success "Dotfiles deployed"
    fi
}

# Install custom scripts
install_scripts() {
    log_step "Installing Custom Scripts"

    run_cmd mkdir -p "$HOME/.local/bin"

    if [ -d "$SCRIPT_DIR/scripts/.local/bin" ]; then
        for script in "$SCRIPT_DIR/scripts/.local/bin"/*; do
            if [ -f "$script" ]; then
                local script_name=$(basename "$script")
                run_cmd cp "$script" "$HOME/.local/bin/"
                run_cmd chmod +x "$HOME/.local/bin/$script_name"
                log_info "Installed: $script_name"
            fi
        done
        log_success "Custom scripts installed"
    fi
}

# Install shell configuration
install_shell_config() {
    log_step "Installing Shell Configuration"

    if [ -d "$SCRIPT_DIR/shell" ]; then
        cd "$SCRIPT_DIR"
        run_cmd stow -v -t "$HOME" shell
        log_success "Shell configuration installed"
    fi
}

# Install systemd user services
install_services() {
    log_step "Installing Systemd User Services"

    if [ -d "$SCRIPT_DIR/systemd/.config/systemd/user" ]; then
        run_cmd mkdir -p "$HOME/.config/systemd/user"

        for service in "$SCRIPT_DIR/systemd/.config/systemd/user"/*; do
            if [ -f "$service" ]; then
                local service_name=$(basename "$service")
                run_cmd cp "$service" "$HOME/.config/systemd/user/"
                log_info "Installed: $service_name"
            fi
        done

        # Reload systemd user daemon
        if ! $DRY_RUN; then
            systemctl --user daemon-reload
        fi

        log_success "Systemd services installed"
        log_info "Enable services with: systemctl --user enable <service>"
        log_info "Available services: backup.timer, sunshine.service"
    fi
}

# Install fonts
install_fonts() {
    log_step "Installing Fonts"

    run_cmd mkdir -p "$HOME/.local/share/fonts"

    if [ -d "$SCRIPT_DIR/fonts/.local/share/fonts" ]; then
        for font in "$SCRIPT_DIR/fonts/.local/share/fonts"/*; do
            if [ -f "$font" ]; then
                run_cmd cp "$font" "$HOME/.local/share/fonts/"
            fi
        done

        # Update font cache
        if ! $DRY_RUN; then
            fc-cache -f
        fi

        log_success "Fonts installed"
    fi
}

# Copy sample wallpapers
install_wallpapers() {
    log_step "Installing Sample Wallpapers"

    run_cmd mkdir -p "$HOME/Pictures"

    if [ -d "$SCRIPT_DIR/wallpapers" ]; then
        for wp in "$SCRIPT_DIR/wallpapers"/*; do
            if [ -f "$wp" ]; then
                local wp_name=$(basename "$wp")
                # Don't overwrite existing wallpapers
                if [ ! -f "$HOME/Pictures/$wp_name" ]; then
                    run_cmd cp "$wp" "$HOME/Pictures/"
                    log_info "Installed wallpaper: $wp_name"
                fi
            fi
        done

        # Create symlink for default wallpaper
        if [ -f "$HOME/Pictures/sample-wallpaper.jpg" ] && [ ! -f "$HOME/Pictures/wallpaper.jpg" ]; then
            run_cmd ln -sf "$HOME/Pictures/sample-wallpaper.jpg" "$HOME/Pictures/wallpaper.jpg"
            log_success "Default wallpaper linked"
        fi
    fi
}

# Apply default theme
apply_theme() {
    log_step "Applying Default Theme"

    if [ -x "$HOME/.local/bin/theme-switcher" ]; then
        log_info "Applying 'maroon' theme..."
        if ! $DRY_RUN; then
            "$HOME/.local/bin/theme-switcher" set maroon
        fi
        log_success "Theme applied"
    else
        log_warning "theme-switcher not found, skipping theme application"
    fi
}

# Post-install instructions
show_post_install() {
    log_step "Installation Complete!"

    echo ""
    echo -e "${GREEN}${BOLD}SwitchArch has been installed successfully!${NC}"
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo "  1. Log out and log back in (or reboot)"
    echo "  2. Hyprland will start automatically on TTY1"
    echo ""
    echo -e "${BOLD}Key bindings:${NC}"
    echo "  SUPER + Enter      → Terminal"
    echo "  SUPER + D          → App launcher"
    echo "  SUPER + E          → File manager"
    echo "  SUPER + Q          → Close window"
    echo "  SUPER + SHIFT + T  → Cycle themes"
    echo "  SUPER + F1         → Show keybindings"
    echo ""
    echo -e "${BOLD}Optional services:${NC}"
    echo "  systemctl --user enable backup.timer     # Daily backups"
    echo "  systemctl --user enable sunshine.service # Game streaming"
    echo ""

    if [ -n "$BACKUP_DIR" ]; then
        echo -e "${BOLD}Your old configs were backed up to:${NC}"
        echo "  $BACKUP_DIR"
        echo ""
    fi

    echo -e "Enjoy your new desktop! 🚀"
}

# Main installation flow
main() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "  ███████╗██╗    ██╗██╗████████╗ ██████╗██╗  ██╗ █████╗ ██████╗  ██████╗██╗  ██╗"
    echo "  ██╔════╝██║    ██║██║╚══██╔══╝██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██║  ██║"
    echo "  ███████╗██║ █╗ ██║██║   ██║   ██║     ███████║███████║██████╔╝██║     ███████║"
    echo "  ╚════██║██║███╗██║██║   ██║   ██║     ██╔══██║██╔══██║██╔══██╗██║     ██╔══██║"
    echo "  ███████║╚███╔███╔╝██║   ██║   ╚██████╗██║  ██║██║  ██║██║  ██║╚██████╗██║  ██║"
    echo "  ╚══════╝ ╚══╝╚══╝ ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${BOLD}  A polished Arch Linux + Hyprland desktop environment${NC}"
    echo ""

    parse_args "$@"

    if $DRY_RUN; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    log_info "Installation mode: $INSTALL_MODE"
    echo ""

    # Confirm installation
    if ! $DRY_RUN; then
        echo -e "${YELLOW}This will install SwitchArch and backup existing configs.${NC}"
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    check_prerequisites
    install_all_packages
    backup_configs
    deploy_dotfiles
    install_scripts
    install_shell_config
    install_services
    install_fonts
    install_wallpapers
    apply_theme
    show_post_install
}

main "$@"
