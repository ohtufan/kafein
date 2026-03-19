# Kafein

Minimalist macOS menu bar app to prevent your Mac from sleeping. Zero dependencies, native Swift.

## Features

- **Sleep Prevention** — Prevents system idle sleep with a single click
- **Timer** — Auto-deactivate after 15min, 30min, 1hr, 2hr, or custom duration
- **Battery Safety** — Auto-deactivate when battery drops below threshold
- **Schedule** — Set weekly schedules for automatic activation
- **Global Hotkey** — Toggle with Cmd+Shift+K from anywhere
- **Launch at Login** — Start automatically when you log in
- **Menu Bar Only** — Lives in your menu bar, no Dock icon

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ (for building from source)

## Install

### From Source

```bash
git clone https://github.com/taostudio/kafein.git
cd kafein
make bundle
make install
```

### Homebrew (coming soon)

```bash
brew install taostudio/tap/kafein
```

## Usage

After launching, Kafein appears in your menu bar as a coffee cup icon.

- **Click** the icon to open the menu
- **Activate/Deactivate** to toggle sleep prevention
- **Activate For...** to set a timer
- **Preferences** to configure battery threshold, schedule, hotkey, and launch at login

### Menu Bar Icon

| State | Icon |
|-------|------|
| Inactive | ☕ (outline) |
| Active | ☕ (filled) |

### Verify Sleep Prevention

```bash
pmset -g assertions
```

When active, you'll see a `PreventUserIdleSystemSleep` assertion from Kafein.

## Build

```bash
# Build
make build

# Run tests
make test

# Create .app bundle
make bundle

# Install to /Applications
make install

# Run directly
make run

# Clean
make clean
```

## Unsigned App Notice

Kafein is distributed without code signing. On first launch:

1. Right-click `Kafein.app`
2. Select **Open**
3. Click **Open** in the dialog

## License

MIT — see [LICENSE](LICENSE)
