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

--no-rosetta     Skip Rosetta 2 installation
--no-formulae    Skip installing Homebrew formulae
--no-casks       Skip installing Homebrew casks
--help           Show help message
```

## What Gets Installed

### System Components

- **Xcode Command Line Tools** - Essential development tools and compilers
- **Homebrew** - macOS package manager
- **Rosetta 2** - Required for running x86_64 applications on Apple Silicon

### Formulae (Command-line Tools)

No formulae are enabled by default. Uncomment or add entries in the `FORMULAE` array to install command-line tools.

### Applications (Casks)

| Application | Description |
|------------|-------------|
| 1Password | Password manager |
| AppCleaner | Application uninstaller |
| Karabiner-Elements | Keyboard customization |
| Rocket | Emoji picker |
| Spotify | Music streaming |
| Visual Studio Code | Code editor |

Additional casks (Docker, Slack, Zoom, etc.) are available commented out in the script — uncomment to include them.

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
- **CLI flags**: Skip Rosetta, formulae, or casks as needed

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
