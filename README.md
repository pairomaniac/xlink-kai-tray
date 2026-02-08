# XLink Kai Tray

System tray launcher for XLink Kai on Linux.

<img width="222" height="223" alt="image" src="https://github.com/user-attachments/assets/1f178798-f0f0-4bad-a7ae-cf3ac933cea0" />

## Requirements

An AppIndicator library is the only dependency not typically preinstalled:

| Distro | Package |
|---|---|
| Fedora / RHEL / Nobara / Bazzite | `sudo dnf install libayatana-appindicator-gtk3` |
| Ubuntu / Debian / Pop!_OS / Linux Mint | `sudo apt install gir1.2-ayatanaappindicator3-0.1` |
| Arch / Manjaro / EndeavourOS / CachyOS | `sudo pacman -S libayatana-appindicator` |
| openSUSE | `sudo zypper install typelib-1_0-AyatanaAppIndicator3-0_1` |

GNOME requires the [AppIndicator extension](https://extensions.gnome.org/extension/615/appindicator-support/).

The installer checks for this and shows the correct command if missing.

## Install

```bash
chmod +x xlink-kai-tray-install.sh
./xlink-kai-tray-install.sh
```

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

kaiengine needs `cap_net_raw` and `cap_net_admin` to capture and inject raw packets without root.

The installer sets these via `sudo setcap` if an engine path is known. The tray app also checks on startup and when setting a new engine path — if capabilities are missing, it prompts with a polkit password dialog to grant them. If declined or if it fails, a copyable `setcap` command is shown.

Skip during install with `--skip-caps`:

```bash
sudo setcap cap_net_raw,cap_net_admin=eip /path/to/kaiengine
```

## Tray Menu

- **Open Web UI** — opens `http://localhost:34522` in browser (greyed out until engine is running with capabilities set)
- **Set Engine Path…** — file picker to change kaiengine binary, prompts for capabilities if needed, saves to config and starts engine
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
