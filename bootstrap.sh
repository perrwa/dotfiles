#!/usr/bin/env bash
set -e

header() {
  echo ""
  echo "=== $1 ==="
}

# ---------------------------
# Xcode Command Line Tools
# ---------------------------
header "Checking Xcode command line tools"
if ! xcode-select -p &>/dev/null; then
  echo "→ Installing Xcode command line tools…"
  xcode-select --install
else
  echo "✓ Xcode tools already installed"
fi

# ---------------------------
# Homebrew
# ---------------------------
header "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✓ Homebrew already installed"
fi

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

brew update

# ---------------------------
# Rosetta
# ---------------------------
header "Checking Rosetta 2"
if /usr/bin/pgrep oahd &>/dev/null; then
  echo "✓ Rosetta already installed"
else
  echo "→ Installing Rosetta…"
  softwareupdate --install-rosetta --agree-to-license || true
fi

# ---------------------------
# Formulae
# ---------------------------
header "Installing formulae"
FORMULAE=(
  "qmk/qmk/qmk"
)

for formula in "${FORMULAE[@]}"; do
  if brew list --formula | grep -q "^$(basename "$formula")$"; then
    echo "✓ $formula already installed"
  else
    echo "→ Installing $formula"
    brew install "$formula"
  fi
done

# ---------------------------
# Casks
# ---------------------------
header "Installing casks"
CASKS=(
  1password
  appcleaner
  docker
  docker-desktop
  google-drive
  handbrake-app
  iina
  karabiner-elements
  logi-options+
  logitune
  macfuse
  microsoft-edge
  rocket
  rode-connect
  slack
  spotify
  visual-studio-code
  zoom
)

for cask in "${CASKS[@]}"; do
  if brew list --cask | grep -q "^$cask$"; then
    echo "✓ $cask already installed"
  else
    echo "→ Installing $cask"
    brew install --cask "$cask"
  fi
done

# ---------------------------
# macOS defaults
# ---------------------------
header "Setting macOS defaults"

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock largesize -int 54
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock show-recents -bool false

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Restart affected apps
killall Dock
killall Finder

header "Setup complete!"
echo "Please restart your terminal to ensure all changes take effect."
