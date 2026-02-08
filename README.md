# XLink Kai Tray

System tray launcher for XLink Kai on Linux - makes using the program on Linux more user-friendly.

## Requirements

- Python 3
- GTK 3
- AppIndicator library (Ayatana or legacy)
- `xdg-open`

### Packages by distro

| Distro | Packages |
|---|---|
| Fedora / RHEL / Nobara / Bazzite | `python3-gobject libayatana-appindicator-gtk3` |
| Ubuntu / Debian / Pop!_OS / Mint | `python3-gi gir1.2-ayatanaappindicator3-0.1` |
| Arch / Manjaro / EndeavourOS / CachyOS | `python-gobject libayatana-appindicator` |

### Desktop environments

Works with any DE that supports AppIndicator/system tray (KDE, XFCE, Cinnamon, Budgie, MATE, etc.).

GNOME requires the [AppIndicator extension](https://extensions.gnome.org/extension/615/appindicator-support/).

## Install

```bash
chmod +x xlink-kai-tray-install.sh
./xlink-kai-tray-install.sh
```

The installer checks for dependencies and exits with the appropriate install command if missing.

Sudo is only requested for setting network capabilities (unless `--skip-caps`).

### Options

```bash
./xlink-kai-tray-install.sh --engine /path/to/kaiengine  # custom engine path
./xlink-kai-tray-install.sh --autostart                  # enable autostart on login
./xlink-kai-tray-install.sh --skip-caps                  # skip capabilities, no sudo
./xlink-kai-tray-install.sh --uninstall                  # remove all files
```

### Engine detection

Auto-detects kaiengine in:
- `/usr/bin/kaiengine`
- `/opt/kaiEngine-standalone/kaiengine`
- `~/.local/bin/kaiengine`
- `~/kaiEngine-standalone/kaiengine`

If not found, the installer prompts for a path. Can also be set later from the tray menu.

### Network capabilities

kaiengine needs `cap_net_raw` and `cap_net_admin` to capture and inject raw packets without root. The installer sets these via `setcap` as extended attributes on the binary. Verify with:

```bash
getcap /path/to/kaiengine
```

`--skip-caps` skips this. You'll need to either run kaiengine as root or set them manually:

```bash
sudo setcap cap_net_raw,cap_net_admin=eip /path/to/kaiengine
```

## Tray Menu

- **Open Web UI** — opens `http://localhost:34522` in browser (greyed out until engine is set)
- **Set Engine Path…** — file picker to change kaiengine binary, saves to config and restarts engine
- **Autostart** — toggle launch on login
- **Stop & Quit** — stops engine and exits

## Files

| File | Location |
|---|---|
| Tray app | `~/.local/bin/xlink-kai-tray` |
| Icon | `~/.local/share/icons/xlink-kai.png` |
| Desktop entry | `~/.local/share/applications/xlink-kai.desktop` |
| Autostart entry | `~/.config/autostart/xlink-kai.desktop` |
| Config | `~/.config/xlink-kai/settings.conf` |

## AI Disclaimer

This script was made with AI assistance.
