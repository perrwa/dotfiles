#!/usr/bin/env bash
set -e

SKIP_ROSETTA=false
SKIP_FORMULAE=false
SKIP_CASKS=false
INTERACTIVE=true

usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --no-rosetta       Skip Rosetta installation"
  echo "  --no-formulae      Skip installing Homebrew formulae"
  echo "  --no-casks         Skip installing Homebrew casks"
  echo "  --non-interactive  Install defaults without prompting"
  echo "  --help             Show this help message"
  exit 0
}

# --- Parse Flags ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-rosetta)       SKIP_ROSETTA=true ;;
    --no-formulae)      SKIP_FORMULAE=true ;;
    --no-casks)         SKIP_CASKS=true ;;
    --non-interactive)  INTERACTIVE=false ;;
    --help)             usage ;;
    *)
      echo "Error: Unknown option '$1'"
      echo "Run with --help for available options."
      exit 1
      ;;
  esac
  shift
done

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
  echo "Waiting for Xcode tools to finish installing…"
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
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
# Gum (interactive prompts)
# ---------------------------
if [[ "$INTERACTIVE" == true ]]; then
  if ! command -v gum &>/dev/null; then
    echo "→ Installing gum (interactive prompts)…"
    brew install gum
  fi
fi

# ---------------------------
# Rosetta
# ---------------------------
if [[ "$SKIP_ROSETTA" == false ]]; then
  header "Checking Rosetta 2"
  if /usr/bin/pgrep oahd &>/dev/null; then
    echo "✓ Rosetta already installed"
  else
    echo "→ Installing Rosetta…"
    softwareupdate --install-rosetta --agree-to-license || true
  fi
else
  header "Skipping Rosetta (flag)"
fi

# ---------------------------
# Formulae
# ---------------------------
if [[ "$SKIP_FORMULAE" == false ]]; then
  header "Formulae"

  # All available formulae — add new entries here
  ALL_FORMULAE=(
    "gh"
    "node"
    "qmk/qmk/qmk"
  )

  # Default selections (pre-checked in interactive mode, installed in non-interactive)
  DEFAULT_FORMULAE=(
  )

  # Filter out already-installed formulae
  AVAILABLE_FORMULAE=()
  AVAILABLE_DEFAULTS=()
  for formula in "${ALL_FORMULAE[@]}"; do
    if ! brew list --formula "$formula" &>/dev/null; then
      AVAILABLE_FORMULAE+=("$formula")
      for d in "${DEFAULT_FORMULAE[@]}"; do
        [[ "$d" == "$formula" ]] && AVAILABLE_DEFAULTS+=("$formula")
      done
    else
      echo "✓ $formula already installed"
    fi
  done

  if [[ ${#AVAILABLE_FORMULAE[@]} -gt 0 ]]; then
    if [[ "$INTERACTIVE" == true ]]; then
      SELECTED_CSV=$(printf "%s" "${AVAILABLE_DEFAULTS[*]}" | tr ' ' ',')
      echo "Select formulae to install (space to toggle, enter to confirm):"
      CHOSEN=$(gum choose --no-limit --selected="$SELECTED_CSV" "${AVAILABLE_FORMULAE[@]}") || true
    else
      CHOSEN=$(printf "%s\n" "${AVAILABLE_DEFAULTS[@]}")
    fi

    while IFS= read -r formula; do
      [[ -z "$formula" ]] && continue
      echo "→ Installing $formula"
      brew install "$formula"
    done <<< "$CHOSEN"
  fi
else
  header "Skipping formulae (flag)"
fi

# ---------------------------
# Casks
# ---------------------------
if [[ "$SKIP_CASKS" == false ]]; then
  header "Casks"

  # All available casks — add new entries here
  ALL_CASKS=(
    1password
    appcleaner
    docker
    docker-desktop
    google-drive
    handbrake
    iina
    karabiner-elements
    logi-options+
    microsoft-edge
    rocket
    rode-connect
    slack
    spotify
    visual-studio-code
    zoom
  )

  # Default selections (pre-checked in interactive mode, installed in non-interactive)
  DEFAULT_CASKS=(
    1password
    appcleaner
    karabiner-elements
    rocket
    spotify
    visual-studio-code
  )

  # Filter out already-installed casks
  AVAILABLE_CASKS=()
  AVAILABLE_DEFAULTS=()
  for cask in "${ALL_CASKS[@]}"; do
    if ! brew list --cask "$cask" &>/dev/null; then
      AVAILABLE_CASKS+=("$cask")
      for d in "${DEFAULT_CASKS[@]}"; do
        [[ "$d" == "$cask" ]] && AVAILABLE_DEFAULTS+=("$cask")
      done
    else
      echo "✓ $cask already installed"
    fi
  done

  if [[ ${#AVAILABLE_CASKS[@]} -gt 0 ]]; then
    if [[ "$INTERACTIVE" == true ]]; then
      SELECTED_CSV=$(printf "%s" "${AVAILABLE_DEFAULTS[*]}" | tr ' ' ',')
      echo "Select casks to install (space to toggle, enter to confirm):"
      CHOSEN=$(gum choose --no-limit --selected="$SELECTED_CSV" "${AVAILABLE_CASKS[@]}") || true
    else
      CHOSEN=$(printf "%s\n" "${AVAILABLE_DEFAULTS[@]}")
    fi

    while IFS= read -r cask; do
      [[ -z "$cask" ]] && continue
      echo "→ Installing $cask"
      brew install --cask "$cask"
    done <<< "$CHOSEN"
  fi
else
  header "Skipping casks (flag)"
fi

# ---------------------------
# macOS defaults
# ---------------------------
header "Setting macOS defaults"

# Dock settings
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock scroll-to-open -bool true
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.dock ResetLaunchPad -bool true
defaults write com.apple.dock persistent-apps -array

# Screenshot behavior
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture show-thumbnail -bool false

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Global system settings
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
defaults write -g AppleShowScrollBars -string "WhenScrolling"

# Prevent .DS_Store files
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Input & trackpad behavior
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Disable infrared remote
# defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -int 0

# Restart affected apps
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

header "Setup complete!"
echo "Please restart your terminal to ensure all changes take effect."
