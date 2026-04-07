# macOS Bootstrap Script

Automated setup script for configuring a new macOS development environment with essential tools and applications.

## Overview

This bootstrap script automates the installation and configuration of development tools, applications, and macOS system settings. It's designed to be idempotent, meaning you can run it multiple times safely without reinstalling already-present software.

## Prerequisites

- macOS (tested on Apple Silicon Macs)
- Administrator access to your Mac

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/perrwa/dotfiles/main/bootstrap.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/perrwa/dotfiles.git
cd dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

## Options

```
./bootstrap.sh [options]

--no-rosetta       Skip Rosetta 2 installation
--no-formulae      Skip installing Homebrew formulae
--no-casks         Skip installing Homebrew casks
--non-interactive  Install defaults without prompting
--help             Show help message
```

## What Gets Installed

### System Components

- **Xcode Command Line Tools** - Essential development tools and compilers
- **Homebrew** - macOS package manager
- **Rosetta 2** - Required for running x86_64 applications on Apple Silicon

### Formulae (Command-line Tools)

The following formulae are available. None are pre-selected by default:

- **qmk** - QMK keyboard firmware tools

Add new entries to `ALL_FORMULAE` in the script to make them available, and to `DEFAULT_FORMULAE` to pre-select them.

### Applications (Casks)

The script presents an interactive picker with all available casks. These are **pre-selected** by default:

| Application | Description |
|------------|-------------|
| 1Password | Password manager |
| AppCleaner | Application uninstaller |
| Karabiner-Elements | Keyboard customization |
| Rocket | Emoji picker |
| Spotify | Music streaming |
| Visual Studio Code | Code editor |

These are also available in the picker (not pre-selected):

| Application | Description |
|------------|-------------|
| Docker | Container runtime |
| Docker Desktop | Container platform GUI |
| Google Drive | Cloud storage |
| HandBrake | Video transcoder |
| IINA | Media player |
| Logi Options+ | Logitech device settings |
| Microsoft Edge | Web browser |
| Rode Connect | Audio interface software |
| Slack | Team communication |
| Zoom | Video conferencing |

Already-installed items are skipped automatically and won't appear in the picker.

### macOS Settings

The script configures the following system preferences:

**Dock:**

- Scale minimize effect
- Show hidden app indicators
- Enable scroll-to-open
- Group windows by app in Exposé
- Reset Launchpad layout
- Clear persistent Dock apps

**Screenshot:**

- Disable window shadows in screenshots
- Disable floating thumbnail after capture

**Finder:**

- Show path bar and status bar
- Sort folders before files (including Desktop)
- Default to list view
- Search current folder by default
- Disable extension change warnings
- Show all file extensions

**Global:**

- Save new documents locally (not iCloud)
- Small sidebar icon size
- Show scroll bars only when scrolling

**Storage:**

- Prevent .DS_Store files on network and USB drives

**Input:**

- Enable three-finger trackpad drag
- Disable press-and-hold for VS Code (enables key repeat)

## Customization

To customize available packages, edit the arrays in `bootstrap.sh`:

- `ALL_FORMULAE` / `ALL_CASKS` — everything shown in the interactive picker
- `DEFAULT_FORMULAE` / `DEFAULT_CASKS` — items pre-selected in the picker (and installed in `--non-interactive` mode)

Example:

```bash
ALL_FORMULAE=(
  "qmk/qmk/qmk"
  "git"
  "node"
  "python"
)

DEFAULT_FORMULAE=(
  "git"
  "node"
)
```

## Features

- **Interactive**: Space-to-toggle selection of formulae and casks via [gum](https://github.com/charmbracelet/gum)
- **Idempotent**: Safe to run multiple times
- **Progress indicators**: Clear feedback on installation status
- **Error handling**: Continues even if individual installations fail
- **Smart checks**: Only shows items that aren't already installed
- **CLI flags**: Skip Rosetta, formulae, or casks; run non-interactively

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
