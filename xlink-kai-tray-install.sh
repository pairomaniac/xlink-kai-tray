#!/bin/bash
set -e
trap 'echo -e "\n\033[0;31mAborted\033[0m"; exit 130' INT

SCRIPT_NAME="xlink-kai-tray"
BIN_DIR="$HOME/.local/bin"
ICON_DIR="$HOME/.local/share/icons"
APP_DIR="$HOME/.local/share/applications"
CONFIG_DIR="$HOME/.config/xlink-kai"
AUTOSTART_DIR="$HOME/.config/autostart"

ENGINE_SEARCH_PATHS=(
    "/usr/bin/kaiengine"
    "/opt/kaiEngine-standalone/kaiengine"
    "$HOME/.local/bin/kaiengine"
    "$HOME/kaiEngine-standalone/kaiengine"
)

RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' DIM=$'\033[2m' NC=$'\033[0m'

die() { echo -e "${RED}Error:${NC} $1" >&2; exit 1; }
ok() { echo -e "  ${GREEN}✔${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
header() { echo -e "\n${BOLD}$1${NC}"; }
file_op() { echo -e "  ${BLUE}$1${NC} $2"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

check_deps() {
    python3 -c "
import gi
try:
    gi.require_version('AyatanaAppIndicator3', '0.1')
    from gi.repository import AyatanaAppIndicator3
    exit(0)
except Exception: pass
try:
    gi.require_version('AppIndicator3', '0.1')
    from gi.repository import AppIndicator3
    exit(0)
except Exception: pass
exit(1)" 2>/dev/null
}

check_caps() {
    [[ -n "$1" && -f "$1" ]] && getcap "$1" 2>/dev/null | grep -q cap_net_raw
}

refresh_desktop_db() {
    command -v update-desktop-database &>/dev/null && update-desktop-database "$APP_DIR" 2>/dev/null && ok "Updated MIME cache"
    command -v xdg-desktop-menu &>/dev/null && xdg-desktop-menu forceupdate 2>/dev/null && ok "Refreshed menu"
    [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]] && command -v kbuildsycoca6 &>/dev/null && kbuildsycoca6 --noincremental 2>/dev/null && ok "Refreshed KDE cache"
    return 0
}

show_help() {
    cat << EOF
${BOLD}Usage:${NC} $0 [OPTIONS]

${BOLD}Options:${NC}
  --help              Show this help
  --uninstall         Remove XLink Kai Tray
  --engine PATH       Set kaiengine path (auto-detected)
  --config PATH       Set kaiengine.conf path (auto-detected)
  --skip-caps         Skip setting capabilities
  --autostart         Enable autostart on login

${BOLD}Engine search paths:${NC}
EOF
    for p in "${ENGINE_SEARCH_PATHS[@]}"; do
        [[ -f "$p" ]] && echo -e "  ${GREEN}✔${NC} $p" || echo -e "  ${DIM}✗ $p${NC}"
    done
}

uninstall() {
    echo -e "${BOLD}XLink Kai Tray - Uninstall${NC}"
    echo "════════════════════════════"

    header "Stopping processes"
    pkill -f "$BIN_DIR/$SCRIPT_NAME" 2>/dev/null && ok "Stopped $SCRIPT_NAME" || info "Not running"

    header "Removing files"
    for f in "$BIN_DIR/$SCRIPT_NAME" "$ICON_DIR/xlink-kai.png" \
             "$APP_DIR/xlink-kai.desktop" "$AUTOSTART_DIR/xlink-kai.desktop"; do
        [[ -f "$f" ]] && { file_op "delete" "$f"; rm -f "$f"; }
    done
    [[ -d "$CONFIG_DIR" ]] && { file_op "delete" "$CONFIG_DIR/"; rm -rf "$CONFIG_DIR"; }

    header "Updating desktop database"
    refresh_desktop_db

    echo -e "\n${GREEN}Uninstall complete${NC}"
    exit 0
}

check_indicator() {
    header "Dependencies"

    if check_deps; then
        ok "AppIndicator found"
        return
    fi

    warn "AppIndicator not found"
    [[ -f /etc/os-release ]] && . /etc/os-release
    _ids="${ID:-} ${ID_LIKE:-}"
    _matched=false
    for _id in $_ids; do
        case "$_id" in
            fedora|rhel|centos|nobara|bazzite|ultramarine)
                info "sudo dnf install python3-gobject libayatana-appindicator-gtk3"; _matched=true; break ;;
            ubuntu|debian|pop|linuxmint|elementary|zorin)
                info "sudo apt install python3-gi gir1.2-ayatanaappindicator3-0.1"; _matched=true; break ;;
            arch|manjaro|endeavouros|garuda|cachyos)
                info "sudo pacman -S python-gobject libayatana-appindicator"; _matched=true; break ;;
            opensuse*|suse)
                info "sudo zypper install python3-gobject typelib-1_0-AyatanaAppIndicator3-0_1"; _matched=true; break ;;
        esac
    done
    [[ "$_matched" == "false" ]] && info "Install python3-gobject + libayatana-appindicator for your distro"
    die "Install dependencies and re-run"
}

