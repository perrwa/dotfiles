# macOS Bootstrap Script

Automated setup script for configuring a new macOS development environment with essential tools and applications.

## Overview

This bootstrap script automates the installation and configuration of development tools, applications, and macOS system settings. It's designed to be idempotent, meaning you can run it multiple times safely without reinstalling already-present software.

## Prerequisites

- macOS (tested on Apple Silicon Macs)
- Administrator access to your Mac

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/perrwa/dotfiles/master/bootstrap.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/perrwa/dotfiles.git
cd dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

## What Gets Installed

### System Components

- **Xcode Command Line Tools** - Essential development tools and compilers
- **Homebrew** - macOS package manager
- **Rosetta 2** - Required for running x86_64 applications on Apple Silicon

### Formulae (Command-line Tools)

- **qmk** - QMK keyboard firmware tools

### Applications (Casks)

| Application | Description |
|------------|-------------|
| 1Password | Password manager |
| AppCleaner | Application uninstaller |
| Docker & Docker Desktop | Container platform |
| Google Drive | Cloud storage |
| HandBrake | Video transcoder |
| IINA | Media player |
| Karabiner-Elements | Keyboard customization |
| Logi Options+ | Logitech device settings |
| LogiTune | Logitech webcam/headset software |
| macFUSE | File system extension |
| Microsoft Edge | Web browser |
| Rocket | Emoji picker |
| Rode Connect | Audio interface software |
| Slack | Team communication |
| Spotify | Music streaming |
| Visual Studio Code | Code editor |
| Zoom | Video conferencing |

### macOS Settings

The script configures the following system preferences:

**Dock:**
- Enable auto-hide
- Set tile size to 36px
- Enable magnification (up to 54px)
- Hide recent applications

**Finder:**
- Show path bar
- Show status bar
- Show all file extensions

## Customization

To customize the script for your needs:

1. Edit the `FORMULAE` array to add/remove command-line tools
2. Edit the `CASKS` array to add/remove applications
3. Modify the macOS defaults section to adjust system preferences

Example:

```bash
FORMULAE=(
  "qmk/qmk/qmk"
  "git"
  "node"
  "python"
)

CASKS=(
  1password
  visual-studio-code
  # Add your preferred apps here
)
```

## Features

- **Idempotent**: Safe to run multiple times
- **Progress indicators**: Clear feedback on installation status
- **Error handling**: Continues even if individual installations fail
- **Smart checks**: Only installs what's missing

## Post-Installation

After the script completes:

1. Restart your terminal to ensure all environment changes take effect
2. Sign in to installed applications (1Password, Slack, etc.)
3. Configure application-specific settings as needed

## Troubleshooting

If you encounter issues:

- **Homebrew installation fails**: Ensure you have a stable internet connection
- **Xcode tools not installing**: Run `xcode-select --install` manually
- **Cask installation fails**: Some apps may require manual approval in System Settings → Privacy & Security

## License

MIT

## Contributing

Feel free to submit issues or pull requests for improvements.