set_caps() {
    header "Capabilities"

    [[ -z "$ENGINE_PATH" || ! -f "$ENGINE_PATH" ]] && { warn "Engine not found, skipping"; return; }

    if check_caps "$ENGINE_PATH"; then
        ok "Already set on $ENGINE_PATH"
        return
    fi

    info "Setting on $ENGINE_PATH (requires sudo)..."
    sudo setcap cap_net_raw,cap_net_admin=eip "$ENGINE_PATH" 2>/dev/null && ok "Done" || warn "Failed - run kaiengine with sudo"
}

install_files() {
    header "Installing files"
    mkdir -p "$BIN_DIR" "$ICON_DIR" "$CONFIG_DIR" "$APP_DIR"

    file_op "copy" "$BIN_DIR/$SCRIPT_NAME"
    cp "$SCRIPT_DIR/$SCRIPT_NAME" "$BIN_DIR/" && chmod +x "$BIN_DIR/$SCRIPT_NAME"

    if [[ -f "$SCRIPT_DIR/xlink-kai.png" ]]; then
        file_op "copy" "$ICON_DIR/xlink-kai.png"
        cp "$SCRIPT_DIR/xlink-kai.png" "$ICON_DIR/xlink-kai.png"
    else
        warn "xlink-kai.png not found, place it in $ICON_DIR manually"
    fi

    file_op "write" "$CONFIG_DIR/settings.conf"
    cat > "$CONFIG_DIR/settings.conf" << EOF
[xlink-kai]
engine_path = $ENGINE_PATH
config_path = $CONFIG_PATH
EOF

    file_op "write" "$APP_DIR/xlink-kai.desktop"
    cat > "$APP_DIR/xlink-kai.desktop" << EOF
[Desktop Entry]
Name=XLink Kai
Comment=Online multiplayer tunneling
Exec=$BIN_DIR/$SCRIPT_NAME
Type=Application
Terminal=false
Icon=xlink-kai
Categories=Network;Game;
StartupNotify=false
EOF

    header "Updating desktop database"
    refresh_desktop_db
}

ENGINE_PATH="" CONFIG_PATH="" SKIP_CAPS=false AUTOSTART=false DO_UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) show_help; exit 0 ;;
        --uninstall) DO_UNINSTALL=true; shift ;;
        --engine) [[ -z "${2:-}" || "$2" == --* ]] && die "--engine requires a path"; ENGINE_PATH="$2"; shift 2 ;;
        --config) [[ -z "${2:-}" || "$2" == --* ]] && die "--config requires a path"; CONFIG_PATH="$2"; shift 2 ;;
        --skip-caps) SKIP_CAPS=true; shift ;;
        --autostart) AUTOSTART=true; shift ;;
        *) die "Unknown option: $1" ;;
    esac
done

[[ "$DO_UNINSTALL" == "true" ]] && uninstall
[[ -f "$SCRIPT_DIR/$SCRIPT_NAME" ]] || die "$SCRIPT_NAME not found in $SCRIPT_DIR"

echo -e "${BOLD}XLink Kai Tray - Install${NC}"
echo "════════════════════════════"

header "Locating kaiengine"
if [[ -z "$ENGINE_PATH" ]]; then
    for p in "${ENGINE_SEARCH_PATHS[@]}"; do
        if [[ -f "$p" ]]; then
            ok "Found: $p"
            ENGINE_PATH="$p"
            break
        else
            echo -e "  ${DIM}✗ $p${NC}"
        fi
    done
else
    if [[ -f "$ENGINE_PATH" ]]; then
        ok "Using: $ENGINE_PATH"
    else
        echo -e "  ${RED}✗${NC} Not found: $ENGINE_PATH"
        ENGINE_PATH=""
    fi
fi

if [[ -z "$ENGINE_PATH" || ! -f "$ENGINE_PATH" ]]; then
    warn "kaiengine not found"
    read -p "  Enter path (Enter to skip): " -r p
    if [[ -n "$p" ]]; then
        if [[ -f "$p" ]]; then
            ENGINE_PATH="$p"
        else
            warn "File not found: $p"
        fi
    fi
fi

if [[ -n "$ENGINE_PATH" && -z "$CONFIG_PATH" ]]; then
    for name in kaiengine.conf kaid.conf; do
        [[ -f "$(dirname "$ENGINE_PATH")/$name" ]] && { CONFIG_PATH="$(dirname "$ENGINE_PATH")/$name"; info "Found config: $CONFIG_PATH"; break; }
    done
fi

echo -e "\n  Engine: ${CYAN}${ENGINE_PATH:-<not set>}${NC}"
echo -e "  Config: ${CYAN}${CONFIG_PATH:-<not set>}${NC}"

check_indicator
[[ "$SKIP_CAPS" == "false" ]] && set_caps
install_files

if [[ "$AUTOSTART" == "true" ]]; then
    header "Autostart"
    mkdir -p "$AUTOSTART_DIR"
    file_op "copy" "$AUTOSTART_DIR/xlink-kai.desktop"
    cp "$APP_DIR/xlink-kai.desktop" "$AUTOSTART_DIR/xlink-kai.desktop"
    ok "Enabled"
fi

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    header "Warning"
    warn "$BIN_DIR is not in your \$PATH"
    info "Add to your shell rc:  export PATH=\"$BIN_DIR:\$PATH\""
fi

echo -e "\n${GREEN}Done${NC}"
[[ -z "$ENGINE_PATH" ]] && warn "Set engine path from the tray menu or edit $CONFIG_DIR/settings.conf"
